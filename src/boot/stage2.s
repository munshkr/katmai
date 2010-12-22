;
; stage2.s ~ Bootloader's second stage
;
; Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
;                Hernán Rodriguez Colmeiro <colmeiro@gmail.com>
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

BITS 16


; Physical RAM available
total_ram dw 0


%include "boot/screen.s"
%include "boot/screen.mac"

%include "boot/mmap.s"
%include "boot/a20.s"
%include "boot/gdt.s"


; === Enter Protected Mode ===

enter_pm:
  ; TODO Print debug messages

  call enable_a20   ; Enable A20 line for 32-bit addressing

  ; TODO Load kernel at 0x100000 (start of high-memory)
  ; ...

  cli               ; Disable interrupts, we want to be alone
  xor ax, ax        ; Clear AX register
  mov ds, ax        ; Set DS-register to 0 - used by lgdt

  lgdt [gdt_desc]   ; Load the GDT descriptor 

  mov eax, cr0      ; Copy the contents of CR0 into EAX
  or eax, 1         ; Set bit 0     (0xFE = Real Mode)
  mov cr0, eax      ; Copy the contents of EAX into CR0

  jmp 08h:kernel_segments ; Jump to code segment, offset kernel_segments


BITS 32             ; We now need 32-bit instructions

kernel_segments:
  mov ax, 0x10      ; Save data segment identifier
  mov ds, ax        ; Move a valid data segment into the data segment register
  mov ss, ax        ; Move a valid data segment into the stack segment register
  mov esp, 0x90000  ; Move the stack pointer to 090000h

  call do_e820      ; Detect available RAM
  mov ax, [total_ram]
  xchg bx, bx

  jmp 08h:01000h    ; Jump to section 08h (code), offset 01000h
