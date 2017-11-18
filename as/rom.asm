start:
li r0, 0xbeef
li r1, 0xbeef
cmp r0, r1
bteqz next
nop
b start
nop
next:
li r2, 0xcafe
cmp r2, r1
bteqz start
nop
loop:
b loop
nop