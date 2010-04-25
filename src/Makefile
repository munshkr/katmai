AUXFILES := Makefile README COPYING bochsrc
BOOTDIR := boot
KERNELDIRS := kernel

ASMFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.s")
SRCFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.c")
HDRFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.h")

BOOTSRCFILES := $(shell find $(BOOTDIR) -mindepth 1 -name "*.s")

ALLFILES := $(BOOTSRCFILES) $(SRCFILES) $(ASMFILES) $(HDRFILES)

OBJFILES := $(patsubst %.c,%.o,$(SRCFILES)) 
OBJFILES += $(patsubst %.s,%.o,$(ASMFILES))

DEPFILES := $(patsubst %.c,%.d,$(SRCFILES))

BOOTLOADER_BIN := boot.bin
KERNEL_BIN := kernel.bin
DISKIMAGE := diskette.img
TAR_FILE := noxpgos.tar.gz

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

$(DISKIMAGE): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "Building disk image "$@
	@dd if=$(BOOTLOADER_BIN) of=$(DISKIMAGE) bs=512 count=1
	@dd if=$(KERNEL_BIN) of=$(DISKIMAGE) bs=512 seek=1

clean:
	-@$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(BOOTLOADER_BIN) $(KERNEL_BIN) $(DISKIMAGE))

dist:
	@echo "Creating tarball "$(TAR_FILE)
	@tar czf $(TAR_FILE) $(ALLFILES) $(AUXFILES)

todolist:
	-@for file in $(ALLFILES); do fgrep -H -e TODO -e FIXME $$file; done; true


-include $(DEPFILES)

$(BOOTLOADER_BIN):
	@echo "Compiling "$@
	@nasm -fbin boot/boot.s -o $@

$(KERNEL_BIN): $(OBJFILES)
	@echo "Compiling "$@
	@ld $(LDFLAGS) -o $@ $(OBJFILES)

%.o: %.s Makefile
	@nasm -felf32 $< -o $@

%.o: %.c Makefile
	@$(CC) $(CFLAGS) -DNDEBUG -MMD -MP -MT "$*.d" -std=c99 -c $< -o $@
