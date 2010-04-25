//
// video.h ~ Video driver
//
// Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
//                Hernán Rodriguez Colmeiro <colmeiro@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY// without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef __VIDEO_H__
#define __VIDEO_H__

#define VGA_TEXT_BUFFER 0xb8000

/* global cursor */
int x = 0;
int y = 0;
unsigned char backcolor = 0;
unsigned char forecolor = 7;


void clear(void) {
  // clear from VGA_TEXT_BUFFER to (VGA_TEXT_BUFFER + (80 * 25 * 2))
  // maybe we should write a memcpy()?
}

void putc(char c) {
  unsigned char attrib = (backcolor << 4) | (forecolor & 0x0f);
  volatile unsigned short *pos;
  pos = (unsigned short *) VGA_TEXT_BUFFER + (y * 80 + x);
  *pos = c | (attrib << 8);
  x++;
}

int puts(char *message) {
	int length;
	while(*message) {
		putc(*message++);
		length++;
	}
	return length;
}

#endif
