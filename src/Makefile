all:
	nasm boot.asm -f bin -o boot.bin
	dd bs=512 count=2880 if=/dev/zero of=boot.img
	dd conv=notrunc if=boot.bin of=boot.img

clean:
	rm *.bin *.img
