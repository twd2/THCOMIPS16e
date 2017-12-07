b main
nop

.org 0x10
; internal interrupt handler
mfc0 r0, cause
mfc0 r1, epc
addiu r1, 1 ; skip syscall
mtc0 r1, epc
eret

.org 0x20
; external interrupt handler
mfc0 r0, cause
mfc0 r1, epc
eret

main:
    li r0, 0x0001
    mtc0 r0, status ; enable exception
    li r0, 0x11
    syscall 666
    li r0, 0x22

$:
    b $
    li r0, 0x33