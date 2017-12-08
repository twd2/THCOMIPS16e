_danmuku:
    la r0, danmuku_read_done
    lw r0, r0, 0
    cmpi r0, 1 ; read_done = 1
    bteqz _damuku_draw
    nop

_danmuku_gets:
    la r0, ps2_base
    lw r0, r0, 1
    li r1, 0x0001
    and r0, r1
    beqz r0, _danmuku_done
    nop
    call getchar
    nop
    la r0, danmuku_read_cnt
    la r1, danmuku_addr
    lw, r0, r2, 0 ; r2 cnt
    addu r1, r2, r1
    sw r1, r4, 0 ; save char
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
    cmpi r1, 30 ; cnt == 30
    bteqz _danmuku_new_pos
    nop
    la r0, danmuku_addr
    la r1, danmuku_pos
    li r2, 0x0700 ; color
    li r3, 0
    _danmuku_draw_loop:
        addu r0, r3, r4
        lw r4, r4, 0 ; char
        cmpi r4, 10
        bteqz _danmuku_done
        nop
        or r4, r2
        la r5, graphics_base
        addiu r5, 160 ; 2 * 80
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
    eret