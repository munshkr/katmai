# Pretty colors for pretty print
NO_COLOR := \e[0m
BULLET_COLOR := \e[1;32m
STEP_COLOR := \e[1;34m

BULLET_STRING := $(BULLET_COLOR)>>$(NO_COLOR)

ECHO := /bin/echo -e

AUXFILES := Makefile README.rst COPYING bochsrc doc
BOOTDIR := boot
KERNELDIRS := kernel

ASMFILES := $(shell find $(KERNELDIRS) -mindepth 1 \( -name "*.s" -not -name "loader.s" -not -name "multiboot.s" \))
SRCFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.c")
HDRFILES := $(shell find $(KERNELDIRS) -mindepth 1 -name "*.h")

KERNELSRCFILES := $(ASMFILES) $(SRCFILES) $(HDRFILES)
BOOTSRCFILES := $(shell find $(BOOTDIR) -mindepth 1 -name "*.s")

ALLFILES := $(BOOTSRCFILES) $(KERNELSRCFILES) $(AUXFILES)

# kernel/loader.o must be linked first when compiling kernel binary
OBJFILES := kernel/loader.o
OBJFILES += $(patsubst %.s,%.o,$(ASMFILES))
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
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Building disk image: $@$(NO_COLOR)"
	dd if=$(BOOT_BIN) of=$(DISKIMAGE) bs=512 count=1 2>/dev/null
	dd if=$(STAGE2_BIN) of=$(DISKIMAGE) bs=512 seek=1 2>/dev/null
	dd if=$(KERNEL_BIN) of=$(DISKIMAGE) bs=512 seek=$(shell echo $(STAGE2_SIZE)+1 | bc) 2>/dev/null

clean:
	-@$(RM) $(wildcard $(KERNELDIRS)/*.o $(KERNELDIRS)/*.d *.img $(BOOT_BIN) $(STAGE2_BIN) $(KERNEL_BIN) $(DISKIMAGE))

dist:
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Making tarball: $(TAR_FILE)$(NO_COLOR)"
	tar czvf $(TAR_FILE) $(ALLFILES)

todolist:
	-@for file in $(ALLFILES); do fgrep -H -e TODO -e FIXME $$file; done; true


-include $(DEPFILES)

$(KERNEL_BIN): $(OBJFILES)
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Linking: $@$(NO_COLOR)"
	$(LD) $(LDFLAGS) -o $@ $(OBJFILES)

$(STAGE2_BIN): $(BOOTSRCFILES)
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Compiling: $@$(NO_COLOR)"
	nasm -fbin boot/stage2.s -o $@

$(BOOT_BIN): $(BOOTSRCFILES) $(KERNEL_BIN) $(STAGE2_BIN)
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Compiling: $@$(NO_COLOR)"
	nasm -fbin -DKSIZE=$(KERNEL_SIZE) -DS2SIZE=$(STAGE2_SIZE) boot/boot.s -o $@

%.o: %.s Makefile
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Assembling: $@$(NO_COLOR)"
	nasm -felf32 $< -o $@

%.o: %.c Makefile
	@$(ECHO) "$(BULLET_STRING) $(STEP_COLOR)Compiling: $@$(NO_COLOR)"
	$(CC) $(CFLAGS) -DNDEBUG -MMD -MP -MT "$*.d" -std=c99 -c $< -o $@
