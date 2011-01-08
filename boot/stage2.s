;
; stage2.s ~ Bootloader's second stage
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

BITS 16
ORG 0x1000

jmp start


stage2_init db "Running Second-stage", 13, 10, 0
a20_enabled db "A20 line enabled", 13, 10, 0
gone_unreal db "Gone Unreal", 13, 10, 0
kernel_loaded db "Kernel loaded", 13, 10, 0
mm_failed db "Memory Map function failed", 13, 10, 0
mm_ready db "Memory Map stored!", 13, 10, 0

%include "boot/screen.s"
%include "boot/screen.mac"

%include "boot/a20.s"
%include "boot/unreal.s"
%include "boot/mmap.s"
%include "boot/disk.s"
%include "boot/gdt.s"


start:
  CLEAR
  PRINT stage2_init

; === A20 line ===/
  call enable_a20   
  PRINT a20_enabled
; ===/

; === Go Unreal ===/
  call enable_unreal_mode
  PRINT gone_unreal
; ===/

; === Memory Map ===/
  call make_mmap
  cmp dword [mmap_entries], 0
  jne .mmap_ok

  PRINT mm_failed
  jmp $

.mmap_ok:
  PRINT mm_ready
; ===/


  ; test unreal mode
  ;mov ebx, 0xcafecafe
  ;mov eax, 0x200000
  ;mov dword [ds:eax], ebx
  ;mov ecx, [ds:eax]


  ; TODO load kernel at 0x100000 (start of high-memory, >= 1 Mb)
  ;push [[S2SIZE + 1]]
  ;push 0
  ;push 0x1000
  ;push S2SIZE
  ;call read_disk
  ;add esi, 8

.idle:
  xchg bx, bx
  jmp .idle


; === Enter Protected Mode ===

enter_pm:
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

  jmp 08h:01000h    ; Jump to section 08h (code), offset 01000h
