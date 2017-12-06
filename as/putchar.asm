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
    la r4, vga_control_base ; vga control
    lw r4, r3, 2 ; cursor pos
    move r2, r3
    sra r2, r2, 8
    li r4, 0xFF
    and r2, r4 ; cursor row
    and r3, r4 ; cursor col

    la r4, graphics_base ; graphics memory base
    li r5, 0x0700 ; color

    cmpi r0, 10 ; '\n'
    bteqz _putchar_newline
    nop
    cmpi r0, 13 ; '\r'
    bteqz _putchar_enter
    nop
    b _putchar_char
    nop

    _putchar_newline: ; '\n'
    subu r1, r3, r1
    addiu r1, 80
    addiu r2, 1
    li r3, 0
    cmpi r2, 30 
    bteqz _putchar_scroll
    nop
    b _putchar_save
    nop

    _putchar_enter: ; '\r'
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
    la r0, vga_control_base ; vga control
    sw r0, r2, 2 ; cursor pos

_putchar_out:
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

clear_screen:
    addsp -2
    swsp r0, 0
    swsp r1, 1
    la r0, graphics_base
    li r1, 0x0700
    _clear_screen_loop:
        cmpi r0, -1 ; r0 = 0xffff?
        bteqz _clear_screen_out
        sw r0, r1, 0x00 ; bd
        b _clear_screen_loop
        addiu r0, 1 ; bd
    _clear_screen_out:
    li r0, 0x0000
    la r1, char_addr
    sw r1, r0, 0
    la r1, vga_control_base
    sw r1, r0, 2 ; pos
    li r0, 29
    sw r1, r0, 3 ; cursor counter limit
    lwsp r0, 0
    lwsp r1, 1
    addsp 2
    ret
    nop

; print a string stored at *r0 ending with '\0'
puts:
    addsp -3
    swsp r0, 0
    swsp r1, 1
    swsp r7, 2
    move r1, r0
_puts_loop:
    lw r1, r0, 0
    beqz r0, _puts_out
    nop
    call putchar
    nop
    ; call delay
    ; nop
    b _puts_loop
    addiu r1, 1 ; bd, next char
_puts_out:
    lwsp r0, 0
    lwsp r1, 1
    lwsp r7, 2
    addsp 3
    ret
    nop

; print [OK], right aligned
put_ok:
    addsp -2
    swsp r0, 0
    swsp r1, 1
    la r1, vga_control_base ; vga control
    lw r1, r1, 2 ; cursor pos
    li r0, 0xFF
    and r1, r0 ; cursor col
    la r0, char_addr
    lw r0, r0, 0 ; cursor addr
    addiu r0, 80 ; next line + col
    subu r0, r1, r0 ; r0 = next line
    li r1, 0x0741 ; TODO
    sw r0, r1, -4
    li r1, 0x0741 ; TODO
    sw r0, r1, -3
    li r1, 0x0741 ; TODO
    sw r0, r1, -2
    li r1, 0x0741 ; TODO
    sw r0, r1, -1
    lwsp r0, 0
    lwsp r1, 1
    addsp 2
    ret
    nop