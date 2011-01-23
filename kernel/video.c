/*
* video.c ~ Video driver
*
* Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
*                Patricio Reboratti <darthpolly@gmail.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*/

#include "video.h"


static void scroll(void);
static void putln(void);
static void update_cursor(void);

static unsigned int len(const int number, const char base);
static unsigned int ulen(const unsigned int number, const char base);
static int pow(const int base, const unsigned int exponent);
static int print_dec(const int number);
static int print_udec(const unsigned int number);
static int print_uhex(const unsigned int number);


// Global cursor
int x = 0;
int y = 0;
char backcolor = C_BLACK;
char forecolor = C_LIGHT_GRAY;


void clear(void) {
    // FIXME Use string's memset here
    short *pos = (short *) VGA_TEXT_BUFFER;
    for (int i=0; i < MAX_COLS * MAX_ROWS; ++i) {
        *pos++ = 0;
    }
    x = 0;
    y = 0;
    update_cursor();
}

int putchar(const char c) {
    if (c == '\n') {
        putln();
    } else if (c == '\t') {
        x += TAB_WIDTH;
    } else {
        char attrib = (backcolor << 4) | (forecolor & 0x0f);
        volatile short *pos;
        pos = (short *) VGA_TEXT_BUFFER + (y * MAX_COLS + x);
        *pos = c | (attrib << 8);
        x++;
    }
    if (x >= MAX_COLS) {
        putln();
    }
    return c;
}


/* Stripped down version of C standard `printf` with only these specifiers:
 *   %c (character)
 *   %s (string)
 *   %d (decimal integer)
 *   %u (unsigned decimal integer)
 *   %x (hexadecimal integer
 *   %% (write '%' character)
 */
int printf(const char* format, ...)
{
    int size = 0;
    va_list ap;
    const char* ptr = format;
    char* str;

    va_start(ap, format);
    while (*ptr) {
        if (*ptr == '%') {
            ptr++;
            switch (*ptr) {
              case 'c':
                putchar((char) va_arg(ap, int));
                size++;
                break;
              case 's':
                str = va_arg(ap, char*);
                while (*str) {
                    putchar(*str++);
                    size++;
                }
                break;
              case 'd':
                size += print_dec(va_arg(ap, int));
                break;
              case 'u':
                size += print_udec(va_arg(ap, unsigned int));
                break;
              case 'x':
                size += print_uhex(va_arg(ap, int));
                break;
              case '%':
                putchar('%');
                size++;
            }
        } else {
            putchar(*ptr);
            size++;
        }
        ptr++;
    }
    va_end(ap);

    return size;
}


static void scroll(void) {
    short *pos = (short *) VGA_TEXT_BUFFER;
    short *cur_pos = pos + MAX_COLS;
    for (int row=1; row < MAX_ROWS; ++row) {
        for (int col=0; col < MAX_COLS; ++col) {
            *pos++ = *cur_pos++;
        }
    }
    for (int col=0; col < MAX_COLS; ++col) {
        *pos++ = 0;
    }
}

static void putln(void) {
    x = 0;
    y++;
    if (y == MAX_ROWS) {
        scroll();
        y--;
    }
    update_cursor();
}

static void update_cursor(void) {
    uint16_t location = y * MAX_COLS + x;

    // FIXME The base port (here assumed to be 0x3d4 and 0x3d5)
    // should be read from the BIOS data area.

    outb(0x3d4, 14);            // Send the high cursor byte
    outb(0x3d5, location >> 8);
    outb(0x3d4, 15);            // Send the low cursor byte
    outb(0x3d5, location);
}

// Get number of digits of a number (signed)
static unsigned int len(const int number, const char base) {
    unsigned int length = 1;
    unsigned int div = ABS(number);

    while (div) {
        div /= base;
        if (!div) break;
        length++;
    }
    return length;
}

// Get number of digits of a number (unsigned)
static unsigned int ulen(const unsigned int number, const char base) {
    unsigned int length = 1;
    unsigned int div = number;

    while (div) {
        div /= base;
        if (!div) break;
        length++;
    }
    return length;
}

// Exponentiation function
static int pow(const int base, const unsigned int exponent) {
    unsigned int i;
    unsigned int res = 1;

    for (i = 0; i < exponent; ++i) {
        res *= base;
    }
    return res;
}

static int print_dec(int number) {
    int size = 0;
    unsigned int i, digit;
    const unsigned int ln = len(number, 10);
    int mult = pow(10, ln - 1);

    if (number < 0) {
        putchar('-');
        number = -number;
        size++;
    }
    for (i = 0; i < ln; ++i) {
        digit = (number / mult) % 10;
        putchar((char) digit + ASCII_0);
        mult /= 10;
        size++;
    }
    return size;
}

static int print_udec(const unsigned int number) {
    unsigned int i, digit;
    const unsigned int ln = ulen(number, 10);
    int mult = pow(10, ln - 1);

    for (i = 0; i < ln; ++i) {
        digit = (number / mult) % 10;
        putchar((char) digit + ASCII_0);
        mult /= 10;
    }
    return ln;
}

static int print_uhex(const unsigned int number) {
    unsigned int i, digit;
    const unsigned int ln = ulen(number, 16);
    unsigned int mult = pow(16, ln - 1);

    putchar('0');
    putchar('x');
    for (i = 0; i < ln; ++i) {
        digit = (number / mult) % 16;
        if (digit < 10) {
            putchar((char) digit + ASCII_0);
        } else if (digit < 16) {
            putchar((char) (digit - 10) + ASCII_a);
        } else {
            putchar('?');
        }
        mult /= 16;
    }
    return ln + 2;
}
