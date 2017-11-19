start:
li r0, 0xbf00 ; uart base address
li r2, 0x0002

wait:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait_out
nop
b wait
nop
wait_out:

lw r0, r1, 0x00
sw r0, r1, 0x00

li r2, 0x0001
wait0:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait0_out
nop
b wait0
nop
wait0_out:

li r0, 0x05af
li r1, 0xfa50
sw r0, r1, 0x00
li r1, 0x05af
sw r0, r1, 0x01
li r1, 0x00
lw r0, r1, 0x00
lw r0, r1, 0x01

li r0, 0xbf00
li r2, 0x0001

li r1, 'h'
sw r0, r1, 0x00 ; data = r1
wait1:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait1_out
nop
b wait1
nop
wait1_out:

li r1, 'e'
sw r0, r1, 0x00 ; data = r1
wait2:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait2_out
nop
b wait2
nop
wait2_out:

li r1, 'l'
sw r0, r1, 0x00 ; data = r1
wait3:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait3_out
nop
b wait3
nop
wait3_out:

li r1, 'l'
sw r0, r1, 0x00 ; data = r1
wait4:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait4_out
nop
b wait4
nop
wait4_out:

li r1, 'o'
sw r0, r1, 0x00 ; data = r1
wait5:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait5_out
nop
b wait5
nop
wait5_out:

li r1, 44
sw r0, r1, 0x00 ; data = r1
wait6:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait6_out
nop
b wait6
nop
wait6_out:

li r1, 32
sw r0, r1, 0x00 ; data = r1
wait7:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait7_out
nop
b wait7
nop
wait7_out:

li r1, 'w'
sw r0, r1, 0x00 ; data = r1
wait8:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait8_out
nop
b wait8
nop
wait8_out:

li r1, 'o'
sw r0, r1, 0x00 ; data = r1
wait9:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait9_out
nop
b wait9
nop
wait9_out:

li r1, 'r'
sw r0, r1, 0x00 ; data = r1
wait10:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait10_out
nop
b wait10
nop
wait10_out:

li r1, 'l'
sw r0, r1, 0x00 ; data = r1
wait11:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait11_out
nop
b wait11
nop
wait11_out:

li r1, 'd'
sw r0, r1, 0x00 ; data = r1
wait12:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait12_out
nop
b wait12
nop
wait12_out:

li r1, 13
sw r0, r1, 0x00 ; data = r1
wait13:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait13_out
nop
b wait13
nop
wait13_out:

li r1, 10
sw r0, r1, 0x00 ; data = r1
wait14:
lw r0, r1, 0x01
and r1, r2
bnez r1, wait14_out
nop
b wait14
nop
wait14_out:

b start
nop