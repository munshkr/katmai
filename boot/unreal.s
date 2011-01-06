;
; unreal.s ~ Unreal mode routine
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

_gdtinfo:
   dw _gdt_end - _gdt - 1   ;last byte in table
   dd _gdt                 ;start of table

_gdt         dd 0,0        ; entry 0 is always unused
flatdesc    db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
_gdt_end:


enable_unreal_mode:
  push ds                ; save real mode

  lgdt [_gdtinfo]         ; load gdt register

  mov eax, cr0           ; switch to pmode by
  or al, 1               ; set pmode bit
  mov cr0, eax

  mov bx, 0x08           ; select descriptor 1
  mov ds, bx             ; 8h = 1000b

  and al, 0xfe           ; back to realmode
  mov cr0, eax           ; by toggling bit again

  pop ds                 ; get back old segment
  ret
