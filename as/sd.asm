sd_init:
    addsp -2
    swsp r0, 0
    swsp r1, 1
    la r0, sd_base ; SD controller base
    li r1, 0x0000
    sw r0, r1, 0 ; sector_base
    sw r0, r1, 1 ; sector_base hi
    sw r0, r1, 2 ; ram_base
    sw r0, r1, 3 ; ram_base hi
    sw r0, r1, 4 ; sector_count
    sw r0, r1, 5 ; sector_count hi
    li r1, 0x0001
    sw r0, r1, 6 ; interrupt control
    ; 0xe008 + 7 is command register
    lwsp r0, 0
    lwsp r1, 1
    addsp 2
    ret
    nop

; r0: sector, r1: ram, r2: sector count
sd_write:
    addsp -2
    swsp r3, 0
    swsp r7, 1
    call sd_command
    li r3, 2 ; bd, command: write
    lwsp r3, 0
    lwsp r7, 1
    addsp 2
    ret
    nop

; r0: sector, r1: ram, r2: sector count
sd_read:
    addsp -2
    swsp r3, 0
    swsp r7, 1
    call sd_command
    li r3, 1 ; bd, command: read
    lwsp r3, 0
    lwsp r7, 1
    addsp 2
    ret
    nop

; r0: sector, r1: ram, r2: sector count, r3: command
sd_command:
    addsp -4
    swsp r1, 0
    swsp r2, 1
    swsp r3, 2
    swsp r4, 3
    la r4, sd_base ; SD controller base
    sw r4, r0, 0 ; sector_base
    sw r4, r1, 2 ; ram_base
    sw r4, r2, 4 ; sector_count
    li r0, 0
    sw r4, r0, 1 ; sector_base hi
    sw r4, r0, 3 ; ram_base hi
    sw r4, r0, 5 ; sector_count hi
    sw r4, r3, 7 ; start command

    li r2, 0x0001 ; interrupt bit
    _sd_wait_irq:
        lw r4, r1, 6
        move r3, r1
        and r3, r2
        beqz r3, _sd_wait_irq
        nop
    sw r4, r1, 6 ; clear interrupt

    lwsp r1, 0
    lwsp r2, 1
    lwsp r3, 2
    lwsp r4, 3
    addsp 4
    ret
    nop

sd_memdump:
    addsp -5
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r7, 4
    li r0, 4096
    li r1, 0
    li r2, 256 ; 2 bytes/word * 64K words / 512 bytes/sector
    call sd_command
    li r3, 2 ; bd, command: write
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r7, 4
    addsp 5
    ret
    nop