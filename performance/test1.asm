; 性能标定
; 这段程序一般没有数据冲突和结构冲突，可作为性能标定。
; 结果：
; 6.006s @ 25.0000MHz, CPI=1.00
; 3.781s @ 40.0000MHz, CPI=1.01
; 3.594s @ 42.0000MHz, CPI=1.01

; *** 程序说明：R4、R5为循环变量   ***
; ***     主要循环体0x0D~0x12，6条 ***
; ***     每条各执行25,000,000次   ***
; ***     共1.50亿条指令           ***
; ***     （行号从0开始）          ***

LI R5 FF
NOP
NOP
NOP
SLL R5 R5 0
NOP
NOP
NOP
ADDIU R5 82
LI R4 60
NOP
NOP
NOP
ADDIU R4 1
LI R0 0
LI R1 1
LI R2 2
BNEZ R4 FB
NOP
ADDIU R5 1
NOP
NOP
NOP
BNEZ R5 F1
NOP
JR R7
NOP
