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

_2048_start_game: 
; load game status from sd card to 0xb000 - 0xb00f
li r0, 0xb000
li r1, 4
sw r0, r1, 0
li r1, 0
sw r0, r1, 1
li r1, 0
sw r0, r1, 2
li r1, 0
sw r0, r1, 3
li r1, 4
sw r0, r1, 4
li r1, 5
sw r0, r1, 5
li r1, 6
sw r0, r1, 6
li r1, 7
sw r0, r1, 7
li r1, 8
sw r0, r1, 8
li r1, 9
sw r0, r1, 9
li r1, 10
sw r0, r1, 10
li r1, 11
sw r0, r1, 11
li r1, 2
sw r0, r1, 12
li r1, 2
sw r0, r1, 13
li r1, 0
sw r0, r1, 14
li r1, 0
sw r0, r1, 15

_2048_clear_graphic_memory:
	li r0, 0
	li r1, 0xEFFC ; vga control
	sw r1, r0, 3 ; turn off cursor
	li r1, 0xf000 ; graphics memory base
	_2048_clear_loop:
		sw r1, r0, 0
		addiu r1, 1
		cmpi r1, -1 ; 0xffff
		bteqz _2048_render
		nop
		b _2048_clear_loop
		nop

_2048_new_block:
	li r1, 0 ; block id
	li r2, 0 ; blank_block_cnt
	_2048_new_block_loop:
		li r3, 0xb000 ; load block status
		addu r1, r3, r3
		lw r3, r4, 0 ; status
		bnez r4, _2048_new_block_next
		nop
		addiu r2, 1 ; blank_block_cnt++
		addu r1, r2, r4
		li r5, 3
		and r4, r5
		bnez r4, _2048_new_block_next
		nop
		li r4, 1
		sw r3, r4, 1 ; blank block -> Colin when (id + cnt) % 4 == 0
		_2048_new_block_next:
			addiu r1, 1
			cmpi r1, 16
			bteqz _2048_render
			nop
			b _2048_new_block_loop
			nop

_2048_render:
	li r0, 0
	_2048_draw_block:
		; r0 block id
		li r1, 0xb000 ; load block status
		addu r0, r1, r1
		lw r1, r1, 0
		beqz r1, _2048_calc_addr
		li r1, 0 ; slot
		li r1, 0x0700 ; r1: block color
		_2048_calc_addr:
			move r2, r0
			move r3, r0
			sra r2, r2, 2 ; r2: block row
			li r4, 3
			and r3, r4 ; r3: block col
			sll r4, r2, 3
			subu r4, r2, r2 ; r2 = r2 * 7
			sll r4, r3, 4
			sll r5, r3, 1
			subu r4, r5, r3 ; r3 = r3 * 14
			sll r4, r2, 6
			sll r5, r2, 4
			addu r4, r5, r2 ; r2 = r2 * 80
			addu r2, r3, r2 ; r2: addr
		_2048_draw_horizontal_line:
			li r3, 0xf000 ; graphics memory base
			li r4, 196
			or r4, r1
			li r5, 1
			_2048_draw_horizontal_line_loop:
				cmpi r5, 13
				bteqz _2048_draw_vertical_line
				nop
				addu r2, r5, r6
				addu r6, r3, r6 
				sw r6, r4, 0 ; draw up line
				li r7, 480 ; 6 * 80
				addu r6, r7, r6
				sw r6, r4, 0 ; draw down line 
				addiu r5, 1
				b _2048_draw_horizontal_line_loop
				nop
		_2048_draw_vertical_line:
			li r3, 0xf000 ; graphics memory base
			li r4, 179
			or r4, r1
			li r5, 80
			_2048_draw_vertical_line_loop:
				li r7, 480 ; 80 * 6
				cmp r5, r7
				bteqz _2048_draw_string
				nop
				addu r2, r5, r6
				addu r6, r3, r6 
				sw r6, r4, 0 ; draw left line
				sw r6, r4, 13 ; draw right line 
				addiu r5, 80
				b _2048_draw_vertical_line_loop
				nop		
		_2048_draw_string:
			li r3, 0xf000 ; graphics memory base
			la r4, _2048_block_name
			li r7, 0xb000 ; load block status
			addu r0, r7, r7
			lw r7, r7, 0
			sll r5, r7, 4
			sll r6, r7, 2
			subu r5, r6, r5 ; r5 = r7 * 12
			addu r4, r5, r4 ; r4: block name
			li r5, 241 ; 3 * 80 + 1
			addu r2, r5, r2
			addu r3, r2, r2
			li r5, 0
			_2048_draw_string_loop:
				cmpi r5, 12
				bteqz _2048_render_next_block
				nop
				lw r4, r6, 0
				or r6, r1
				sw r2, r6, 0
				addiu r5, 1
				addiu r4, 1
				addiu r2, 1
				b _2048_draw_string_loop
				nop
		_2048_render_next_block:
			addiu r0, 1
			cmpi r0, 16
			bteqz _2048_get_command
			nop
			b _2048_draw_block
			nop

