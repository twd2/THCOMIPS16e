_bullet_screen_loop:
	li r0, gets_result
	call gets
	nop
	li r1, 3000 ; show time
	li r2, 0 ; pos
	_draw_bullet_pos_loop:
		addiu r2, 1
		li r3, 0 ; times
		_draw_bullet_time_loop:
			addiu r3, 1
			cmp r1, r3
			bteqz _draw_bullet_pos_loop
			nop
			li r4, gets_result ; char addr
			move r5, r2 ; char pos
			_draw_bullet_loop:
				la r6, graphics_base
				addiu r6, 160 ; 2 * 80
				addu r6 r5 r6
				lw r4, r7, 0
				cmpi r7, 0
				bteqz _draw_bullet_time_loop
				nop
				li r0, 0x0700
				or r7, r0
				sw r6, r7, 0
				addiu r4, 1
				addiu r5, 1
				cmpi r5, 80
				bteqz _bullet_screen_loop
				nop
				b _draw_bullet_loop
				nop
