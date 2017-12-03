selftest:
    addsp -1
    swsp r7, 0

    la r0, self_test_prefix
    call puts
    nop
    
    li r0, '1'
    call putchar
    nop
    
    la r0, self_test_suffix
    call puts
    nop
    
    ; test 1
    ; memory read and write
    ; 0x7000 ~ 0xbeff
    li r0, 0x7000
    li r1, 0xbeff
_test_1_loop:
    cmp r0, r1
    bteqz _test_1_done
    sw r0, r0, 0 ; bd
    b _test_1_loop
    addiu r0, 1 ; bd
_test_1_done:
    la r0, self_test_passed
    call puts
    nop

    lwsp r7, 0
    addsp 1
    ret
    nop

_selftest_failed:
    la r0, self_test_failed
    call puts
    nop
_selftest_failed_loop:
    b _selftest_failed_loop
    nop