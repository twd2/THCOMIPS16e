getchar:
	addsp -4
	swsp r0, 0
	swsp r1, 1
	swsp r2, 2
	swsp r3, 3
	la r2, ps2_base
	li r3, 0x0001
	_getchar_ps2_loop:
		_getchar_wait_ps2:
            la r0, global_counter
            lw r0, r1, 0
            addiu r1, 1
            sw r0, r1, 0
			lw r2, r4, 1 ; ps2 control
			and r4, r3
			beqz r4, _getchar_wait_ps2
			nop
		lw r2, r0, 0 ; ps2 data

		; is extend?
		li r1, 0xe0
		cmp r0, r1
		bteqz _getchar_extend
		nop

		; is break?
		li r1, 0xf0
		cmp r0, r1
		bteqz _getchar_break
		nop

		; ignore extend and break
		la r1, is_extend
		lw r1, r1, 0
		bnez r1, _getchar_clear_flags
		nop
		la r1, is_break
		lw r1, r1, 0
		bnez r1, _getchar_clear_flags
		nop

		; keyboard 2 ascii
		la r1, ps2_scancode
		addu r0, r1, r0
		lw r0, r4, 0

_getchar_done:
	lwsp r0, 0
	lwsp r1, 1
	lwsp r2, 2
	lwsp r3, 3
	addsp 4
	ret
	nop

_getchar_extend:
	li r4, 0
	la r0, is_extend
	li r1, 1
	sw r0, r1, 0
	b _getchar_done
	nop

_getchar_break:
	li r4, 0
	la r0, is_break
	li r1, 1
	sw r0, r1, 0
	b _getchar_done
	nop

_getchar_clear_flags:
	li r4, 0
	; clear flags
	la r0, is_extend
	li r1, 0
	sw r0, r1, 0
	la r0, is_break
	li r1, 0
	sw r0, r1, 0
	b _getchar_done
	nop
