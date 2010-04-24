FLAGS=-Wall -Wextra -Werror -ffreestanding -fno-builtin -nostdlib -nostartfiles -nodefaultlibs
LDFLAGS=-static -m elf_i386 --oformat binary -b elf32-i386 -e start -Ttext 0x1000
IMAGE=diskette.img

all: k b
	dd if=boot.bin of=$(IMAGE) bs=512 count=1
	dd if=kernel.bin of=$(IMAGE) bs=512 seek=1

k:
	gcc $(FLAGS) -c *.c 
	nasm -felf32 loader.asm -o loader.o
	ld $(LDFLAGS) -o kernel.bin loader.o main.o

b:
	nasm -f bin boot.asm -o boot.bin

clean:
	rm -rf *.o *.bin *.img
