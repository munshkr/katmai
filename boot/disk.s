;
; disk.s ~ BIOS disk reading subroutines
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

SECTORS_PER_TRACK equ 18
HEADS equ 2
CYLINDERS equ 80


; read_disk local variables
head: dw 0
track: dw 0
sec: dw 0


; READ_DISK source, destination, lenght
; Read n sectors from the floppy drive.
;
; Parameters:
;     - "logical" sector number   [bp+10]
;     - destination segment       [bp+8]
;     - destination offset        [bp+6]
;     - number of sectors         [bp+4]
;
; TODO Retry thrice only, then return -1 in AX on failure.

read_disk:
  push bp           ; set up stack frame
  mov bp, sp
  pusha             ; save all registers


  ; Convert logical sector number to physical (sector:cylinder:head)

  ; Sector = log_sec % SECTORS_PER_TRACK
  ; Head = (log_sec / SECTORS_PER_TRACK) % HEADS

  mov ax, [bp+10]           ; get logical sector number from stack
  xor dx, dx                ; dx is high part of dividend (== 0)
  mov bx, SECTORS_PER_TRACK ; divisor
  div bx                    ; do the division
  mov [cs:sec], dx          ; sector is the remainder
  mov bl, HEADS
  div bl
  mov [cs:head], ah

  ; Track = log_sec / (SECTORS_PER_TRACK * HEADS)

  mov ax, [bp+10]                   ; get logical sector number again
  xor dx, dx                        ; dx is high part of dividend
  mov bx, SECTORS_PER_TRACK*HEADS   ; divisor
  div bx                            ; do the division
  mov [cs:track], ax                ; track is quotient


.reset:
  mov ah, 0             ; RESET-DISK command
  mov dl, 0             ; Drive 0 is floppy drive
  int 13h               ; Call BIOS routine
  jc .fail              ; If CF is set, there was an error.

  mov  ax, [bp+8]        ; destination segment
  mov  es, ax
  mov bx, [bp+6]        ; destination offset

  mov ah, 02h           ; READ-SECTOR command
  mov al, [bp+4]        ; Number of sectors to read
  mov dl, 0             ; Drive 0 is floppy drive
  mov ch, [cs:track]    ; Track
  mov cl, [cs:sec]      ; Starting sector
  mov dh, [cs:head]     ; Head
  int 13h               ; Call BIOS routine
  jnc .done             ; CF is set if there was an error

.fail:
  PRINT read_disk_fail  ; Print error message,
  jmp .reset            ; and retry

.done:
  popa
  pop  bp      ; leave stack frame
  xor ax, ax
  ret
