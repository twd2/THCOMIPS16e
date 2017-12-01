.extern char_addr, 0xc005

li r0, 0xe000
mtsp r0

clear_screen:
li r0, 0xf000
li r1, 0x0700
_clear_screen_loop:
    cmpi r0, -1 ; r0 = 0xffff?
    bteqz _clear_screen_out
    sw r0, r1, 0x00 ; bd
    b _clear_screen_loop
    addiu r0, 1 ; bd
_clear_screen_out:

li r0, 0x0000
la r4, char_addr
sw r4, r0, 0

li r0, 'a'
call putchar
nop
li r0, 'b'
call putchar
nop
li r0, 'c'
call putchar
nop
li r0, 10
call putchar
nop
li r0, 'd'
call putchar
nop
li r0, 'e'
call putchar
nop

li r0, 'g'
li r1, 0
loop:
    cmpi r1, 127
    bteqz out
    nop
    call putchar
    nop
    b loop
    addiu r1, 1 ; bd
out:

li r0, 10
li r1, 0
loop2:
    cmpi r1, 28
    bteqz out2
    nop
    call putchar
    nop
    b loop2
    addiu r1, 1 ; bd
out2:

li r0, 'g'
call putchar
nop

li r0, 'g'
call putchar
nop

li r0, 'f'
li r1, 0
loop3:
    cmpi r1, 127
    bteqz out3
    nop
    call putchar
    nop
    b loop3
    addiu r1, 1 ; bd
out3:

$:
b $
nop

putchar:
    addsp -7
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6

    ; r0 data
    la r4, char_addr
    lw r4, r1, 0 ; cursor addr
    li r4, 0xEFFC ; vga control
    lw r4, r3, 2 ; cursor pos
    move r2, r3
    sra r2, r2, 8
    li r4, 0xFF
    and r2, r4 ; cursor row
    and r3, r4 ; cursor col
    li r4, 0xf000 ; graphics memory base
    li r5, 0x0700 ; color

    cmpi r0, 10 ; \n
    bteqz _putchar_newline
    nop
    cmpi r0, 13 ; \r
    bteqz _putchar_enter
    nop
    b _putchar_char
    nop

    _putchar_newline: ;\n
    subu r1, r3, r1
    addiu r1, 80
    addiu r2, 1
    li r3, 0
    cmpi r2, 30 
    bteqz _putchar_scroll
    nop
    b _putchar_save
    nop

    _putchar_enter: ;\r
    subu r1, r3, r1
    li r3, 0
    b _putchar_save
    nop

    _putchar_char:
    or r0, r5
    addu r1, r4, r6
    sw r6, r0, 0
    addiu r1, 1
    addiu r3, 1
    cmpi r3, 80 
    bteqz _putchar_nextline
    nop
    b _putchar_save
    nop
    _putchar_nextline:
    addiu r2, 1
    li r3, 0
    cmpi r2, 30 
    bteqz _putchar_scroll
    nop
    b _putchar_save
    nop

    _putchar_scroll:
    addiu r1, -80
    addiu r2, -1
    move r5, r4
        _putchar_loop:
        cmpi r5, -81 ; r5 + 80 <= 0xffff
        bteqz _putchar_save
        nop
        addiu r5, 80
        lw r5, r6, 0
        addiu r5, -80
        sw r5, r6, 0
        addiu r5, 1
        b _putchar_loop
        nop

    _putchar_save:
    la r0, char_addr
    sw r0, r1, 0 ; cursor addr
    sll r2, r2, 8 ; row
    or r2, r3 ; pos
    li r0, 0xEFFC ; vga control
    sw r0, r2, 2 ; cursor pos

    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r4, 4
    lwsp r5, 5
    lwsp r6, 6
    addsp 7
    ret
    nop