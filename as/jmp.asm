.org 0x0000
b init
nop

.org 0x0010 ; internal exception handler
b syscall_handler
nop

.org 0x0020 ; external exception handler
    addsp -9
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7
    bteqz _external_exception_handler_t_eq_z
    li r0, 0 ; bd
    li r0, 1
_external_exception_handler_t_eq_z:
    swsp r0, 8 ; save T
    la r6, timer_interrupt_handler
    jr r6
    nop
