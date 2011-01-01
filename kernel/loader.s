BITS 32

extern kmain
global start

start:
	call kmain
	cli
	hlt
