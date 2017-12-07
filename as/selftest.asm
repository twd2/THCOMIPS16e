selftest:
    addsp -1
    swsp r7, 0

    la r0, gpio_base
    li r1, 0x0000 ; out
    sw r0, r1, 1 ; gpio control

    li r1, 0b1111110011111100 ; 00
    sw r0, r1, 0 ; gpio data

_test_1:
    la r0, self_test_prefix
    call puts
    nop
    
    li r0, '1'
    call putchar
    nop
    
    la r0, self_test_suffix
    call puts
    nop

    la r0, gpio_base
    li r1, 0b1111110001100000 ; 01
    sw r0, r1, 0 ; gpio data
    
    ; test 1
    ; memory write and read
    ; 0x7000 ~ 0xbeff
    li r0, 0x7000
    li r1, 0xbeff
_test_1_write_loop:
    cmp r0, r1
    bteqz _test_1_write_done
    sw r0, r0, 0 ; bd
    b _test_1_write_loop
    addiu r0, 1 ; bd
_test_1_write_done:

    li r0, 0x7000
_test_1_read_loop:
    lw r0, r2, 0
    subu r0, r2, r2
    bnez r2, _selftest_failed ; if *r0 != r0
    cmp r0, r1 ; bd
    bteqz _test_1_read_done
    nop
    b _test_1_read_loop
    addiu r0, 1 ; bd

_test_1_read_done:

    call put_ok
    nop

    la r0, self_test_passed
    call puts
    nop

_test_2:
    la r0, self_test_prefix
    call puts
    nop
    
    li r0, '2'
    call putchar
    nop
    
    la r0, self_test_suffix
    call puts
    nop

    la r0, gpio_base
    li r1, 0b1111110011011010 ; 02
    sw r0, r1, 0 ; gpio data

    ; test 2
    ; memory write, read and bnez
    ; 0x7000 ~ 0xbeff
    li r0, 0x7000
    li r1, 0xbeff
    li r3, 0x0000
    li r4, 0xffff
_test_2_loop:
    li r2, 0xffff
    sw r0, r3, 0
    sw r0, r4, -1
    lw r0, r2, 0
    bnez r2, _selftest_failed
    cmp r0, r1 ; bd
    bteqz _test_2_done
    nop
    b _test_2_loop
    addiu r0, 1 ; bd
_test_2_done:

    call put_ok
    nop

    la r0, self_test_passed
    call puts
    nop

    la r0, gpio_base
    li r1, 0x0000 ; out
    sw r0, r1, 1 ; gpio control

    li r1, 0x0000 ; off
    sw r0, r1, 0 ; gpio data

    lwsp r7, 0
    addsp 1
    ret
    nop

_selftest_failed:
    move r1, r0 ; save r1
    call put_fail
    nop
    la r0, self_test_failed
    call puts
    nop
_selftest_failed_loop:
    b _selftest_failed_loop
    addiu r1, 0 ; bd