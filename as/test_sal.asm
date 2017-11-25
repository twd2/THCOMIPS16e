li r0, 0x8000
li r1, 0x05af
sw r0, r1, 0x00 ; init

; test
li r3, 0x0000
li r2, 0x0000
; store after load
lw r0, r2, 0x00
sw r0, r2, 0x01

lw r0, r3, 0x01
addiu r3, 0

li r3, 0xfa50
lw r0, r2, 0x00
sw r0, r3, 0x02
lw r0, r3, 0x02
addiu r3, 0

$:
b $
nop