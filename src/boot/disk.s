;
; disk.s ~ BIOS disk reading subroutines
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

bios_read_disk:
  ; TODO Retry thrice only, then return -1 in AX on failure.

.reset:
  mov ah, 0         ; RESET-DISK command
  mov dl, 0         ; Drive 0 is floppy drive
  int 13h           ; Call BIOS routine
  jc .fail          ; If CF is set, there was an error.

  xor ax, ax
  mov es, ax
  mov bx, 01000h    ; destination address = 0000:1000

  mov ah, 02h       ; READ-SECTOR command
  mov al, ksize     ; Number of sectors to read
  mov dl, 0         ; Drive 0 is floppy drive
  mov ch, 0         ; Cylinder = 0
  mov cl, 2         ; Starting sector = 3
  mov dh, 0         ; Head = 1
  int 13h           ; Call BIOS routine
  jnc .done         ; CF is set if there was an error

.fail:
  PRINT read_disk_fail  ; Print error message,
  jmp .reset            ; and retry

.done:
  xor ax, ax
  ret
