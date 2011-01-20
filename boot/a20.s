;
; a20.s ~ Enable A20 line (adapted from Visopsys OS-loader)
;
; Copyright (c) 2000, J. Andrew McLaughlin
; You're free to use this code in any manner you like, as long as this
; notice is included (and you give credit where it is due), and as long
; as you understand and accept that it comes with NO WARRANTY OF ANY KIND.
; Contact me at jamesamc@yahoo.com about any bugs or problems.
;


m_a20_fail  db "Failed to enable A20 line! Halted.", 13, 10, 0
m_a20_warn  db "Used non-standard method for enabling A20 line.", 13, 10, 0

enable_a20:
    ; This routine will enable the A20 address line in the keyboard
    ; controller.  It will halt processor on failure.

    enter 0, 0
    pushad

    cli       ; Make sure interrupts are disabled

    ; Keep a counter so that we can make up to 5 attempts to turn
    ; on A20 if necessary
    mov cx, 5

    .startAttempt1:
    ; Wait for the controller to be ready for a command
    .commandWait1:
    xor ax, ax
    in al, 64h
    bt ax, 1
    jc .commandWait1

    ; Tell the controller we want to read the current status.
    ; Send the command d0h: read output port.
    mov al, 0d0h
    out 64h, al

    ; Wait for the controller to be ready with a byte of data
    .dataWait1:
    xor ax, ax
    in al, 64h
    bt ax, 0
    jnc .dataWait1

    ; Read the current port status from port 60h
    xor ax, ax
    in al, 60h

    ; Save the current value of AX
    push ax

    ; Wait for the controller to be ready for a command
    .commandWait2:
    in al, 64h
    bt ax, 1
    jc .commandWait2

    ; Tell the controller we want to write the status byte again
    mov al, 0d1h
    out 64h, al

    ; Wait for the controller to be ready for the data
    .commandWait3:
    xor ax, ax
    in al, 64h
    bt ax, 1
    jc .commandWait3

    ; Write the new value to port 60h.  Remember we saved the old
    ; value on the stack
    pop ax

    ; Turn on the A20 enable bit
    or al, 00000010b
    out 60h, al

    ; Finally, we will attempt to read back the A20 status
    ; to ensure it was enabled.

    ; Wait for the controller to be ready for a command
    .commandWait4:
    xor ax, ax
    in al, 64h
    bt ax, 1
    jc .commandWait4

    ; Send the command D0h: read output port.
    mov al, 0d0h
    out 64h, al

    ; Wait for the controller to be ready with a byte of data
    .dataWait2:
    xor ax, ax
    in al, 64h
    bt ax, 0
    jnc .dataWait2

    ; Read the current port status from port 60h
    xor ax, ax
    in al, 60h

    ; Is A20 enabled?
    bt ax, 1

    ; Check the result.  If carry is on, A20 is on.
    jc .success

    ; Should we retry the operation?  If the counter value in CX
    ; has not reached zero, we will retry
    loop .startAttempt1


    ; Well, our initial attempt to set A20 has failed.  Now we will
    ; try a backup method (which is supposedly not supported on many
    ; chipsets, but which seems to be the only method that works on
    ; other chipsets).


    ; Keep a counter so that we can make up to 5 attempts to turn
    ; on A20 if necessary
    mov cx, 5

    .startAttempt2:
    ; Wait for the keyboard to be ready for another command
    .commandWait6:
    xor ax, ax
    in al, 64h
    bt ax, 1
    jc .commandWait6

    ; Tell the controller we want to turn on A20
    mov al, 0dfh
    out 64h, al

    ; Again, we will attempt to read back the A20 status
    ; to ensure it was enabled.

    ; Wait for the controller to be ready for a command
    .commandWait7:
    xor ax, ax
    in al, 64h
    bt ax, 1
    jc .commandWait7

    ; Send the command d0h: read output port.
    mov al, 0d0h
    out 64h, al

    ; Wait for the controller to be ready with a byte of data
    .dataWait3:
    xor ax, ax
    in al, 64h
    bt ax, 0
    jnc .dataWait3

    ; Read the current port status from port 60h
    xor ax, ax
    in al, 60h

    ; Is A20 enabled?
    bt ax, 1

    ; Check the result.  If carry is on, A20 is on, but we might warn
    ; that we had to use this alternate method
    jc .warn

    ; Should we retry the operation?  If the counter value in Ecx
    ; has not reached zero, we will retry
    loop .startAttempt2


    ; OK, we weren't able to set the A20 address line.  Halt!
    PRINT m_a20_fail
    hlt

    .warn:
    ; Here you may or may not want to print a warning message about
    ; the fact that we had to use the nonstandard alternate enabling
    ; method
    PRINT m_a20_warn

    .success:
    sti     ; Enable interrupts

    popad
    leave
    ret
