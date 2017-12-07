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
    b _print_hex_out_hex
    addiu r0, 0x30 ; bd

_print_hex_is_hex:
    addiu r0, 0x37 ; r0 += 'A' - 0x0A
_print_hex_out_hex:
    call putchar
    nop
    lwsp r0, 0
    lwsp r7, 1
    addsp 2
    ret
    nop

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
    ret
    nop

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
    sra r0, r0, 4
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
    ret
    nop

; to hex, r0
to_hex:
    addsp -1
    swsp r1, 0
    li r1, 0x0a
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    li r1, 0x0b ; bd
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    li r1, 0x0c ; bd
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    li r1, 0x0d ; bd
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    li r1, 0x0e ; bd
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    li r1, 0x0f ; bd
    subu r0, r1, r1
    beqz r1, _to_hex_is_hex
    nop

    ; 0~9
    b _to_hex_out_hex
    addiu r0, 0x30 ; bd

_to_hex_is_hex:
    addiu r0, 0x37 ; r0 += 'A' - 0x0A
_to_hex_out_hex:
    lwsp r1, 0
    addsp 1
    ret
    nop