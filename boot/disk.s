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
;     - "logical" start sector number  [bp+4]
;     - destination segment            [bp+6]
;     - destination offset             [bp+8]
;     - number of sectors              [bp+10]
;
; TODO Retry thrice only, halt on failure
;

; Floppy constants
SECTORS_PER_TRACK equ 18
HEADS equ 2
CYLINDERS equ 80

%define start_sector [bp+4]
%define dest_segment [bp+6]
%define dest_offset  [bp+8]
%define count        [bp+10]

%define head   [bp-2]
%define track  [bp-4]
%define sector [bp-6]

read_disk_fail db "Failed to read sectors!", 13, 10, 0

read_disk:
  enter 6, 0
  pushad

  ; Convert logical sector number to physical (sector:cylinder:head)

  ; Sector = log_sec % SECTORS_PER_TRACK
  ; Head = (log_sec / SECTORS_PER_TRACK) % HEADS

  mov ax, start_sector      ; get logical sector number from stack
  xor dx, dx                ; dx is high part of dividend

  mov bx, SECTORS_PER_TRACK ; divisor
  div bx                    ; do the division
  mov sector, dx            ; sector is the remainder
  mov bl, HEADS
  div bl
  mov head, ah

  ; Track = log_sec / (SECTORS_PER_TRACK * HEADS)

  mov ax, start_sector              ; get logical sector number again
  xor dx, dx                        ; dx is high part of dividend
  mov bx, SECTORS_PER_TRACK*HEADS   ; divisor
  div bx                            ; do the division
  mov track, ax                     ; track is quotient

.reset:
  mov ah, 0             ; RESET-DISK command
  mov dl, 0             ; Drive 0 is floppy drive
  int 13h               ; Call BIOS routine
  jc .fail              ; If CF is set, there was an error.

  mov ax, dest_segment  ; destination segment
  mov es, ax
  mov bx, dest_offset   ; destination offset

  mov ah, 02h           ; READ-SECTOR command
  mov al, count         ; Number of sectors to read
  mov dl, 0             ; Drive 0 is floppy drive
  mov ch, track         ; Track
  mov cl, sector        ; Starting sector
  mov dh, head          ; Head
  int 13h               ; Call BIOS routine
  jnc .done             ; CF is set if there was an error

.fail:
  PRINT read_disk_fail  ; Print error message,
  jmp .reset            ; and retry

.done:
  popad
  leave
  ret


; read_disk32(uint16 start_sector, uint32 destination, uint16 count)
;
; Read `n` sectors from the floppy drive to a destination
; in high-memory (above 1Mb).
;
; Call `read_disk` routine and store read sectors on a
; buffer in conventional memory. Then relocate data from
; buffer to a 32bit offset in high memory.
;
; NOTE: A20 line and unreal mode must be enabled before
; calling this routine.
;
; Parameters:
;     - "logical" start sector number  [bp+4]
;     - destination                    [bp+6]
;     - number of sectors              [bp+10]
;

BUFFER_SEGMENT equ 0x7000
BUFFER_OFFSET  equ 0
BUFFER_ADDRESS equ 0x70000  ; Final address after real mode address translation

BUFFER_SIZE    equ 127      ; This the maximum number of sectors per cylinder
                            ; the READ_DISK routine of some BIOSes support.
BUFFER_SIZE_B  equ BUFFER_SIZE * 512

%define start_sector [bp+4]
%define dest         [bp+6]
%define count        [bp+10]

read_disk32:
  enter 0, 0
  pushad

  xor ecx, ecx
  mov cx, count           ; cx: remaining sectors to copy

  xor ebx, ebx
  mov bx, start_sector    ; bx: logical sector number

  mov edx, dword dest     ; edx: 32bit destination offset

  xor esi, esi

.loop:
  cmp cx, BUFFER_SIZE
  jb .smaller_chunk

  mov si, BUFFER_SIZE
  jmp .load_buffer

.smaller_chunk:
  mov si, cx

.load_buffer:
  push si
  push BUFFER_OFFSET
  push BUFFER_SEGMENT
  push bx
  call read_disk
  add sp, 8

.copy_buffer:
  push si
  push dword BUFFER_ADDRESS
  push dword edx
  call copy_sectors
  add sp, 10

  add bx, BUFFER_SIZE     ; move sector number
  add edx, BUFFER_SIZE_B  ; and destination pointer

  sub cx, si              ; decrement remaining sectors to copy
  or cx, cx
  jnz .loop

  popad
  leave
  ret


; copy_sectors(uint32 destination, uint32 source, uint16 count)
;
; Copy `n` sectors from source in low memory to a destination in high memory
;
; Parameters:
;     - destination          [bp+4]
;     - source               [bp+8]
;     - number of sectors    [bp+12]
;

%define dest    [bp+4]
%define source  [bp+8]
%define count   [bp+12]

copy_sectors:
  enter 0, 0
  pushad

  mov eax, dword source   ; source
  mov ebx, dword dest     ; destination

  xor ecx, ecx
  mov cx, count           ; count

.loop:
  mov edx, ecx
  dec edx
  sal edx, 9        ; mult 512
  mov edi, edx

  add edx, eax      ; edx: source + count * 512
  add edi, ebx      ; edi: destination + count * 512

  push dword edx
  push dword edi
  call copy_sector
  add sp, 8
  loop .loop

  popad
  leave
  ret


; copy_sector(uint32 destination, uint32 source)
;
; Copy a sector from source in low memory to a destination in high memory
;
; Parameters:
;     - destination   [bp+4]
;     - source        [bp+8]
;

%define dest    [bp+4]
%define source  [bp+8]

copy_sector:
  enter 0, 0
  pushad

  mov ecx, 128

  mov eax, dword source
  mov ebx, dword dest

.loop:
  mov esi, ecx
  dec esi
  mov edx, [eax + esi * 4]
  mov [ebx + esi * 4], edx
  loop .loop

  popad
  leave
  ret
