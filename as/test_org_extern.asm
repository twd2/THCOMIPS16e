.org 0x4000
.extern putchar, 0xffff

la r0, putchar
jalr r7, r0
nop

$:
b $
nop