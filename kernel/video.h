/*
* video.h ~ Video driver (header)
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

#ifndef __VIDEO_H__
#define __VIDEO_H__


#include "common.h"
#include "math.h"


#define VGA_TEXT_BUFFER 0xb8000
#define MAX_COLS 80
#define MAX_ROWS 25

// Colors
#define C_BLACK 0x00
#define C_LIGHT_GRAY 0x07

#define ASCII_0 0x30
#define ASCII_a 0x61


// Clear screen
void clear(void);

// Put char at current position
void putc(char);

// New line
void putln(void);

// Put string at current position
void print(char*);

// Put string at current position and linefeed
void println(char*);

void print_base(int32_t number, uint8_t base);

#define PRINT_DEC(n) print_base(n, 10)
#define PRINT_HEX(n) print_base(n, 16)


#endif /* __VIDEO_H__ */
