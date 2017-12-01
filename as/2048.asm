_2048_start_game: 
; load game status from sd card to 0xb000 - 0xb00f
li r0, 0xb000
li r1, 0
sw r0, r1, 0
li r1, 1
sw r0, r1, 1
li r1, 2
sw r0, r1, 2
li r1, 3
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
li r1, 12
sw r0, r1, 12
li r1, 13
sw r0, r1, 13
li r1, 14
sw r0, r1, 14
li r1, 15
sw r0, r1, 15

addsp -32

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
				bteqz _2048_next_block
				nop
				lw r4, r6, 0
				or r6, r1
				sw r2, r6, 0
				addiu r5, 1
				addiu r4, 1
				addiu r2, 1
				b _2048_draw_string_loop
				nop
		_2048_next_block:
			addiu r0, 1
			cmpi r0, 16
			bteqz _2048_get_command
			nop
			b _2048_draw_block
			nop



_2048_get_command:
	$:
		b $
		nop

_2048_left:

_2048_right:

_2048_up:

_2048_down:

_2048_new_block:

_2048_game_over:
; store game status to sd card

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
