;
; fat12.s ~ FAT12 Header for floppies
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

bios_reset:
  mov   ah, 0         ; Reset floppy disk function
  mov   dl, 0         ; Drive 0 is floppy drive
  int   0x13          ; Call BIOS routine
  jc    bios_reset    ; If Carry Flag (CF) is set, there was an error. Try again

; TODO Read files routines
