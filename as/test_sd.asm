; init sd controller
li r0, 0xe008 ; SD controller base
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

; write 1 sector (512 bytes) to SD sector 2049 (1MB+512) from RAM 0x9000
li r1, 2049
sw r0, r1, 0 ; sector_base = 2049 (at 1MB+512)
li r1, 0x9000
sw r0, r1, 2 ; ram_base = 0x9000
li r1, 1
sw r0, r1, 4 ; sector_count = 1
li r1, 2 ; command write
sw r0, r1, 7 ; start write

li r2, 0x0001
wait_irq:
    lw r0, r1, 6
    move r3, r1
    and r3, r2
    beqz r3, wait_irq
    nop
sw r0, r1, 6 ; clear interrupt

; read 16 sector (4096 words) from SD sector 2048 (1MB) to RAM 0x4000
li r1, 2048
sw r0, r1, 0 ; sector_base = 2048 (at 1MB)
li r1, 0x4000
sw r0, r1, 2 ; ram_base = 0x4000
li r1, 16
sw r0, r1, 4 ; sector_count = 16
li r1, 1 ; command read
sw r0, r1, 7 ; start read

li r2, 0x0001
wait_irq2:
    lw r0, r1, 6
    move r3, r1
    and r3, r2
    beqz r3, wait_irq2
    nop
sw r0, r1, 6 ; clear interrupt

; copy 4096 words from 0x4000 to 0xf000 (graphics memory)
; because SD controller cannot access graphics memory directly
li r0, 0x4000
li r1, 0xf000 ; graphics memory base
li r2, 0x1000

memcpy_loop:
    lw r0, r3, 0x00
    sw r1, r3, 0x00
    addiu r0, 1
    addiu r1, 1
    addiu r2, -1
    bnez r2, memcpy_loop
    nop

$:
b $
nop