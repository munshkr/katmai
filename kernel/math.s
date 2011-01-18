global log10, pow

; float log10(float number);

%define number ebp+8
%define result ebp-4

log10:
  enter 4, 0
  push ebx
  push esi
  push edi

  fld1
  fld dword [number]
  fyl2x
  fldl2t
  fdivp
  fst dword [result]
  mov eax, [result]

  pop edi
  pop esi
  pop ebx
  leave
  ret


; float pow(float base, float exponent);

%define exponent ebp+12
%define base ebp+8
%define result ebp-4

pow:
  enter 4, 0
  push ebx
  push esi
  push edi

  fld dword [exponent]
  fld dword [base]
  fyl2x
  fld st0
  frndint
  fsub st1,st0
  fxch st1
  f2xm1
  fld1
  faddp
  fscale
  fst dword [result]
  mov eax, [result]

  pop edi
  pop esi
  pop ebx
  leave
  ret
