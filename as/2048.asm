game_2048:
    addsp -8
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7
_2048_start_game:
    ; load game status from sd card to 0xb000 ~ 0xb0ff
    li r0, 2048
    li r1, 0xb000
    li r2, 1
    call sd_read
    nop
_2048_clear_graphic_memory:
    li r0, 0
    la r1, vga_control_base
    sw r1, r0, 3 ; turn off cursor
    la r1, graphics_base
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
    la r2, global_counter
    lw r2, r2, 0
    _2048_new_block_loop:
        li r3, 0xb000 ; load block status
        addu r1, r3, r3
        lw r3, r4, 0 ; status
        bnez r4, _2048_new_block_next
        nop
        addu r1, r2, r4
        li r5, 3
        and r4, r5
        bnez r4, _2048_new_block_next
        nop
        li r4, 1
        sw r3, r4, 0 
        _2048_new_block_next:
            addiu r1, 1
            cmpi r1, 16
            bteqz _2048_render
            nop
            b _2048_new_block_loop
            nop

_2048_render:
    li r0, 0
    _2048_draw_welcome:
        la r1, graphics_base
        li r2, 2240 ; 7 * 4 * 80
        addu r1, r2, r1
        la r2, _2048_welcome
        li r3, 0x0700
        li r4, 0
        _2048_draw_welcome_loop:
            cmpi r4, 21
            bteqz _2048_draw_help
            nop
            lw r2, r5, 0
            or r5, r3
            sw r1, r5, 0
            addiu r1, 1
            addiu r2, 1
            addiu r4, 1
            b _2048_draw_welcome_loop
            nop    
    _2048_draw_help:
        la r1, graphics_base
        li r2, 2320 ; 7 * 4 * 80
        addu r1, r2, r1
        la r2, _2048_help
        li r3, 0x0700
        li r4, 0
        _2048_draw_help_loop:
            cmpi r4, 71
            bteqz _2048_draw_block
            nop
            lw r2, r5, 0
            or r5, r3
            sw r1, r5, 0
            addiu r1, 1
            addiu r2, 1
            addiu r4, 1
            b _2048_draw_help_loop
            nop    
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
            la r3, graphics_base
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
            la r3, graphics_base
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
            la r3, graphics_base
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

_2048_new_game:
    li r1, 0 ; block id
    la r2, global_counter
    lw r2, r2, 0
    not r2, r2
    _2048_new_game_loop:
        li r3, 0xb000
        addu r1, r3, r3
        li r4, 0
        sw r3, r4, 0 
        li r4, 1
        sllv r1, r4
        move r5, r4
        and r4, r2
        cmp r4, r5
        bteqz _2048_new_game_next
        nop
        li r4, 1
        sw r3, r4, 0 
        _2048_new_game_next:
            addiu r1, 1
            cmpi r1, 16
            bteqz _2048_render
            nop
            b _2048_new_game_loop
            nop

_2048_get_command:
    call getchar
    nop
    cmpi r4, 'w' 
    bteqz _2048_up_relay
    nop 
    cmpi r4, 's' 
    bteqz _2048_down_relay 
    nop
    cmpi r4, 'a' 
    bteqz _2048_left_relay
    nop
    cmpi r4, 'd' 
    bteqz _2048_right_relay
    nop
    cmpi r4, 'q' 
    bteqz _2048_game_over_relay
    nop
    cmpi r4, 'n' 
    bteqz _2048_new_game
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
    ; save game status to sd card
    li r0, 2048
    li r1, 0xb000
    li r2, 1
    call sd_write
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
