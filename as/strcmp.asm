; compare r0 and r1, result is in r4
strcmp:
    addsp -5
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r5, 4
    li r4, 0
    _strcmp_loop:
        lw r0, r2, 0
        lw r1, r3, 0
        move r5, r2
        or r5, r3
        beqz r5, _strcmp_break ; *r0 == 0 || *r1 == 0
        cmp r2, r3 ; bd
        bteqz _strcmp_char_eq
        nop
        ; *r0 != *r1
        b _strcmp_end
        li r4, 1 ; bd
        _strcmp_char_eq:
        addiu r0, 1
        addiu r1, 1
        b _strcmp_loop
        nop
    _strcmp_break:
        bteqz _strcmp_end ; *r0 == 0 && *r1 == 0
        nop
        li r4, 1
    _strcmp_end:
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r5, 4
    addsp 5
    ret
    nop