danmuku:
    addsp -8
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7

    la r0, danmuku_read_done
    lw r0, r0, 0
    bnez r0, _danmuku_draw
    nop

_danmuku_gets:
    la r0, ps2_base
    lw r0, r0, 1
    li r1, 0x0001
    and r0, r1
    beqz r0, _danmuku_done
    nop
    la r6, getchar
    jalr r7, r6
    nop

    la r6, gpio_data
    sw r6, r4, 0

    la r0, danmuku_read_cnt
    la r1, danmuku_addr
    lw r0, r2, 0 ; r2 cnt
    addu r1, r2, r1
    cmpi r4, 0x1B ; ESC 
    bteqz _danmuku_exit_badapple
    nop
    sw r1, r4, 0 ; save char
    cmpi r4, 0
    bteqz _danmuku_done
    nop
    addiu r2, 1 ; cnt++
    sw r0, r2, 0 ; save cnt
    cmpi r4, 10 ; '\n' 
    bteqz _danmuku_read_done
    nop
    b _danmuku_done
    nop

_danmuku_read_done:
    la r0, danmuku_read_done    
    li r1, 1
    sw r0, r1, 0 ; read_done = 1
    la r0, danmuku_cnt    
    li r1, 0
    sw r0, r1, 0 ; cnt = 0
    la r0, danmuku_pos    
    li r1, 0
    sw r0, r1, 0 ; pos = 0
    b _danmuku_done
    nop

_danmuku_draw:
    la r0, danmuku_cnt
    lw r0, r1, 0 ; r1 cnt
    addiu r1, 1 ; cnt++
    sw r0, r1, 0 ; save cnt
    cmpi r1, 20 ; cnt == 30
    bteqz _danmuku_new_pos
    nop
    la r0, danmuku_addr
    la r1, danmuku_pos
    lw r1, r1, 0
    li r2, 0x0700 ; color
    li r3, 0
    lw r0, r4, 0 ; char
    cmpi r4, 10
    bteqz _danmuku_new_danmu ; is empty string
    nop
    _danmuku_draw_loop:
        addu r0, r3, r4
        lw r4, r4, 0 ; char
        cmpi r4, 10
        bteqz _danmuku_done
        nop
        or r4, r2
        la r5, graphics_base
        addiu r5, 80
        addiu r5, 80 ; 2 * 80
        addu r5, r1, r5 ; += pos
        addu r5, r3, r5
        sw r5, r4, 0
        addiu r3, 1
        b _danmuku_draw_loop
        nop

_danmuku_new_pos:
    la r0, danmuku_cnt
    li r1, 0 ; cnt = 0
    sw r0, r1, 0 ; save cnt
    la r0, danmuku_pos
    lw r0, r1, 0 ; r1 pos
    addiu r1, 1 ; pos++
    sw r0, r1, 0 ; save pos
    cmpi r1, 70
    bteqz _danmuku_new_danmu
    nop
    b _danmuku_done
    nop

_danmuku_new_danmu:
    la r0, danmuku_read_done    
    li r1, 0
    sw r0, r1, 0 ; read_done = 0
    la r0, danmuku_read_cnt    
    sw r0, r1, 0 ; cnt = 0

_danmuku_done:
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

_danmuku_exit_badapple:
    la r0, is_in_badapple
    li r1, 0
    b _danmuku_done
    sw r0, r1, 0 ; bd