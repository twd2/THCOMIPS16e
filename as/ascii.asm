; R1, R2, R3, R7: callee saved
; R6: caller saved

start:
    ADDSP -2
    SW_SP R6 0x01 ; push R6
    SW_SP R7 0x00 ; push R7
    
    LI R2 0x1F
    LI R3 0x7E
    
print_loop:
    ADDIU R2 0x01 ; ++R2
    
    LI R1 0x30 ; '0'
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP
    
    LI R1 0x78 ; 'x'
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP

    MFPC R7
    ADDIU R7 0x03
    B print_byte
    NOP
    
    LI R1 0x20 ; ' '
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP

    ADDIU3 R2 R1 0x00 ; R1 = R2
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP
    
    LI R1 0x0A ; '\n'
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP
    
    CMP R2 R3
    BTEQZ out
    NOP
    
    B print_loop
    NOP
    
out:
    
    LW_SP R7 0x00 ; pop R7
    LW_SP R6 0x01 ; pop R6
    ADDSP 0x02
    JR R7
    NOP

; print char, arg = R1
print_char:
    LI R6 0xBF
    SLL R6 R6 8 ; R6 = 0xBF00
    LI R5 0x01
    
; wait for serial
wait_loop:
    LW R6 R0 0x01
    AND R0 R5
    BEQZ R0 wait_loop ; *BF01 & 1 == 0 则等待
    NOP
    
    SW R6 R1 0x00 ; *BF00 = R1
    
    JR R7
    NOP

; print byte, arg = R2
print_byte:
    ADDSP -1
    SW_SP R7 0x00 ; push R7

    ; high half-byte
    SRA R1 R2 0x04 ; R1 = R2 >> 4
    MFPC R7
    ADDIU R7 0x03
    B print_hex
    NOP
    
    ; low half-byte
    ADDIU3 R2 R1 0x00
    LI R6 0x0F
    AND R1 R6 ; R1 = R2 & 0x0F
    MFPC R7
    ADDIU R7 0x03
    B print_hex
    NOP

    LW_SP R7 0x00 ; pop R7
    ADDSP 0x01
    JR R7
    NOP

; print hex, arg = R1
print_hex:
    ADDSP -1
    SW_SP R7 0x00 ; push R7
    
    LI R6 0x0A
    CMP R1 R6
    BTEQZ is_hex
    LI R6 0x0B
    CMP R1 R6
    BTEQZ is_hex
    LI R6 0x0C
    CMP R1 R6
    BTEQZ is_hex
    LI R6 0x0D
    CMP R1 R6
    BTEQZ is_hex
    LI R6 0x0E
    CMP R1 R6
    BTEQZ is_hex
    LI R6 0x0F
    CMP R1 R6
    BTEQZ is_hex
    NOP
    ADDIU R1 0x30 ; R1 += '0'
    B out_hex
    NOP
is_hex:
    ADDIU R1 0x37 ; R1 += 'A' - 0x0A
out_hex:
    
    MFPC R7
    ADDIU R7 0x03
    B print_char
    NOP
    
    LW_SP R7 0x00 ; pop R7
    ADDSP 0x01
    JR R7
    NOP