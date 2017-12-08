init:

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
la r4, uptime_counter
sw r4, r0, 0
la r4, danmuku_cnt
sw r4, r0, 0
la r4, danmuku_pos
sw r4, r0, 0
la r4, danmuku_read_done
sw r4, r0, 0
la r4, danmuku_read_cnt
sw r4, r0, 0
la r4, danmuku_addr
sw r4, r0, 0
la r4, is_in_badapple
sw r4, r0, 0

call clear_screen
nop