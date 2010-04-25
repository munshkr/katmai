#ifndef __VIDEO_H__
#define __VIDEO_H__

unsigned int x = 0;
unsigned int y = 0;
unsigned char color = 0x07;

void putc(unsigned char c) {
  unsigned char *vidmem = (unsigned char*) 0xb8000; /* pointer to video memory */
	unsigned int pos = (y * 2) + x; /* Get the position */
	vidmem[pos] = c; /* print the character */
	vidmem[pos++] = color; /* Set the color attribute */
}

int puts(unsigned char *message) {
	unsigned int length;
	while(*message) {
		putc(*message++);
		length++;
	}
	return length;
}

#endif
