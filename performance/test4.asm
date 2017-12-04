; 访存数据冲突性能测试

; 结果：
; 6.006s @ 25.0000MHz, CPI=1.00
; failed @ 100.000MHz, CPI=----

; *** 程序说明：R4、R5为循环变量   ***
; ***     主要循环体0x07~0x0C，6条 ***
; ***     每条各执行25,000,000次   ***
; ***     共1.50亿条指令           ***

; --------------------------------------------
; |冲突：(8)LW后(9)SW
; |　　　(8)LW后(B)BNEZ
; |　　　(A)LW后延迟槽内(C)ADDIU
; |　　　延迟槽内(C)ADDIU后(7)SW
; --------------------------------------------

LI R2 FF
LI R3 C0
SLL R3 R3 0
LI R5 FF
SLL R5 R5 0
ADDIU R5 83
LI R1 61
SW R3 R1 2
LW R3 R4 2
SW R3 R4 1
LW R3 R1 1
BNEZ R4 FB
ADDIU R1 1
BNEZ R5 F8
ADDIU R5 1
JR R7
NOP
