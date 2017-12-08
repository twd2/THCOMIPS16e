.org 0x2b0

; VGA
.extern vga_control_base, 0xeffc
.extern graphics_base, 0xf000

; PS/2
.extern ps2_base, 0xe002
.extern ps2_data, 0xe002
.extern ps2_control, 0xe003

; GPIO
.extern gpio_base, 0xe000
.extern gpio_data, 0xe000
.extern gpio_direction, 0xe001

; SD
.extern sd_base, 0xe008

; Timer
.extern timer_base, 0xe004
.extern timer_reserved, 0xe004
.extern timer_control, 0xe005

; global variables
.extern ctrl_pressed, 0xc000
.extern alt_pressed, 0xc001
.extern shift_pressed, 0xc002
.extern is_extend, 0xc003
.extern is_break, 0xc004
.extern char_addr, 0xc005
.extern global_counter, 0xc006
.extern gets_result, 0xc007
.extern uptime_counter, 0xc008
.extern danmuku_cnt, 0xc009
.extern danmuku_pos, 0xc00a
.extern danmuku_read_done, 0xc00b
.extern danmuku_read_cnt, 0xc00c
.extern danmuku_addr, 0xc00d ; size=80
.extern is_in_badapple, 0xc05d

; stack
.extern stack_base, 0xe000