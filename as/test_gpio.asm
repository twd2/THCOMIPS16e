li r0, 0xe000 ; gpio base
mtsp r0

li r1, 0x0000
sw r0, r1, 0x01 ; gpio direction = output

loop:
    sw r0, r1, 0x00 ; gpio output = r1
    addiu r1, 1
    call delay
    nop
    b loop
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