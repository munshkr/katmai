;
; boot.s ~ NoxPgOS Bootloader
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

; KSIZE is kernel binary in sector size. This %define is deprecated because
; Makefile defines it automatically.
;%define KSIZE 1

BITS 16           ; We need 16-bit intructions for Real mode
ORG 0x7c00        ; The BIOS loads the boot sector into memory location 0x7c00

jmp start

; == SECTION .data ==
drive db 0        ; Stores floppy drive
%include "boot/gdt.s"

; == Bootsector Code ==
  
start:

; === Load Kernel into memory ===

read_disk:
  mov ah, 0         ; RESET-command
  int 13h           ; Call interrupt 13h
  mov [drive], dl   ; Store boot disk
  or ah, ah         ; Check for error code
  jnz read_disk     ; Try again if ah != 0

  xor ax, ax
  mov es, ax            
  mov bx, 01000h    ; Destination address = 0000:1000

  mov ah, 02h       ; READ SECTOR-command
  mov al, KSIZE     ; Number of sectors to read
  mov dl, [drive]   ; Load boot disk
  mov ch, 0         ; Cylinder = 0
  mov cl, 2         ; Starting Sector = 3
  mov dh, 0         ; Head = 1
  int 13h           ; Call interrupt 13h
  or ah, ah         ; Check for error code
  jnz read_disk     ; Try again if ah != 0


; TODO === Obtain memory map ===
;%include "boot/mmap.s"

; === Enable A20 line ===
%include "boot/a20.s"

; === Enter Protected Mode ===

enter_pm:
  cli               ; Disable interrupts, we want to be alone
  xor ax, ax        ; Clear AX register
  mov ds, ax        ; Set DS-register to 0 - used by lgdt

  lgdt [gdt_desc]   ; Load the GDT descriptor 
    
  mov eax, cr0      ; Copy the contents of CR0 into EAX
  or eax, 1         ; Set bit 0     (0xFE = Real Mode)
  mov cr0, eax      ; Copy the contents of EAX into CR0
  
  jmp 08h:kernel_segments ; Jump to code segment, offset kernel_segments
  

BITS 32           ; We now need 32-bit instructions

kernel_segments:
  mov ax, 10h       ; Save data segment identifyer
  mov ds, ax        ; Move a valid data segment into the data segment register
  mov ss, ax        ; Move a valid data segment into the stack segment register
  mov esp, 090000h  ; Move the stack pointer to 090000h
  
  jmp 08h:01000h    ; Jump to section 08h (code), offset 01000h
  


; If NASM throws "TIMES value is negative" here, it means we have
; stepped over our 512 bytes limit. We should delete code to make it
; smaller, or write a second stage bootloader.
times 510-($-$$) db 0    ; Fill up the file with zeros

dw 0AA55h           ; Boot sector identifier
