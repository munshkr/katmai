AUXFILES := Makefile README COPYING bochsrc
BOOTDIR := boot
KERNELDIRS := kernel

ASMFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.s")
SRCFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.c")
HDRFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.h")

KERNELSRCFILES := $(ASMFILES) $(SRCFILES) $(HDRFILES)
BOOTSRCFILES := $(shell find $(BOOTDIR) -mindepth 1 -name "*.s")

ALLFILES := $(BOOTSRCFILES) $(KERNELSRCFILES) $(AUXFILES)

# kernel/loader.o must be linked first when compiling kernel binary,
# so we put .s files first in OBJFILES list as a workaround.
OBJFILES := $(patsubst %.s,%.o,$(ASMFILES))
OBJFILES += $(patsubst %.c,%.o,$(SRCFILES)) 

DEPFILES := $(patsubst %.c,%.d,$(SRCFILES))

BOOTLOADER_BIN := boot.bin
KERNEL_BIN := kernel.bin
DISKIMAGE := diskette.img
TAR_FILE := noxpgos.tar.gz

# TODO Check if these ultra-paranoid gcc flags are useful
# CFLAGS := -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
# 				  -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
# 				  -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
# 				  -Wconversion -Wstrict-prototypes
CFLAGS := -Wall -Wextra -Werror -ffreestanding -fno-builtin -nostdlib \
				  -nostartfiles -nodefaultlibs
LDFLAGS := -static -m elf_i386 -b elf32-i386 --oformat binary \
				   -e start -Ttext 0x1000

.PHONY: all clean dist todolist


all: $(DISKIMAGE)

$(DISKIMAGE): $(KERNEL_BIN) $(BOOTLOADER_BIN)
	@echo "--> Building disk image "$@
	@echo "Remember to check if KSIZE is the same as kernel binary size!"
	dd if=$(BOOTLOADER_BIN) of=$(DISKIMAGE) bs=512 count=1
	dd if=$(KERNEL_BIN) of=$(DISKIMAGE) bs=512 seek=1

clean:
	-@$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(BOOTLOADER_BIN) $(KERNEL_BIN) $(DISKIMAGE))

dist:
	@echo "--> Creating tarball "$(TAR_FILE)
	@tar czf $(TAR_FILE) $(ALLFILES)

todolist:
	-@for file in $(ALLFILES); do fgrep -H -e TODO -e FIXME $$file; done; true


-include $(DEPFILES)

$(KERNEL_BIN): $(OBJFILES)
	@echo "--> Compiling "$@
	$(LD) $(LDFLAGS) -o $@ $(OBJFILES)

# TODO Calculate kernel binary size and pass it to nasm line in
# bootloader so it knows exactly how much sectors it needs to read 
# from floppy.
$(BOOTLOADER_BIN): $(BOOTSRCFILES) $(KERNEL_BIN)
	@echo "--> Compiling "$@
	nasm -fbin -DKSIZE=$(shell du -bB512 $(KERNEL_BIN) | cut -f1) boot/boot.s -o $@

%.o: %.s Makefile
	nasm -felf32 $< -o $@

%.o: %.c Makefile
	$(CC) $(CFLAGS) -DNDEBUG -MMD -MP -MT "$*.d" -std=c99 -c $< -o $@