_2048_get_command:
	call getchar
	nop
	cmpi r4, 'w' ; 'w'
	bteqz _2048_up_relay
	nop 
	cmpi r4, 's' ; 's'
	bteqz _2048_down_relay 
	nop
	cmpi r4, 'a' ; 'a'
	bteqz _2048_left_relay
	nop
	cmpi r4, 'd' ; 'd'
	bteqz _2048_right_relay
	nop
	cmpi r4, 'q' ; 'q'
	bteqz _2048_game_over_relay
	nop
	b _2048_get_command
	nop
	_2048_up_relay:
		b _2048_up
		nop
	_2048_down_relay:
		b _2048_down
		nop
	_2048_left_relay:
		b _2048_left
		nop
	_2048_right_relay:
		b _2048_right
		nop
	_2048_game_over_relay:
		b _2048_game_over
		nop


_2048_left:
	li r0, 0 ; block id
	_2048_left_loop:
		li r1, 0xb000 ; load block status
		addu r0, r1, r2
		lw r2, r1, 0 ; status
		beqz r1, _2048_left_next_block
		li r3, 0
		sw r2, r3, 0 ; clear origin status
		move r2, r0 ; next_id
		_2048_left_next_loop:
			addiu r2, -1
			li r3, 3
			and r3, r2
			cmpi r3, 3
			bteqz _2048_left_move
			nop
			li r3, 0xb000 ; load block status
			addu r2, r3, r3
			lw r3, r3, 0 ; next status
			beqz r3, _2048_left_next_loop
			nop
			cmp r3, r1
			bteqz _2048_left_merge
			nop
		_2048_left_move:
			addiu r2, 1 ; next id
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			sw r3, r1, 0 ; move block
			b _2048_left_next_block
			nop
		_2048_left_merge:
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			addiu r1, 1
			sw r3, r1, 0 ; move block
		_2048_left_next_block:
			addiu r0, 1
			cmpi r0, 16
			bteqz _2048_left_new_block_relay
			nop
			b _2048_left_loop
			nop
		_2048_left_new_block_relay:
			b _2048_new_block
			nop

_2048_right:
	li r0, 15 ; block id
	_2048_right_loop:
		li r1, 0xb000 ; load block status
		addu r0, r1, r2
		lw r2, r1, 0 ; status
		beqz r1, _2048_right_next_block
		li r3, 0
		sw r2, r3, 0 ; clear origin status
		move r2, r0 ; next_id
		_2048_right_next_loop:
			addiu r2, 1
			li r3, 3
			and r3, r2
			beqz r3, _2048_right_move
			nop
			li r3, 0xb000 ; load block status
			addu r2, r3, r3
			lw r3, r3, 0 ; next status
			beqz r3, _2048_right_next_loop
			nop
			cmp r3, r1
			bteqz _2048_right_merge
			nop
		_2048_right_move:
			addiu r2, -1 ; next id
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			sw r3, r1, 0 ; move block
			b _2048_right_next_block
			nop
		_2048_right_merge:
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			addiu r1, 1
			sw r3, r1, 0 ; move block
		_2048_right_next_block:
			addiu r0, -1
			cmpi r0, -1
			bteqz _2048_right_new_block_relay
			nop
			b _2048_right_loop
			nop
		_2048_right_new_block_relay:
			b _2048_new_block
			nop


