gets:
    addsp -8
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7
    li r7, 1 ; not done
    addsp -2
    sw_sp r0, 1 ; result addr (modified)
    sw_sp r0, 2 ; result addr (original)

    _gets_ps2_loop:
        beqz r7, _gets_done
        nop
        la r2, ps2_base
        li r3, 0x0001
        _gets_wait_ps2:
            lw r2, r4, 1 ; ps2 control
            and r4, r3
            beqz r4, _gets_wait_ps2
            nop
        lw r2, r0, 0 ; ps2 data

        ; is extend?
        li r1, 0xe0
        cmp r0, r1
        bteqz _gets_extend
        nop

        ; is break?
        li r1, 0xf0
        cmp r0, r1
        bteqz _gets_break
        nop

        ; ignore extend and break
        la r1, is_extend
        lw r1, r1, 0
        bnez r1, _gets_clear_flags
        nop
        la r1, is_break
        lw r1, r1, 0
        bnez r1, _gets_clear_flags
        nop

        ; keyboard 2 ascii
        la r1, ps2_scancode
        addu r0, r1, r0
        lw r0, r0, 0

    _gets_putchar:
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
        bteqz _gets_newline
        nop
        cmpi r0, 8 ; backspace
        bteqz _gets_backspace
        nop
        cmpi r0, 0 
        bteqz _gets_ps2_loop
        nop
        b _gets_char
        nop

    _gets_done:
        lw_sp r6, 1 ; result addr (modified)
        li r0, 0
        sw r6, r0, 0 ; '\0'
        addsp 2
        ; print last '\n'
        li r0, 10
        call putchar
        nop
        lwsp r0, 0
        lwsp r1, 1
        lwsp r2, 2
        lwsp r3, 3
        lwsp r4, 4
        lwsp r5, 5
        lwsp r6, 6
        lwsp r7, 7
        addsp 8
        ret
        nop

    _gets_extend:
        la r0, is_extend
        li r1, 1
        sw r0, r1, 0
        b _gets_ps2_loop
        nop

    _gets_break:
        la r0, is_break
        li r1, 1
        sw r0, r1, 0
        b _gets_ps2_loop
        nop

    _gets_backspace:
        lw_sp r5, 2 ; result addr (original)
        lw_sp r6, 1 ; result addr (modified)
        cmp r5, r6
        bteqz _gets_clear_flags ; cannot backspace
        nop
        li r5, 0
        sw r6, r5, 0 ; clear memory
        addiu r6, -1
        sw_sp r6, 1
        addiu r1, -1
        addiu r3, -1
        addu r1, r4, r6
        li r5, 0x0700
        sw r6, r5, 0 ; clear graphics memory
        b _gets_save
        nop

    _gets_clear_flags:
        ; clear flags
        la r0, is_extend
        li r1, 0
        sw r0, r1, 0
        la r0, is_break
        li r1, 0
        sw r0, r1, 0
        b _gets_ps2_loop
        nop

    _gets_newline: ; '\n'
        li r7, 0
        b _gets_save
        nop

    _gets_char:
        lw_sp r6, 1 ; result addr (modified)
        sw r6, r0, 0
        addiu r6, 1
        sw_sp r6, 1
        or r0, r5
        addu r1, r4, r6
        sw r6, r0, 0
        addiu r1, 1
        addiu r3, 1
        b _gets_save
        nop

    _gets_save:
        la r0, char_addr
        sw r0, r1, 0 ; cursor addr
        sll r2, r2, 8 ; row
        or r2, r3 ; pos
        la r0, vga_control_base ; vga control
        sw r0, r2, 2 ; cursor pos
        b _gets_clear_flags
        nop