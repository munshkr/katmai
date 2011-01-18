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
* but WITHOUT ANY WARRANTY// without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*/

#include "video.h"
#include "x86.h"


/* global cursor */
int x = 0;
int y = 0;
char backcolor = C_BLACK;
char forecolor = C_LIGHT_GRAY;


void clear(void) {
  // FIXME Maybe we should write a memset()?
  short *pos = (short *) VGA_TEXT_BUFFER;
  for (int i=0; i < MAX_COLS * MAX_ROWS; ++i) {
    *pos++ = 0;
  }
  x = 0;
  y = 0;
}

void scroll(void) {
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

void putc(char c) {
  char attrib = (backcolor << 4) | (forecolor & 0x0f);
  volatile short *pos;
  pos = (short *) VGA_TEXT_BUFFER + (y * MAX_COLS + x);
  *pos = c | (attrib << 8);
  x++;
  if (x == MAX_COLS) {
    putln();
  }
}

void putln(void) {
  x = 0;
  y++;
}

int puts(char *message) {
	int length;
	while(*message) {
		putc(*message++);
		length++;
	}
  putln();
  if (y == MAX_ROWS) {
    scroll();
    y--;
  }
	return length;
}


/* Get number of digits of a number */
uint32_t len(const int32_t number, const uint8_t base) {
  uint32_t length = 0;
  uint32_t div = ABS(number);

  while (div) {
    div /= base;
    length++;
  }

  return length;
}

/* Exponentiation function */
uint32_t v_pow(const int32_t base, const uint32_t exponent) {
  uint32_t i;
  uint32_t res = 1;

  for (i = 0; i < exponent; ++i) {
    res *= base;
  }

  return res;
}

void print_base(int32_t number, uint8_t base) {
  uint32_t i, digit;
  const uint32_t ln = len(number, base);
  uint32_t mult = v_pow(base, ln - 1);

  if (number < 0) {
    putc('-');
    number = -number;
  }

  if (base == 16) {
    putc('0');
    putc('x');
  }

  for (i = 0; i < ln; ++i) {
    digit = (number / mult) % base;
    if (digit < 10) {
      putc((char) digit + ASCII_0);
    } else if (digit < 35) {
      putc((char) (digit - 10) + ASCII_a);
    } else {
      putc('?');
    }
    mult /= base;
  }
}
