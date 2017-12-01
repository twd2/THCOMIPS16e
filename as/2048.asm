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
	li r1, 0xe002 ; ps2 base
	li r2, 0x0001
	_2048_gets_wait_ps2:
		lw r1, r0, 0x01 ; ps2 control
		and r0, r2
		beqz r0, _2048_gets_wait_ps2
		nop
	lw r1, r0, 0x00 ; ps2 data
	cmpi r0, 0x1D ; 'w'
	bteqz _2048_up_relay
	nop 
	cmpi r0, 0x1B ; 's'
	bteqz _2048_down_relay 
	nop
	cmpi r0, 0x1C ; 'a'
	bteqz _2048_left_relay
	nop
	cmpi r0, 0x23 ; 'd'
	bteqz _2048_right_relay
	nop
	cmpi r0, 0x15 ; 'q'
	bteqz _2048_game_over_relay
	nop
	b _2048_get_command
	nop
	_2048_up_relay:
		li r1, _2048_up
		jr r1
		nop
	_2048_down_relay:
		li r1, _2048_down
		jr r1
		nop
	_2048_left_relay:
		li r1, _2048_left
		jr r1
		nop
	_2048_right_relay:
		li r1, _2048_right
		jr r1
		nop
	_2048_game_over_relay:
		li r1, _2048_game_over
		jr r1
		nop


_2048_left:
	li r0, 1 ; block id
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
			cmpi r2, -1
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
			addiu r0, 4
			move r1, r0
			cmpi r1, 17
			bteqz _2048_left_loop
			li r0, 2 ; slot
			cmpi r1, 18
			bteqz _2048_left_loop
			li r0, 3 ; slot
			cmpi r1, 19
			bteqz _2048_left_new_block_relay ; FIXME: ImmOutOfRangeError: -164
			li r0, 0 ; slot
			move r0, r1
			b _2048_left_loop
			nop
		_2048_left_new_block_relay:
			li r1, _2048_new_block
			jr r1
			nop

_2048_right:

_2048_up:

_2048_down:

_2048_game_over:
; store game status to sd card
	$:
		b $
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
