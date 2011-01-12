;
; multiboot.s ~ Multiboot header macros for loader.s
;
; Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
;                Patricio Reboratti <darthpolly@gmail.com>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

;
; Source from example code of GNU Multiboot specification version 0.6.96
; and adapted to NASM syntax.
;
; http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
;

%ifndef MUTLIBOOT_HEADER
%define MULTIBOOT_HEADER 1

; How many bytes from the start of the file we search for the header.
MULTIBOOT_SEARCH                  equ 8192

; The magic field should contain this.
MULTIBOOT_HEADER_MAGIC            equ 0x1badb002

; This should be in %eax.
MULTIBOOT_BOOTLOADER_MAGIC        equ 0x2badb002

; The bits in the required part of flags field we don't support.
MULTIBOOT_UNSUPPORTED             equ 0x0000fffc

; Alignment of multiboot modules.
MULTIBOOT_MOD_ALIGN               equ 0x00001000

; Alignment of the multiboot info structure.
MULTIBOOT_INFO_ALIGN              equ 0x00000004

; Flags set in the 'flags' member of the multiboot header.

; Align all boot modules on i386 page (4KB) boundaries.
MULTIBOOT_PAGE_ALIGN              equ 0x00000001

; Must pass memory information to OS.
MULTIBOOT_MEMORY_INFO             equ 0x00000002

; Must pass video information to OS.
MULTIBOOT_VIDEO_MODE              equ 0x00000004

; This flag indicates the use of the address fields in the header.
MULTIBOOT_AOUT_KLUDGE             equ 0x00010000

; Flags to be set in the 'flags' member of the multiboot info structure.

; is there basic lower/upper memory information?
MULTIBOOT_INFO_MEMORY             equ 0x00000001
; is there a boot device set?
MULTIBOOT_INFO_BOOTDEV            equ 0x00000002
; is the command-line defined?
MULTIBOOT_INFO_CMDLINE            equ 0x00000004
; are there modules to do something with?
MULTIBOOT_INFO_MODS               equ 0x00000008

; These next two are mutually exclusive

; is there a symbol table loaded?
MULTIBOOT_INFO_AOUT_SYMS          equ 0x00000010
; is there an ELF section header table?
MULTIBOOT_INFO_ELF_SHDR           equ 0x00000020

; is there a full memory map?
MULTIBOOT_INFO_MEM_MAP            equ 0x00000040

; Is there drive info?
MULTIBOOT_INFO_DRIVE_INFO         equ 0x00000080

; Is there a config table?
MULTIBOOT_INFO_CONFIG_TABLE       equ 0x00000100

; Is there a boot loader name?
MULTIBOOT_INFO_BOOT_LOADER_NAME   equ 0x00000200

; Is there a APM table?
MULTIBOOT_INFO_APM_TABLE          equ 0x00000400

; Is there video information?
MULTIBOOT_INFO_VIDEO_INFO         equ 0x00000800


%endif ; MULTIBOOT_HEADER
