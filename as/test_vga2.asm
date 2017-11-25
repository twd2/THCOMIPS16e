li r4, 0x8000
li r5, 0x1000

memcpy:
    move r0, r4
    li r1, 0xf000 ; graphics memory base
    li r2, 0x1000

    memcpy_loop:
        lw r0, r3, 0x00
        sw r1, r3, 0x00
        addiu r0, 1
        addiu r1, 1
        addiu r2, -1
        bnez r2, memcpy_loop
        nop

    addu r4, r5, r4
    call delay
    nop
    b memcpy
    nop

delay:
    push r7
    push r6
    li r7, 1000
delay_outer_loop:
    li r6, 1000
delay_inner_loop:
    addiu r6 -1
    bnez r6, delay_inner_loop
    nop
    addiu r7 -1
    bnez r7, delay_outer_loop
    nop
    pop r6
    pop r7
    ret
    nop