; .org 0x0000
; copy r1 ~ r1 + r0 to r2 ~ r2 + r0

mfpc r0

li r1, 0xe000
mtsp r1

li r2, 0x4001
cmp r0, r2
bteqz b_ok ; is copied code
nop

b start
nop

b_ok:
b ok
nop

start:

;b memcpy
;nop

; start
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop
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

memcpy:

li r0, 0x1000 ; 4K
li r1, 0x0000
li r2, 0x4000
loop:
    lw r1, r3, 0x00
    sw r2, r3, 0x00 ; *r2 = *r1
    addiu r1, 1
    addiu r2, 1
    addiu r0, -1
    bnez r0, loop
    nop

li r3, 13
call putchar
nop
li r3, 10
call putchar
nop
li r3, 'j'
call putchar
nop
li r3, 'u'
call putchar
nop
li r3, 'm'
call putchar
nop
li r3, 'p'
call putchar
nop
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop

;b $
;nop

jump:

li r2, 0x4000
jr r2
nop

failed:
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop
li r3, 'f'
call putchar
nop
li r3, 'a'
call putchar
nop
li r3, 'i'
call putchar
nop
li r3, 'l'
call putchar
nop
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop

b $
nop

ok:
li r3, 13
call putchar
nop
li r3, 10
call putchar
nop
li r3, 'o'
call putchar
nop
li r3, 'k'
call putchar
nop
li r3, 'O'
call putchar
nop
li r3, 'K'
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
