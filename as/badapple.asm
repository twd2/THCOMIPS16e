.extern badapple_buffer, 0x9000

badapple:
    addsp -8
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6
    swsp r7, 7
    li r0, 0 ; frame counter
    la r5, vga_control_base
    sw r5, r0, 3 ; turn off cursor
    la r5, sd_base ; SD controller base
_badapple_play_loop:
    li r1, 6560 ; 6560 frames totally
    cmp r0, r1
    bteqz _badapple_done
    
    ; load current frame from SD card
    ; 16 sectors per frame
    sll r1, r0, 4 ; r1 = (r0 * 16) % 65536
    sw r5, r1, 0 ; sector_base
    sra r1, r0, 8
    sra r1, r1, 4 
    li r2, 0xf
    and r1, r2 ; r1 = (r0 * 16) / 65536 = r0 / 4096
    addiu r1, 1 ; 64K sectors (32MiB) offset
    sw r5, r1, 1 ; sector_base hi
    la r1, badapple_buffer
    sw r5, r1, 2 ; ram_base
    li r1, 0
    sw r5, r1, 3 ; ram_base hi
    li r1, 16 ; 4K words = 16 sectors
    sw r5, r1, 4 ; sector_count
    li r1, 0
    sw r5, r1, 5 ; sector_count hi
    li r1, 1 ; command: read
    sw r5, r1, 7 ; start command
    
    ; wait for SD controller
    li r2, 0x0001 ; interrupt bit
    _badapple_wait_irq:
        lw r5, r1, 6
        move r3, r1
        and r3, r2
        ; check PS/2 here to quit
        la r6, ps2_base
        lw r6, r6, 1
        li r7, 0x0001
        and r6, r7
        beqz r6, _badapple_wait_continue
        nop
        call getchar
        nop
        cmpi r4, 'q'
        bteqz _badapple_done
        nop
    _badapple_wait_continue:
        beqz r3, _badapple_wait_irq
        nop
    sw r5, r1, 6 ; clear interrupt bit
    
    ; copy badapple_buffer to graphics_base
    la r1, badapple_buffer
    la r2, graphics_base
    _badapple_memcpy_loop:
        lw r1, r3, 0x00
        sw r2, r3, 0x00
        cmpi r2, -1 ; 0xffff
        bteqz _badapple_memcpy_done
        addiu r1, 1 ; bd
        b _badapple_memcpy_loop
        addiu r2, 1 ; bd
    _badapple_memcpy_done:
    
    ; magic delay!
    _badapple_delay:
        li r2, 2
    _badapple_delay_outer_loop:
        li r1, 60553
    _badapple_delay_inner_loop:
        addiu r1, -1
        bnez r1, _badapple_delay_inner_loop
        nop
        addiu r2, -1
        bnez r2, _badapple_delay_outer_loop
        nop

    b _badapple_play_loop
    addiu r0, 1 ; bd

_badapple_done:
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
