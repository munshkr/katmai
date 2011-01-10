;
; mmap.s ~ Memory map detection subroutines
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

;; ----------------------------------------
;; Relleno para entender el mapa de memoria
;
;  mov ecx, 50
;  mov di, 0x8000
;
;.relleno:
;  cmp ecx, 0
;  je .fin
;  mov dword [es:di], 0xFFFFFFFF
;  dec ecx
;  add di, 4
;  xchg bx, bx
;  jmp .relleno
;
;.fin:
;
;; ----------------------------------------

MMAP_ADDRESS equ 0x500

%define mmap_entries [bp-2]

make_mmap:
  enter 2, 0
  pushad

  mov di, MMAP_ADDRESS    ; Init
  xor ebx, ebx            ;

  mov edx, 0x534d4150     ;
  xor eax, eax            ;
  mov eax, 0xe820         ; INT_0x15 EAX_0xE820 Setup & Call
  mov ecx, 24             ;
  int 0x15                ;

  jc .failed              ;
  mov edx, 0x534d4150     ;
  cmp eax, edx            ;
  jne .failed             ; Error check
  cmp ebx, 0              ;
  je .failed              ;
  jmp .sucess             ;

.ignore:
.loop:
  cmp ebx, 0              ;
  je .end                 ; Check for finish

  mov edx, 0x534d4150     ;
  xor eax, eax            ;
  mov eax, 0xe820         ; INT_0x15 EAX_0xE820 Setup & Call
  mov ecx, 24             ;
  int 0x15                ;

  jc .failed              ;
  mov edx, 0x534d4150     ;
  cmp eax, edx            ; Status check
  jne .failed             ;
  jmp .sucess             ;

.failed:
  popad
  xor eax, eax

  leave
  ret

.sucess:
  mov ecx, [es:di + 8]    ;
  or ecx, [es:di + 12]    ; If the length of the entry is zero, ignore it
  jz .ignore              ;

  add di, 24

  mov dx, mmap_entries    ;
  inc dx                  ; Otherwise, increment and keep on maping
  mov mmap_entries, dx    ;

  jmp .loop

.end:
  popad
  mov eax, mmap_entries

  leave
  ret
