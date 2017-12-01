; VGA
.extern vga_control_base, 0xeffc
.extern graphics_base, 0xf000

; PS/2
.extern ps2_base, 0xe002
.extern ps2_data, 0xe002
.extern ps2_control, 0xe003

; global variables
.extern ctrl_pressed, 0xc000
.extern alt_pressed, 0xc001
.extern shift_pressed, 0xc002
.extern is_extend, 0xc003
.extern is_break, 0xc004
.extern char_addr, 0xc005

; stack
.extern stack_base 0xe000
; initialize stack
la r0, stack_base
mtsp r0

; initialize global variables
li r0, 0x0000
la r4, ctrl_pressed
sw r4, r0, 0
la r4, alt_pressed
sw r4, r0, 0
la r4, shift_pressed
sw r4, r0, 0
la r4, is_extend
sw r4, r0, 0
la r4, is_break
sw r4, r0, 0
la r4, char_addr
sw r4, r0, 0

call clear_screen
nop
la r0, boot_message
call puts
nop

shell_loop:
    la r0, prompt
    call puts
    nop
    li r0, 0xb000 ; temp buffer
    call gets
    nop
    call puts
    nop
    li r0, 10
    call putchar
    nop
    b shell_loop
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
    swsp r0, 1
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
delay:
    push r0
    push r1
    li r1, 1000
_delay_outer_loop:
    li r0, 1000
_delay_inner_loop:
    addiu r0, -1
    bnez r0, _delay_inner_loop
    nop
    addiu r1, -1
    bnez r1, _delay_outer_loop
    nop
    pop r1
    pop r0
    ret
    nop
hello_world:
.word 'h'
.word 'e'
.word 'l'
.word 'l'
.word 'o'
.word 44
.word 32
.word 'w'
.word 'o'
.word 'r'
.word 'l'
.word 'd'
.word 10
.word 0

prompt:
.word 's'
.word 'h'
.word '#'
.word 32
.word 0

boot_message:
.word 'S'
.word 'y'
.word 's'
.word 't'
.word 'e'
.word 'm'
.word 32
.word 'b'
.word 'o'
.word 'o'
.word 't'
.word 'e'
.word 'd'
.word 32
.word 's'
.word 'u'
.word 'c'
.word 'c'
.word 'e'
.word 's'
.word 's'
.word 'f'
.word 'u'
.word 'l'
.word 'l'
.word 'y'
.word '!'
.word 10
.word 10
.word 'T'
.word 'H'
.word 'C'
.word 'O'
.word 32
.word 'M'
.word 'I'
.word 'P'
.word 'S'
.word '1'
.word '6'
.word 'e'
.word 32
.word '['
.word 'v'
.word 'e'
.word 'r'
.word 's'
.word 'i'
.word 'o'
.word 'n'
.word 32
.word '0'
.word '.'
.word '0'
.word '.'
.word '0'
.word ']'
.word 10
.word 32
.word 32
.word 32
.word 32
.word 'b'
.word 'y'
.word 32
.word 't'
.word 'w'
.word 'd'
.word '2'
.word 32
.word 'a'
.word 'n'
.word 'd'
.word 32
.word 'C'
.word 'o'
.word 'l'
.word 'i'
.word 'n'
.word 10
.word 10
.word 0

ps2_scancode:
; scancode lookup table
; 128 items
; usage:
; la r0, ps2_scancode
; addu r1, r0, r0
; lw r1, r1, 0
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x09
.word 0x60
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x71
.word 0x31
.word 0x00
.word 0x01
.word 0x02
.word 0x7A
.word 0x73
.word 0x61
.word 0x77
.word 0x32
.word 0x00
.word 0x00
.word 0x63
.word 0x78
.word 0x64
.word 0x65
.word 0x34
.word 0x33
.word 0x00
.word 0x00
.word 0x20
.word 0x76
.word 0x66
.word 0x74
.word 0x72
.word 0x35
.word 0x00
.word 0x00
.word 0x6E
.word 0x62
.word 0x68
.word 0x67
.word 0x79
.word 0x36
.word 0x00
.word 0x00
.word 0x00
.word 0x6D
.word 0x6A
.word 0x75
.word 0x37
.word 0x38
.word 0x00
.word 0x00
.word 0x2C
.word 0x6B
.word 0x69
.word 0x6F
.word 0x30
.word 0x39
.word 0x00
.word 0x00
.word 0x2E
.word 0x2F
.word 0x6C
.word 0x3B
.word 0x70
.word 0x2D
.word 0x00
.word 0x00
.word 0x00
.word 0x27
.word 0x00
.word 0x5B
.word 0x3D
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x0A
.word 0x5D
.word 0x00
.word 0x5C
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x06
.word 0x07
.word 0x08
.word 0x00
.word 0x00
.word 0x31
.word 0x00
.word 0x34
.word 0x37
.word 0x00
.word 0x00
.word 0x00
.word 0x30
.word 0x2E
.word 0x32
.word 0x35
.word 0x36
.word 0x38
.word 0x00
.word 0x00
.word 0x00
.word 0x2B
.word 0x33
.word 0x2D
.word 0x2A
.word 0x39
.word 0x00
.word 0x00

