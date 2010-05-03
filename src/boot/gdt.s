;
; gdt.s ~ GDT initial structure
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

;----------Global Descriptor Table----------;

gdt:          ; Address for the GDT

gdt_null:           ; Null Segment
  dd 0
  dd 0
  
KERNEL_CODE       equ $-gdt
gdt_kernel_code:
  dw 0FFFFh         ; Limit 0xFFFF
  dw 0        ; Base 0:15
  db 0        ; Base 16:23
  db 09Ah     ; Present, Ring 0, Code, Non-conforming, Readable
  db 0CFh     ; Page-granular
  db 0        ; Base 24:31

KERNEL_DATA       equ $-gdt
gdt_kernel_data:      
  dw 0FFFFh         ; Limit 0xFFFF
  dw 0        ; Base 0:15
  db 0        ; Base 16:23
  db 092h     ; Present, Ring 0, Data, Expand-up, Writable
  db 0CFh     ; Page-granular
  db 0        ; Base 24:32

gdt_interrupts:
  dw 0FFFFh
  dw 01000h
  db 0
  db 10011110b
  db 11001111b
  db 0

gdt_end:      ; Used to calculate the size of the GDT

gdt_desc:           ; The GDT descriptor
  dw gdt_end - gdt - 1    ; Limit (size)
  dd gdt      ; Address of the GDT
