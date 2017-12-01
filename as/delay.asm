delay:
    push r0
    push r1
    li r1, 1000
_delay_outer_loop:
    li r0, 1000
_delay_inner_loop:
    addiu r0, -1
    bnez r0, _delay_inner_loop
    nop
    addiu r1, -1
    bnez r1, _delay_outer_loop
    nop
    pop r1
    pop r0
    ret
    nop