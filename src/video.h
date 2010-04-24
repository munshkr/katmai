#ifndef __VIDEO_H__
#define __VIDEO_H__

/* Simple putc */
int x = 0;
int y = 0; /* Our global 'x' and 'y' */
char color = 0; /* Our global color attribute */

void putc(unsigned char c) {
	char *vidmem = (char*) 0xb8000; /* pointer to video memory */
	int pos = (y * 2) + x; /* Get the position */
	vidmem[pos] = c; /* print the character */
	vidmem[pos++] = color; /* Set the color attribute */
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
