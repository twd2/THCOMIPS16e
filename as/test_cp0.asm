mfc0 r0, 2
li r0, 0x55aa
mtc0 r0, 2

; test CP0 hazard
mfc0 r1, 2
mfc0 r2, 2
mfc0 r3, 2
mfc0 r4, 2
; test mfc0 hazard
move r5, r4
move r6, r4
move r0, r4
move r1, r4

$:
b $
nop