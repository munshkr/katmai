;
; disk.s ~ Disk reading subroutines
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


; read_disk(start_sector, dest_segment, dest_offset, count)
;
; Read `n` sectors from the floppy drive using READ_DISK command
;
; Parameters:
;     - "logical" start sector number  [bp+10]
;     - destination segment            [bp+8]
;     - destination offset             [bp+6]
;     - number of sectors              [bp+4]
;
; TODO Retry thrice only, then return -1 in AX on failure.
;

; Floppy constants
SECTORS_PER_TRACK equ 18
HEADS equ 2
CYLINDERS equ 80

; Local variables
head: dw 0
track: dw 0
sec: dw 0

read_disk_fail db "Failed to read sectors!", 13, 10, 0


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

  mov ax, [bp+8]        ; destination segment
  mov es, ax
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
  pop bp                ; leave stack frame
  xor ax, ax
  ret


; read_disk32(start_sector, dest_hi, dest_lo, count)
;
; Read `n` sectors from the floppy drive to a destination 
; in high-memory (above 1Mb).
;
; Call `read_disk` routine and store read sectors on a
; buffer in conventional memory. Then relocate data from
; buffer to a 32bit offset in high memory.
;
; A20 line and unreal mode must be enabled before calling
; this routine.
;
; Parameters:
;     - "logical" start sector number  [bp+10]
;     - destination (hi)               [bp+8]
;     - destination (lo)               [bp+6]
;     - number of sectors              [bp+4]
;

BUFFER_ADDR equ 0x9000
BUFFER_SIZE equ 127 ; This the maximum number of sectors per cylinder
                    ; the READ_DISK routine of some BIOSes support.

read_disk32:
  push bp           ; set up stack frame
  mov bp, sp
  pusha             ; save all registers

  xor ecx, ecx
  mov cx, [bp+4]    ; cx: remaining sectors to copy

  xor ebx, ebx
  mov bx, [bp+10]   ; bx: logical sector number

  xor edx, edx
  mov dx, [bp+8]    ;
  shl edx, 16       ; edx: 32-bit destination offset
  mov dx, [bp+6]    ;

  xor esi, esi

.loop:
  cmp ecx, BUFFER_SIZE
  jb .esi_ksize

  mov esi, BUFFER_SIZE
  jmp .bios_copy

.esi_ksize:
  mov esi, ecx
  
.bios_copy:
  push ebx
  push 0
  push BUFFER_ADDR
  push esi
  call read_disk
  add esp, 8
  
  push esi
  push BUFFER_ADDR
  mov eax, edx
  push ax
  shr eax, 16
  push ax
  call copy_sectors
  add esp, 8

  add edx, BUFFER_SIZE
  add ebx, BUFFER_SIZE

  popa
  pop bp
  ret
  

; copy_sectors(dest_hi, dest_lo, source, count)
;
; Copy `n` sectors from source in low memory to a destination in high-memory
;
; Parameters:
;     - destination (hi)     [bp+10]
;     - destination (lo)     [bp+8]
;     - source               [bp+6]
;     - number of sectors    [bp+4]
;

copy_sectors:
  push bp           ; set up stack frame
  mov bp, sp
  pusha
  
  xor eax, eax      ;
  mov ax, [ebp+4]   ; Load Source

  xor ebx, ebx
  mov bx, [bp+8]    ;
  shl ebx, 16       ; Load 32bit dest. offset into ebx
  mov bx, [bp+6]    ;

  mov ecx, [ebp+4]  ; Load count

.loop:
  mov edx, ecx
  sal edx, 9        ; mult 512
  mov edi, edx

  add edx, eax
  push edx
  
  add edi, ebx
  push di
  shr edi, 16
  push di

  call copy_sector
  add esp, 6
  loop .loop

  popa
  pop bp
  ret

  
; copy_sector(dest_hi, dest_lo, source)
;
; Copy a sector from source in low memory to a destination in high-memory
;
; Parameters:
;     - destination (hi)     [bp+8]
;     - destination (lo)     [bp+6]
;     - source               [bp+4]
;

copy_sector:
  push bp           ; set up stack frame
  mov bp, sp
  pusha
  mov ecx, 127
  
  xor eax, eax
  mov ax, [ebp+4]

  xor ebx, ebx
  mov bx, [bp+8]    ;
  shl ebx, 16       ; load 32bit offset into ebx
  mov bx, [bp+6]    ;

.loop:
  mov edx, [ecx * 4 + eax]
  mov [ecx * 4 + ebx], edx
  loop .loop

  popa
  pop bp
  ret
