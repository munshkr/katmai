;
; boot.s ~ Bootloader's first stage
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

BITS 16           ; We need 16-bit intructions for Real mode
ORG 0x7c00        ; The BIOS loads the boot sector into memory location 0x7c00


; == Header and data section ==

jmp start

; NOTE: This header is based on info taken from Wikipedia's article
; about FAT filesystem, and is intended to be stored in a 3 1/2 floppy.

; === BIOS parameter block and other data ===

bpbOEMIdentifier:     db "NoxPgOS "     ; 8 bytes
bpbBytesPerSector:    dw 512
bpbSectorsPerCluster: db 1
bpbReservedSectors:   dw 1              ; Only bootsector
bpbNumberOfFATs:      db 2
bpbRootEntries:       dw 224
bpbNumberOfSectors:   dw 2880
bpbMediaDescriptor:   db 0xf0           ; 1.44MB diskette
bpbSectorsPerFAT:     dw 9
bpbSectorsPerTrack:   dw 18
bpbHeadsPerCylinder:  dw 2              ; Double sided
bpbHiddenSectors:     dd 0
bpbTotalSectorsBig:   dd 0              ; Unused, see bpbNumberOfSectors

; === Extended BIOS parameter block ===

bpbDriveNumber:       db 0              ; Physical Drive number
bpbReserved:          db 0              ; Unused
bpbExtBootSignature:  db 0x29           ; Extended boot signature
bpbSerialNumber:      dd 0              ; Nobody cares...
bpbVolumeLabel:       db "NoxPgOS    "  ; Padded with spaces, 11 bytes
bpbFileSystem:        db "FAT12   "     ; FAT file system type, padded with spaces, 8 bytes


; FAT12 and BIOS screen subroutines
%include "boot/fat12.s"
%include "boot/screen.s"

; Messages
loading        db "Loading second-stage bootloader...", 13, 10, 0
read_disk_fail db "Failed to read sectors!", 13, 10, 0

; == Bootsector Code ==
  
start:
  ;CLEAR                   ; Clear screen
  PRINT loading           ; Print hello message

; === Load STAGE2.SYS file into memory ===

; TODO Look for STAGE2.SYS in FAT, load it in 0x1000 and jump there


; If NASM throws "TIMES value is negative" here, it means we have
; stepped over our 512 bytes limit. We should delete code to make it
; smaller.
times 510-($-$$) db 0    ; Fill up the file with zeros

dw 0AA55h           ; Boot sector identifier
