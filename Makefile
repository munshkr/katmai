AUXFILES := Makefile README.rst COPYING bochsrc doc
BOOTDIR := boot
KERNELDIRS := kernel

ASMFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.s")
SRCFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.c")
HDRFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.h")

KERNELSRCFILES := $(ASMFILES) $(SRCFILES) $(HDRFILES)
BOOTSRCFILES := $(shell find $(BOOTDIR) -mindepth 1 -name "*.s")

ALLFILES := $(BOOTSRCFILES) $(KERNELSRCFILES) $(AUXFILES)

# kernel/loader.o must be linked first when compiling kernel binary
OBJFILES := kernel/loader.o
OBJFILES += $(patsubst %.c,%.o,$(SRCFILES)) 

DEPFILES := $(patsubst %.c,%.d,$(SRCFILES))

BOOT_BIN := boot.bin
STAGE2_BIN := stage2.bin
KERNEL_BIN := kernel.bin
DISKIMAGE := diskette.img
TAR_FILE := katmai.tar.gz

# TODO Check if these ultra-paranoid gcc flags are useful
# CFLAGS := -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
# 				  -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
# 				  -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
# 				  -Wconversion -Wstrict-prototypes
CFLAGS := -Wall -Wextra -Werror -ffreestanding -fno-builtin -nostdlib \
				  -nostartfiles -nodefaultlibs
LDFLAGS := -melf_i386 -belf32-i386 --oformat binary \
				   -Tkernel/link.ld

.PHONY: all clean dist todolist


STAGE2_SIZE = $(shell du -bB512 $(STAGE2_BIN) | cut -f1)
KERNEL_SIZE = $(shell du -bB512 $(KERNEL_BIN) | cut -f1)


all: $(DISKIMAGE)

$(DISKIMAGE): $(KERNEL_BIN) $(STAGE2_BIN) $(BOOT_BIN)
	@echo ">> Building disk image: "$@
	dd if=$(BOOT_BIN) of=$(DISKIMAGE) bs=512 count=1 2>/dev/null
	dd if=$(STAGE2_BIN) of=$(DISKIMAGE) bs=512 seek=1 2>/dev/null
	dd if=$(KERNEL_BIN) of=$(DISKIMAGE) bs=512 seek=$(shell echo $(STAGE2_SIZE)+1 | bc) 2>/dev/null

clean:
	-@$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(BOOT_BIN) $(STAGE2_BIN) $(KERNEL_BIN) $(DISKIMAGE))

dist:
	@echo ">> Making tarball: "$(TAR_FILE)
	tar czvf $(TAR_FILE) $(ALLFILES)

todolist:
	-@for file in $(ALLFILES); do fgrep -H -e TODO -e FIXME $$file; done; true


-include $(DEPFILES)

$(KERNEL_BIN): $(OBJFILES)
	@echo ">> Linking: "$@
	$(LD) $(LDFLAGS) -o $@ $(OBJFILES)

$(STAGE2_BIN): $(BOOTSRCFILES)
	@echo ">> Compiling: "$@
	nasm -fbin boot/stage2.s -o $@

$(BOOT_BIN): $(BOOTSRCFILES) $(KERNEL_BIN) $(STAGE2_BIN)
	@echo ">> Compiling: "$@
	nasm -fbin -DKSIZE=$(KERNEL_SIZE) -DS2SIZE=$(STAGE2_SIZE) boot/boot.s -o $@

%.o: %.s Makefile
	@echo ">> Compiling: "$@
	nasm -felf32 $< -o $@

%.o: %.c Makefile
	@echo ">> Compiling: "$@
	$(CC) $(CFLAGS) -DNDEBUG -MMD -MP -MT "$*.d" -std=c99 -c $< -o $@
