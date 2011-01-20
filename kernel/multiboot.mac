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

; The magic field should contain this.
%define MULTIBOOT_HEADER_MAGIC        0x1badb002

; This should be in %eax.
%define MULTIBOOT_BOOTLOADER_MAGIC    0x2badb002

; The bits in the required part of flags field we don't support.
%define MULTIBOOT_UNSUPPORTED         0x0000fffc

; Alignment of multiboot modules.
%define MULTIBOOT_MOD_ALIGN           0x00001000

; Alignment of the multiboot info structure.
%define MULTIBOOT_INFO_ALIGN          0x00000004

; Flags set in the 'flags' member of the multiboot header.

; Align all boot modules on i386 page (4KB) boundaries.
%define MULTIBOOT_PAGE_ALIGN          0x00000001

; Must pass memory information to OS.
%define MULTIBOOT_MEMORY_INFO         0x00000002

; Must pass video information to OS.
%define MULTIBOOT_VIDEO_MODE          0x00000004

; This flag indicates the use of the address fields in the header.
%define MULTIBOOT_AOUT_KLUDGE         0x00010000
