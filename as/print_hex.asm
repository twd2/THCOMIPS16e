; print hex, r0
print_hex:
    addsp -2
    swsp r0, 0
    swsp r7, 1
    cmpi r0, 0x0a
    bteqz _print_hex_is_hex
    cmpi r0, 0x0b ; bd
    bteqz _print_hex_is_hex
    cmpi r0, 0x0c ; bd
    bteqz _print_hex_is_hex
    cmpi r0, 0x0d ; bd
    bteqz _print_hex_is_hex
    cmpi r0, 0x0e ; bd
    bteqz _print_hex_is_hex
    cmpi r0, 0x0f ; bd
    bteqz _print_hex_is_hex
    nop

    ; 0~9
    addiu r0, 0x30
    b _print_hex_out_hex
    nop

_print_hex_is_hex:
    addiu r0, 0x37 ; r0 += 'A' - 0x0A
_print_hex_out_hex:
    call putchar
    nop
    lwsp r0, 0
    lwsp r7, 1
    addsp 2

; print byte r0
print_byte:
    addsp -4
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r7, 3
    move r1, r0
    li r2, 0xf
    sra r0, r1, 4
    and r0, r2
    call print_hex
    nop
    move r0, r1
    and r0, r2
    call print_hex
    nop
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r7, 3
    addsp 4

; print word r0
print_word:
    addsp -4
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r7, 3
    move r1, r0
    li r2, 0xf
    sra r0, r1, 8
    sra r0, r1, 4
    and r0, r2
    call print_hex
    nop
    sra r0, r1, 8
    and r0, r2
    call print_hex
    nop
    sra r0, r1, 4
    and r0, r2
    call print_hex
    nop
    move r0, r1
    and r0, r2
    call print_hex
    nop
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r7, 3
    addsp 4