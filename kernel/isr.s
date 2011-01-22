;
; isr.s ~ Interrupt Service Routines
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

; If you change these offsets, remember to update in `isr_hi.h`
%define PIC1_OFFSET     0x20
%define PIC2_OFFSET     0x28

%macro ISR_NOERRCODE 1
  global isr%1
  isr%1:
      cli
      push byte 0
      push byte %1
      jmp isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
  global isr%1
  isr%1:
      cli
      push byte %1
      jmp isr_common_stub
%endmacro

%macro IRQ 2
  global irq%1
  irq%1:
      cli
      push byte %1
      push byte %2
      jmp irq_common_stub
%endmacro

ISR_NOERRCODE  0
ISR_NOERRCODE  1
ISR_NOERRCODE  2
ISR_NOERRCODE  3
ISR_NOERRCODE  4
ISR_NOERRCODE  5
ISR_NOERRCODE  6
ISR_NOERRCODE  7
ISR_ERRCODE    8
ISR_NOERRCODE  9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_ERRCODE   17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

IRQ  0, (PIC1_OFFSET+0)
IRQ  1, (PIC1_OFFSET+1)
IRQ  2, (PIC1_OFFSET+2)
IRQ  3, (PIC1_OFFSET+3)
IRQ  4, (PIC1_OFFSET+4)
IRQ  5, (PIC1_OFFSET+5)
IRQ  6, (PIC1_OFFSET+6)
IRQ  7, (PIC1_OFFSET+7)

IRQ  8, (PIC2_OFFSET+0)
IRQ  9, (PIC2_OFFSET+1)
IRQ 10, (PIC2_OFFSET+2)
IRQ 11, (PIC2_OFFSET+3)
IRQ 12, (PIC2_OFFSET+4)
IRQ 13, (PIC2_OFFSET+5)
IRQ 14, (PIC2_OFFSET+6)
IRQ 15, (PIC2_OFFSET+7)


; Defined in isr_hi.c
extern isr_handler, irq_handler

; This is our common ISR stub. It saves the processor state, sets
; up for kernel mode segments, calls the C-level fault handler,
; and finally restores the stack frame.
isr_common_stub:
    pushad               ; Pushes edi, esi, ebp, esp, ebx, edx, ecx, eax

    mov ax, ds           ; Lower 16-bits of eax = ds
    push eax             ; Save the data segment descriptor

    mov ax, 0x10         ; Load the kernel data segment descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call isr_handler

    pop eax              ; Reload the original data segment descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    popad                ; Pops edi, esi, ebp...
    add esp, 8           ; Cleans up the pushed error code and pushed ISR number
    sti
    iret                 ; Pops 5 things at once: cs, eip, eflags, ss, and esp


; This is our common IRQ stub. It saves the processor state, sets
; up for kernel mode segments, calls the C-level fault handler,
; and finally restores the stack frame.
irq_common_stub:
    pusha

    mov ax, ds           ; Lower 16-bits of eax = ds
    push eax             ; Save the data segment descriptor

    mov ax, 0x10         ; Load the kernel data segment descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call irq_handler

    pop ebx              ; Reload the original data segment descriptor
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx

    popa
    add esp, 8
    sti
    iret
