timer_interrupt_handler:
    ; uptime_counter += 1
    la r0, uptime_counter
    lw r0, r1, 0
    addiu r1, 1
    sw r0, r1, 0

    ; show uptime
    la r2, graphics_base
    addiu r2, 80

    ; Uptime: 0x????
    li r4, 0x0700

    li r0, 'U'
    or r0, r4
    sw r2, r0, -14
    li r0, 'p'
    or r0, r4
    sw r2, r0, -13
    li r0, 't'
    or r0, r4
    sw r2, r0, -12
    li r0, 'i'
    or r0, r4
    sw r2, r0, -11
    li r0, 'm'
    or r0, r4
    sw r2, r0, -10
    li r0, 'e'
    or r0, r4
    sw r2, r0, -9
    li r0, 58
    or r0, r4
    sw r2, r0, -8
    li r0, 32
    or r0, r4
    sw r2, r0, -7
    li r0, '0'
    or r0, r4
    sw r2, r0, -6
    li r0, 'x'
    or r0, r4
    sw r2, r0, -5

    li r3, 0xf
    move r0, r1
    sra r0, r0, 8
    sra r0, r0, 4
    and r0, r3
    call to_hex
    nop
    or r0, r4
    sw r2, r0, -4

    move r0, r1
    sra r0, r0, 8
    and r0, r3
    call to_hex
    nop
    or r0, r4
    sw r2, r0, -3

    move r0, r1
    sra r0, r0, 4
    and r0, r3
    call to_hex
    nop
    or r0, r4
    sw r2, r0, -2

    move r0, r1
    and r0, r3
    call to_hex
    nop
    or r0, r4
    sw r2, r0, -1

    la r0, is_in_badapple
    lw r0, r0, 0
    beqz r0, _timer_skip_danmuku
    nop

    call danmuku
    nop

_timer_skip_danmuku:

    ; clear timer interrupt bit
    la r0, timer_base
    lw r0, r7, 1 ; control
    sw r0, r7, 1 ; clear interrupt

    lwsp r0, 8
    cmpi r0, 0 ; restore T

    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r4, 4
    lwsp r5, 5
    lwsp r6, 6
    lwsp r7, 7
    addsp 9
    eret