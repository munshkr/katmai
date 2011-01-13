global log10

; float log10(float number);

%define number ebp+4

log10:
  enter 0, 0
  push ebx
  push esi
  push edi

  fld [number]
  ; TODO ...

  pop edi
  pop esi
  pop ebx
  leave
