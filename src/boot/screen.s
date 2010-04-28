;
; screen.s ~ BIOS screen macros
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

bios_row db 0     ; Stores current cursor row

bios_clear_screen:
  pusha
  mov ah, 0x06    ; BIOS: Clear the screen
  xor cx, cx      ; from (0,0)
  mov dx, 0x184f  ; to (24,79)
  mov bh, 0x07    ; keep light grey display
  int 0x10
  mov ah, 0x02    ; BIOS: Set cursor position
  xor dx, dx      ; at (0, 0)
  mov bh, dh      ; page=0
  int 0x10
  mov byte [cs:bios_row], 0  ; update variable
  popa
  ret

bios_print:
  ; Print a null-terminated string on the screen.
  pusha
  mov ah, 0xe     ; BIOS: Write char and attr at cursor pos
  mov bx, 0x7     ; page=0, attributes is lgrey/black.
  mov dl, 1       ; first colum (forced)
  mov dh, [cs:bios_row]
  inc byte [cs:bios_row]
.loop:
  lodsb
  or al, al
  jz .done
  int 0x10
  jmp .loop
.done:
  popa
  ret
