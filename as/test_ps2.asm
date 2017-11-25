li r0, 0xf000 ; graphics memory base
li r1, 0x0700 ; color
li r2, 'h'
or r2, r1
sw r0, r2, 0x00
lw r0, r2, 0x00
li r2, 'e'
or r2, r1
sw r0, r2, 0x01
lw r0, r2, 0x01
li r2, 'l'
or r2, r1
sw r0, r2, 0x02
lw r0, r2, 0x02
li r2, 'l'
or r2, r1
sw r0, r2, 0x03
lw r0, r2, 0x03
li r2, 'o'
or r2, r1
sw r0, r2, 0x04
lw r0, r2, 0x04
li r2, 44
or r2, r1
sw r0, r2, 0x05
lw r0, r2, 0x05
li r2, 32
or r2, r1
sw r0, r2, 0x06
lw r0, r2, 0x06
li r2, 'w'
or r2, r1
sw r0, r2, 0x07
lw r0, r2, 0x07
li r2, 'o'
or r2, r1
sw r0, r2, 0x08
lw r0, r2, 0x08
li r2, 'r'
or r2, r1
sw r0, r2, 0x09
lw r0, r2, 0x09
li r2, 'l'
or r2, r1
sw r0, r2, 0x0A
lw r0, r2, 0x0A
li r2, 'd'
or r2, r1
sw r0, r2, 0x0B
lw r0, r2, 0x0B

;li r2, 22
;or r2, r1
;sw r0, r2, 0x0C

addiu r0, 0x0C ; r0 = 0xf00c
loop:
    cmpi r0, -1 ; r0 = 0xffff?
    bteqz out
    sw r0, r1, 0x00 ; bd
    b loop
    addiu r0, 1 ; bd

out:

li r0, 0xEFFC ; vga control
li r1, 0x0000
sw r0, r1, 0 ; base addr
sw r0, r1, 1 ; base addr hi
li r1, 29
sw r0, r1, 3 ; cursor_counter_limit
li r1, 0x000c
sw r0, r1, 2 ; cursor pos

; PS/2

li r0, 0xf00c
li r1, 0x0700 ; color
li r2, 0xe002 ; ps2 base
li r3, 0x0001
ps2_loop:
    wait_ps2:
        lw r2, r4, 0x01 ; ps2 control
        and r4, r3
        beqz r4, wait_ps2
        nop
    lw r2, r4, 0x00 ; ps2 data
    or r4, r1
    sw r0, r4, 0x00
    b ps2_loop
    addiu r0, 1
