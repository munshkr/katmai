%include "kernel/common.mac"

%define ACPI_MASK 0x200

global check_cpuid
global check_apic

check_cpuid:
    PROLOGUE 0
    pushfd ; get
    pop eax
    mov ecx, eax ; save
    xor eax, 0x200000 ; flip
    push eax ; set
    popfd
    pushfd ; and test
    pop eax
    xor eax, ecx ; mask changed bits
    shr eax, 21 ; move bit 21 to bit 0
    and eax, 1 ; and mask others
    EPILOGUE
    ret

check_apic:
    PROLOGUE 0
    mov eax, 1              ; Parámetro para cpuid
    cpuid
    and edx, ACPI_MASK      ; Enmascaro el bit 9
    shr edx, 9
    mov eax, edx            ; Lo paso al bit 1 y de ahi a eax para resultado
    EPILOGUE
    ret
