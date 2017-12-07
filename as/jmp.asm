.org 0x0000
b init
nop

.org 0x10 ; internal exception
b syscall_handler
nop

.org 0x20 ; external exception
    addsp -8
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7
    la r6, timer_interrupt_handler
    jr r6
    nop