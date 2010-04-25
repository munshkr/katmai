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

; NOTE: This header is based on info taken from Wikipedia's article
; about FAT filesystem, and is intended to be stored in a 3 1/2 floppy.


; == BIOS parameter block ==

db "NoxPgOS", 0  ; OEM Identifier
dw 512           ; Bytes per sector
db 1             ; Sectors per cluster
dw 1             ; Reserved sectors (only bootsector)
db 2             ; Number of FATs
dw 224           ; Root entries
dw 2880          ; Number of sectors
db 0f0h           ; Media descriptor
dw 9             ; Sectors per FAT
dw 18            ; Sectors per track
dw 2             ; Heads per cylinder (double sided)
dd 0             ; Hidden sectors
dd 0             ; Total sectors (unused, see Number of sectors)

; == Extended BIOS parameter block ==
drive db 0       ; Used to store boot device

; Rest of header ignored...
