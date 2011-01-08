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

; FIXME change address (0x8000 steps over stage2.bin)
mmap_entries: dw 0
mmap_addr:    dw 0x8000

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

make_mmap:
  pusha
  xor ebp, ebp                  ;
  mov di, [mmap_addr]           ; Init
  xor ebx, ebx                  ;

  mov edx, 0x534D4150           ;
  xor eax, eax                  ;
  mov eax, 0xE820               ; INT_0x15 EAX_0xE820 Setup & Call
  mov ecx, 24                   ;
  int 0x15                      ;

  jc .failed                    ;
  mov edx, 0x534D4150           ;
  cmp eax, edx                  ;
  jne .failed                   ; Error check
  cmp ebx, 0                    ;
  je .failed                    ;
  jmp .sucess                   ;

.ignore:
.loop:
  cmp ebx, 0                    ;
  je .end                       ; Check for finish

  mov edx, 0x534D4150           ;
  xor eax, eax                  ;
  mov eax, 0xE820               ; INT_0x15 EAX_0xE820 Setup & Call
  mov ecx, 24                   ;
  int 0x15                      ;

  jc .failed                    ;
  mov edx, 0x534D4150           ;
  cmp eax, edx                  ; Status check
  jne .failed                   ;
  jmp .sucess                   ;

.failed:
  xchg bx, bx
  mov dword [mmap_entries], 0
  popa
  ret

.sucess:
  mov ecx, [es:di + 8]          ;
  or ecx, [es:di + 12]          ; If the length of the entry is zero, ignore it
  jz .ignore                    ;

  add di, 24                    ;
  inc ebp                       ; Otherwise, increment and keep on maping
  jmp .loop                     ;

.end:
  mov dword [mmap_entries], ebp
  popa
  ret

