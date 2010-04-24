; === FAT12 header ===
; 3 1/2 floppy, 1.44MB, 18 sectors per track

db "NoxPgOS", 0  ; OEM Identifier
dw 512           ; Bytes per sector
db 1             ; Sectors per cluster
dw 1             ; Reserved sectors (only bootsector)
db 2             ; Number of FATs
dw 512           ; Root entries
dw 2880          ; Number of sectors
db f0h           ; Media descriptor
dw 9             ; Sectors per FAT
dw 18            ; Sectors per track
dw 2             ; Heads per cylinder (double sided)
dd 0             ; Hidden sectors
  
drive db 0          ; Used to store boot device
