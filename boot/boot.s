;
; boot.s ~ Bootloader's first stage
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

BITS 16           ; We need 16-bit intructions for Real mode
ORG 0x7c00        ; The BIOS loads the boot sector into memory location 0x7c00


; == Header and data section ==

jmp start
# TODO See if jmp 0x0000:start is needed

; BIOS screen subroutines
%include "boot/screen.s"
%include "boot/screen.mac"
%include "boot/disk.s"


; Messages
loading        db "Loading second-stage bootloader...", 13, 10, 0
loading_kernel db "Loading kernel...", 13, 10, 0
read_disk_fail db "Failed to read sectors!", 13, 10, 0

; == Bootsector Code ==
  
start:
  ;CLEAR                   ; Clear screen
  PRINT loading           ; Print hello message

; === Load second-stage at 0x1000 (usable low-memory) ===

  push 2
  push 0
  push 0x1000
  push S2SIZE
  call read_disk
  add esi, 8

  or ax, ax
  jnz .readerror

  jmp 0x0:0x1000

.readerror:
  PRINT read_disk_fail
  cli
  hlt


; If NASM throws "TIMES value is negative" here, it means we have
; stepped over our 512 bytes limit. We should delete code to make it
; smaller.
times 510-($-$$) db 0    ; Fill up the file with zeros

dw 0AA55h           ; Boot sector identifier
