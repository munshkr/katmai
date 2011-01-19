;
; math.s ~ Math functions with FPU
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

%include "kernel/x86.mac"

global log10, pow


; float log10(float number);

%define number ebp+8
%define result ebp-4

log10:
  PROLOGUE 4

  fld1
  fld dword [number]
  fyl2x
  fldl2t
  fdivp st0
  fst dword [result]
  mov eax, [result]

  EPILOGUE
  ret


; float pow(float base, float exponent);

%define exponent  ebp+12
%define base      ebp+8
%define result    ebp-4

pow:
  PROLOGUE 4

  fld dword [exponent]
  fld dword [base]
  fyl2x
  fld st0
  frndint
  fsub st1,st0
  fxch st1
  f2xm1
  fld1
  faddp st0
  fscale
  fst dword [result]
  mov eax, [result]

  EPILOGUE
  ret
