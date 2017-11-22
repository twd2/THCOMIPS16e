li r0, 0xe000
mtsp r0

; start
li r3, 's'
call putchar
nop
li r3, 't'
call putchar
nop
li r3, 'a'
call putchar
nop
li r3, 'r'
call putchar
nop
li r3, 't'
call putchar
nop
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop

$:
    b $
    nop

putchar:
    push r7
    push r6
    push r0
    li r0, 0xbf00
    li r7, 0x0001
    sw r0, r3, 0x00
wait_loop:
    lw r0, r6, 0x01
    and r6, r7
    beqz r6, wait_loop
    nop
    pop r0
    pop r6
    pop r7
    ret
    nop