_2048_up:
	li r0, 0 ; block id
	_2048_up_loop:
		li r1, 0xb000 ; load block status
		addu r0, r1, r2
		lw r2, r1, 0 ; status
		beqz r1, _2048_up_next_block
		li r3, 0
		sw r2, r3, 0 ; clear origin status
		move r2, r0 ; next_id
		_2048_up_next_loop:
			addiu r2, -4
			li r3, 16
			and r3, r2
			cmpi r3, 16
			bteqz _2048_up_move
			nop
			li r3, 0xb000 ; load block status
			addu r2, r3, r3
			lw r3, r3, 0 ; next status
			beqz r3, _2048_up_next_loop
			nop
			cmp r3, r1
			bteqz _2048_up_merge
			nop
		_2048_up_move:
			addiu r2, 4 ; next id
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			sw r3, r1, 0 ; move block
			b _2048_up_next_block
			nop
		_2048_up_merge:
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			addiu r1, 1
			sw r3, r1, 0 ; move block
		_2048_up_next_block:
			addiu r0, 1
			cmpi r0, 16
			bteqz _2048_up_new_block_relay
			nop
			b _2048_up_loop
			nop
		_2048_up_new_block_relay:
			b _2048_new_block
			nop


_2048_down:
	li r0, 15 ; block id
	_2048_down_loop:
		li r1, 0xb000 ; load block status
		addu r0, r1, r2
		lw r2, r1, 0 ; status
		beqz r1, _2048_down_next_block
		li r3, 0
		sw r2, r3, 0 ; clear origin status
		move r2, r0 ; next_id
		_2048_down_next_loop:
			addiu r2, 4
			li r3, 16
			and r3, r2
			cmpi r3, 16
			bteqz _2048_down_move
			nop
			li r3, 0xb000 ; load block status
			addu r2, r3, r3
			lw r3, r3, 0 ; next status
			beqz r3, _2048_down_next_loop
			nop
			cmp r3, r1
			bteqz _2048_down_merge
			nop
		_2048_down_move:
			addiu r2, -4 ; next id
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			sw r3, r1, 0 ; move block
			b _2048_down_next_block
			nop
		_2048_down_merge:
			li r3, 0xb000 
			addu r3, r2, r3 ; next addr
			addiu r1, 1
			sw r3, r1, 0 ; move block
		_2048_down_next_block:
			addiu r0, -1
			cmpi r0, -1
			bteqz _2048_down_new_block_relay
			nop
			b _2048_down_loop
			nop
		_2048_down_new_block_relay:
			b _2048_new_block
			nop


_2048_game_over:
; store game status to sd card
	$:
		b $
		nop

; global variables
.extern ps2_base, 0xe002
.extern ctrl_pressed, 0xc000
.extern alt_pressed, 0xc001
.extern shift_pressed, 0xc002
.extern is_extend, 0xc003
.extern is_break, 0xc004
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

_2048_block_name:
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 'C'
.word 'o'
.word 'l'
.word 'i'
.word 'n'
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 'b'
.word 'i'
.word 'l'
.word 'l'
.word '1'
.word '2'
.word '5'
.word 32
.word 32
.word 32

.word 32
.word 32
.word 'l'
.word 'a'
.word 'z'
.word 'y'
.word 'c'
.word 'a'
.word 'l'
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word 't'
.word 'w'
.word 'd'
.word '2'
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 'f'
.word 's'
.word 'y'
.word 'g'
.word 'd'
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word 'w'
.word 'u'
.word 'h'
.word 'z'
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word 'Y'
.word 'Y'
.word 'F'
.word 32
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word '1'
.word '2'
.word '8'
.word 32
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word '2'
.word '5'
.word '6'
.word 32
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word '5'
.word '1'
.word '2'
.word 32
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word '1'
.word '0'
.word '2'
.word '4'
.word 32
.word 32
.word 32
.word 32

.word 32
.word 32
.word 32
.word 32
.word 'l'
.word 's'
.word 's'
.word 32
.word 32
.word 32
.word 32
.word 32


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
