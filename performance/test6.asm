; 访存数据冲突+控制冲突性能测试

; 结果：
; 6.001s @ 25.0000MHz, CPI=1.20
; 3.767s @ 40.0000MHz, CPI=1.21

; *** 程序说明：R4、R5为循环变量   ***
; ***     主要循环体0x07~0x0B，5条 ***
; ***     每条各执行25,000,000次   ***
; ***     共1.25亿条指令           ***

; LW 后紧跟 BNEZ。

LI R2 FF
LI R3 C0
SLL R3 R3 0
LI R5 FF
SLL R5 R5 0
ADDIU R5 83
LI R1 61
SW R3 R1 2
SW R3 R5 1
LW R3 R4 2
BNEZ R4 FC
ADDIU R1 1
BNEZ R5 F9
ADDIU R5 1
JR R7
NOP
