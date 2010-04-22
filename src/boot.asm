; boot.asm
ORG 0x7c00
  ; set DS segment (just in case)
  xor ax, ax
  mov ds, ax

  ; print hello message
  mov si, msg
  call bios_print

  cli
hang:
  hlt
  jmp hang

;------------------------------------------------
bios_print:
  lodsb
  or al, al
  jz .done
  mov ah, 0xe
  int 0x10
  jmp bios_print
.done:
  ret

;------------------------------------------------
msg
  db "-=- NoxPgOS -=-", 10, 13
  db "Unfortunately, there is nothing to do here.", 10, 13
  db 0

times 510-($-$$) db 0
dw 0xaa55   ; boot sector signature
