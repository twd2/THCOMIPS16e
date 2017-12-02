b main
nop
NOP

;保存用户程序寄存器的地址 
;0xBF10  0xBF11 BF12 0xBF13 BF14 0xBF15
; R0    R1   R2   R3   R4   R5  

B START
NOP

DELINT:   ;中断处理程序
	NOP
	NOP
	NOP
	;保存用户程序现场
	LI R6 0xBF
	SLL R6 R6 8
	ADDIU R6 0x10					;R6=0xBF10
	SW R6 R0 0x0000
	SW R6 R1 0x0001
	SW R6 R2 0x0002
	

	

	
	;R1=中断号
	LW_SP R1 0x0000
	ADDSP 0x0001
	LI R0 0x00FF
	AND R1 R0
	
	;R2=应用程序的pc
	LW_SP R2 0x0000
	ADDSP 0x0001
	
	;保存r3
	ADDSP -1
	SW_SP R3 0x0000


	
	;保存用户程序返回地址
	ADDSP -1
	SW_SP R7 0x0000
	
	;提示终端，进入中断处理
	LI R3 0x000F
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00
	SW R6 R3 0x0000
	NOP
	;输出中断号
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00 
	SW R6 R1 0x0000
	NOP
	
	;提示终端，中断处理结束
	LI R3 0x000F
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00 
	SW R6 R3 0x0000
	NOP
	
	;R6保存返回地址
	ADDIU3 R2 R6 0x0000
	
	;用r3=IH（高位变成1）
	MFIH R3
	LI R0 0x0080
	SLL R0 R0 8
	OR R3 R0
	
	;恢复现场
	LI R7 0xBF
	SLL R7 R7 8
	ADDIU R7 0x10					;R7=0xBF10
	LW R7 R0 0x0000
	LW R7 R1 0x0001
	LW R7 R2 0x0002
	
	;r7=用户程序返回地址
	LW_SP R7 0x0000
	
	ADDSP 0x0001
	ADDSP 0x0001
	NOP
	MTIH R3;
	JR R6
	LW_SP R3 -1
	
	NOP	


;init  0x8251
START:
	;初始化IH寄存器，最高位为1时，允许中断，为0时不允许。初始化为0，kernel不允许中断
	LI R0 0x07
	MTIH R0
	;初始化栈地址
	li r0, 0xc000
	MTSP R0
	NOP
	
	;用户寄存器值初始化
	LI R6 0x00BF 
	SLL R6 R6 8
	ADDIU R6 0x10					;R6=0xBF10 
	LI R0 0x0000
	SW R6 R0 0x0000
	SW R6 R0 0x0001
	SW R6 R0 0x0002
	SW R6 R0 0x0003
	SW R6 R0 0x0004
	SW R6 R0 0x0005
		
	;WELCOME
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x004F
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x004B
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x000A
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x000D
	SW R6 R0 0x0000
	NOP
	

	

	

	
BEGIN:          ;检测命令
	;接收字符，保存到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00ff 
  AND R1 R6 
	NOP	
	

	;检测是否为R命令		
	LI R0 0x0052
	CMP R0 R1
	BTEQZ SHOWREGS	
	NOP	
	;检测是否为D命令
	LI R0 0x0044
	CMP R0 R1
	BTEQZ SHOWMEM
	NOP	
	
	;检测是否为A命令
	LI R0 0x0041
	CMP R0 R1
	BTEQZ GOTOASM
	NOP	
	
	;检测是否为U命令
	LI R0 0x0055
	CMP R0 R1
	BTEQZ GOTOUASM
	NOP	
	;检测是否为G命令
	LI R0 0x0047
	CMP R0 R1
	BTEQZ GOTOCOMPILE
	NOP		
	
	B BEGIN
	NOP

;各处理块的入口
GOTOUASM:
	NOP
	B UASM
	NOP
GOTOASM:
	NOP
	B ASM
	NOP
	
GOTOCOMPILE:
	NOP
	B COMPILE
	NOP
  
	
;测试8251是否能写
TESTW:	
	NOP	 		
	LI R6 0x00BF 
	SLL R6 R6 8 
	ADDIU R6 0x0001 
	LW R6 R0 0x0000 
	LI R6 0x0001 
	AND R0 R6 
	BEQZ R0 TESTW     ;BF01&1=0 则等待	
	NOP		
	JR R7
	NOP 
	

	
;测试8251是否能读
TESTR:	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 
	ADDIU R6 0x0001 
	LW R6 R0 0x0000 
	LI R6 0x0002
	AND R0 R6 
	BEQZ R0 TESTR   ;BF01&2=0  则等待	
	NOP	
	JR R7
	NOP 		
	
	
SHOWREGS:    ;R命令，打印R0-R5
	LI R1 0x0006  ;R1递减  
	LI R2 0x0006   ;R2不变
	
LOOP:
	LI R0  0x00BF
	SLL R0 R0 8
	ADDIU R0 0x0010
	SUBU R2 R1 R3   ;R2=0,1,2,3
	ADDU R0 R3 R0   ;R0=BF10...
	LW R0 R3 0x0000    ;R3=用户程序的 R0,R1,R2	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=BF00	
	SW R6 R3 0x0000	
	;发送高八位
	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 -1
	NOP
	BNEZ R1 LOOP
	NOP	
	B BEGIN
	NOP
	

	
	

	
	
	
SHOWMEM:  ;查看内存	
;D读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000	
	LI R6 0x00FF
	AND R5 R6
	NOP	
	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	;读取显示次数低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取显示次数高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存个数
	SLL R2 R2 8
	OR R2 R5

	
		;循环发出	
	
MEMLOOP:		
	
	LW R1 R3 0x0000    ;R3为内存数据	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	;发送高八位

	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 0x0001   ;R1=地址加加加
	ADDIU R2 -1
	NOP
	BNEZ R2 MEMLOOP
	NOP	

	B BEGIN
	NOP		


 ;汇编	
ASM:  
	;A命令读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	
	
	
	;检测地址是否合法
	LI R0 0x0000
	CMP R0 R1      
  BTEQZ GOTOBEGIN
	NOP	
	
 
	;读取数据低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	

	;读取数据高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存数据
	SLL R2 R2 8
	OR R2 R5
			
	SW R1 R2 0x0000	
	NOP
	
	B ASM
	NOP
	
GOTOBEGIN:
	NOP
	B BEGIN
	NOP
	
	
	
	
;反汇编：将需要反汇编的地址处的值发给终端处理	
UASM:
;读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	;读取显示次数低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取显示次数高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存个数
	SLL R2 R2 8
	OR R2 R5

	
		;循环发出	
	
UASMLOOP:		
	
	LW R1 R3 0x0000    ;R3为内存数据	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	;发送高八位

	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 0x0001   ;R1=地址加加加
	ADDIU R2 -1
	NOP
	BNEZ R2 UASMLOOP
	NOP	

	B BEGIN
	NOP			
	
;连续执行
COMPILE:
	;读取地址低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取内存高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存地址  传给r6
	SLL R2 R2 8
	OR R2 R5
	ADDIU3 R2 R6 0x0000
	
	
	LI R7 0x00BF
	SLL R7 R7 8
	ADDIU R7 0x0010
	
	LW R7 R5 0x0005
	ADDSP -1
	SW_SP R5 0x0000
	
	
	;中断保存在R5中
	MFIH R5
	LI R1 0x0080
	SLL R1 R1 8
	OR R5 R1
	
	
	
	;恢复现场
	LW R7 R0 0x0000
	LW R7 R1 0x0001
	LW R7 R2 0x0002
	LW R7 R3 0x0003
	LW R7 R4 0x0004
	
	
	
	MFPC R7
	ADDIU R7 0x0004
	MTIH R5    ;IH高位赋1	
	JR R6
	LW_SP R5 0x0000  ;R5恢复现场
	
	;用户程序执行完毕，返回kernel，保存现场
	NOP
	NOP
	ADDSP 0x0001
	LI R7 0x00BF
	SLL R7 R7 8
	ADDIU R7 0x0010
	
	SW R7 R0 0x0000
	SW R7 R1 0x0001
	SW R7 R2 0x0002
	SW R7 R3 0x0003
	SW R7 R4 0x0004
	SW R7 R5 0x0005
	
	;IH高位赋0
	MFIH R0
	LI R1 0x007F
	SLL R1 R1 8
	LI R2 0x00FF
	OR R1 R2	
	AND R0 R1
	MTIH R0
	
	;给终端发送结束用户程序提示
	LI R1 0x0007
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R1 0x0000		
	B BEGIN
	NOP	
		
	
	




	
.org 0x200

; VGA
.extern vga_control_base, 0xeffc
.extern graphics_base, 0xf000

; PS/2
.extern ps2_base, 0xe002
.extern ps2_data, 0xe002
.extern ps2_control, 0xe003

; global variables
.extern ctrl_pressed, 0xc000
.extern alt_pressed, 0xc001
.extern shift_pressed, 0xc002
.extern is_extend, 0xc003
.extern is_break, 0xc004
.extern char_addr, 0xc005

; stack
.extern stack_base 0xe000
main:

; initialize stack
la r0, stack_base
mtsp r0

; initialize global variables
li r0, 0x0000
la r4, ctrl_pressed
sw r4, r0, 0
la r4, alt_pressed
sw r4, r0, 0
la r4, shift_pressed
sw r4, r0, 0
la r4, is_extend
sw r4, r0, 0
la r4, is_break
sw r4, r0, 0
la r4, char_addr
sw r4, r0, 0

call clear_screen
nop
la r0, boot_message
call puts
nop

shell_loop:
    la r0, prompt
    call puts
    nop
    li r0, 0xb000 ; temp buffer
    call gets
    nop

    ; command == "server"?
    la r1, server
    call strcmp
    nop
    beqz r4, goto_server
    nop

    la r1, empty_string
    call strcmp
    nop
    beqz r4, shell_loop
    nop

    ; print "Unknown command: xxx\n"
    move r1, r0
    la r0, unknown_command
    call puts
    nop
    move r0, r1
    call puts
    nop
    li r0, 10
    call putchar
    nop

    b shell_loop
    nop

goto_server:
    ; goto 0x0003
    li r0, 0x0003
    jr r0
    nop
putchar:
    addsp -7
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r4, 4
    swsp r5, 5
    swsp r6, 6

    ; r0 data
    la r4, char_addr
    lw r4, r1, 0 ; cursor addr
    la r4, vga_control_base ; vga control
    lw r4, r3, 2 ; cursor pos
    move r2, r3
    sra r2, r2, 8
    li r4, 0xFF
    and r2, r4 ; cursor row
    and r3, r4 ; cursor col

    la r4, graphics_base ; graphics memory base
    li r5, 0x0700 ; color

    cmpi r0, 10 ; '\n'
    bteqz _putchar_newline
    nop
    cmpi r0, 13 ; '\r'
    bteqz _putchar_enter
    nop
    b _putchar_char
    nop

    _putchar_newline: ; '\n'
    subu r1, r3, r1
    addiu r1, 80
    addiu r2, 1
    li r3, 0
    cmpi r2, 30 
    bteqz _putchar_scroll
    nop
    b _putchar_save
    nop

    _putchar_enter: ; '\r'
    subu r1, r3, r1
    li r3, 0
    b _putchar_save
    nop

    _putchar_char:
    or r0, r5
    addu r1, r4, r6
    sw r6, r0, 0
    addiu r1, 1
    addiu r3, 1
    cmpi r3, 80 
    bteqz _putchar_nextline
    nop
    b _putchar_save
    nop
    _putchar_nextline:
    addiu r2, 1
    li r3, 0
    cmpi r2, 30 
    bteqz _putchar_scroll
    nop
    b _putchar_save
    nop

    _putchar_scroll:
    addiu r1, -80
    addiu r2, -1
    move r5, r4
        _putchar_loop:
        cmpi r5, -81 ; r5 + 80 <= 0xffff
        bteqz _putchar_save
        nop
        addiu r5, 80
        lw r5, r6, 0
        addiu r5, -80
        sw r5, r6, 0
        addiu r5, 1
        b _putchar_loop
        nop

    _putchar_save:
    la r0, char_addr
    sw r0, r1, 0 ; cursor addr
    sll r2, r2, 8 ; row
    or r2, r3 ; pos
    la r0, vga_control_base ; vga control
    sw r0, r2, 2 ; cursor pos

_putchar_out:
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r4, 4
    lwsp r5, 5
    lwsp r6, 6
    addsp 7
    ret
    nop

clear_screen:
    addsp -2
    swsp r0, 0
    swsp r0, 1
    la r0, graphics_base
    li r1, 0x0700
    _clear_screen_loop:
        cmpi r0, -1 ; r0 = 0xffff?
        bteqz _clear_screen_out
        sw r0, r1, 0x00 ; bd
        b _clear_screen_loop
        addiu r0, 1 ; bd
    _clear_screen_out:
    li r0, 0x0000
    la r1, char_addr
    sw r1, r0, 0
    la r1, vga_control_base
    sw r1, r0, 2 ; pos
    lwsp r0, 0
    lwsp r1, 1
    addsp 2
    ret
    nop

; print a string stored at *r0 ending with '\0'
puts:
    addsp -3
    swsp r0, 0
    swsp r1, 1
    swsp r7, 2
    move r1, r0
_puts_loop:
    lw r1, r0, 0
    beqz r0, _puts_out
    nop
    call putchar
    nop
    ; call delay
    ; nop
    b _puts_loop
    addiu r1, 1 ; bd, next char
_puts_out:
    lwsp r0, 0
    lwsp r1, 1
    lwsp r7, 2
    addsp 3
    ret
    nop
gets:
	addsp -8
	swsp r0, 0
	swsp r1, 1
	swsp r2, 2
	swsp r3, 3
	swsp r4, 4
	swsp r5, 5
	swsp r6, 6
	swsp r7, 7
	li r7, 1 ; not done
	addsp -2
	sw_sp r0, 1 ; result addr (modified)
	sw_sp r0, 2 ; result addr (original)

	_gets_ps2_loop:
		beqz r7, _gets_done
		nop
		la r2, ps2_base
		li r3, 0x0001
		_gets_wait_ps2:
			lw r2, r4, 1 ; ps2 control
			and r4, r3
			beqz r4, _gets_wait_ps2
			nop
		lw r2, r0, 0 ; ps2 data

		; is extend?
		li r1, 0xe0
		cmp r0, r1
		bteqz _gets_extend
		nop

		; is break?
		li r1, 0xf0
		cmp r0, r1
		bteqz _gets_break
		nop

		; ignore extend and break
		la r1, is_extend
		lw r1, r1, 0
		bnez r1, _gets_clear_flags
		nop
		la r1, is_break
		lw r1, r1, 0
		bnez r1, _gets_clear_flags
		nop

		; keyboard 2 ascii
		la r1, ps2_scancode
		addu r0, r1, r0
		lw r0, r0, 0

	_gets_putchar:
		; r0 data
		la r4, char_addr
		lw r4, r1, 0 ; cursor addr
		la r4, vga_control_base ; vga control
		lw r4, r3, 2 ; cursor pos
		move r2, r3
		sra r2, r2, 8
		li r4, 0xFF
		and r2, r4 ; cursor row
		and r3, r4 ; cursor col
		la r4, graphics_base ; graphics memory base
		li r5, 0x0700 ; color
		cmpi r0, 10 ; '\n'
		bteqz _gets_newline
		nop
		cmpi r0, 8 ; backspace
		bteqz _gets_backspace
		nop
		cmpi r0, 0 
		bteqz _gets_ps2_loop
		nop
		b _gets_char
		nop

	_gets_done:
		lw_sp r6, 1 ; result addr (modified)
		li r0, 0
		sw r6, r0, 0 ; '\0'
		addsp 2
		; print last '\n'
		li r0, 10
		call putchar
		nop
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

	_gets_extend:
		la r0, is_extend
		li r1, 1
		sw r0, r1, 0
		b _gets_ps2_loop
		nop

	_gets_break:
		la r0, is_break
		li r1, 1
		sw r0, r1, 0
		b _gets_ps2_loop
		nop

	_gets_backspace:
		lw_sp r5, 2 ; result addr (original)
		lw_sp r6, 1 ; result addr (modified)
		cmp r5, r6
		bteqz _gets_clear_flags ; cannot backspace
		nop
		li r5, 0
		sw r6, r5, 0 ; clear memory
		addiu r6, -1
		sw_sp r6, 1
		addiu r1, -1
		addiu r3, -1
		addu r1, r4, r6
		li r5, 0x0700
		sw r6, r5, 0 ; clear graphics memory
		b _gets_save
		nop

	_gets_clear_flags:
		; clear flags
		la r0, is_extend
		li r1, 0
		sw r0, r1, 0
		la r0, is_break
		li r1, 0
		sw r0, r1, 0
		b _gets_ps2_loop
		nop

	_gets_newline: ; '\n'
		li r7, 0
		b _gets_save
		nop

	_gets_char:
		lw_sp r6, 1 ; result addr (modified)
		sw r6, r0, 0
		addiu r6, 1
		sw_sp r6, 1
		or r0, r5
		addu r1, r4, r6
		sw r6, r0, 0
		addiu r1, 1
		addiu r3, 1
		b _gets_save
		nop

	_gets_save:
		la r0, char_addr
		sw r0, r1, 0 ; cursor addr
		sll r2, r2, 8 ; row
		or r2, r3 ; pos
		la r0, vga_control_base ; vga control
		sw r0, r2, 2 ; cursor pos
		b _gets_clear_flags
		nop
delay:
    push r0
    push r1
    li r1, 1000
_delay_outer_loop:
    li r0, 1000
_delay_inner_loop:
    addiu r0, -1
    bnez r0, _delay_inner_loop
    nop
    addiu r1, -1
    bnez r1, _delay_outer_loop
    nop
    pop r1
    pop r0
    ret
    nop
; compare r0 and r1, result is in r4
strcmp:
    addsp -5
    swsp r0, 0
    swsp r1, 1
    swsp r2, 2
    swsp r3, 3
    swsp r5, 4
    li r4, 0
    _strcmp_loop:
        lw r0, r2, 0
        lw r1, r3, 0
        move r5, r2
        or r5, r3
        beqz r5, _strcmp_break ; *r0 == 0 || *r1 == 0
        cmp r2, r3 ; bd
        bteqz _strcmp_char_eq
        nop
        ; *r0 != *r1
        b _strcmp_end
        li r4, 1 ; bd
        _strcmp_char_eq:
        addiu r0, 1
        addiu r1, 1
        b _strcmp_loop
        nop
    _strcmp_break:
        bteqz _strcmp_end ; *r0 == 0 && *r1 == 0
        nop
        li r4, 1
    _strcmp_end:
    lwsp r0, 0
    lwsp r1, 1
    lwsp r2, 2
    lwsp r3, 3
    lwsp r5, 4
    addsp 5
    ret
    nop
hello_world:
.word 'h'
.word 'e'
.word 'l'
.word 'l'
.word 'o'
.word 44
.word 32
.word 'w'
.word 'o'
.word 'r'
.word 'l'
.word 'd'
.word 10
.word 0

prompt:
.word 's'
.word 'h'
.word '#'
.word 32
.word 0

boot_message:
.word 'S'
.word 'y'
.word 's'
.word 't'
.word 'e'
.word 'm'
.word 32
.word 'b'
.word 'o'
.word 'o'
.word 't'
.word 'e'
.word 'd'
.word 32
.word 's'
.word 'u'
.word 'c'
.word 'c'
.word 'e'
.word 's'
.word 's'
.word 'f'
.word 'u'
.word 'l'
.word 'l'
.word 'y'
.word '!'
.word 10
.word 10
.word 'T'
.word 'H'
.word 'C'
.word 'O'
.word 32
.word 'M'
.word 'I'
.word 'P'
.word 'S'
.word '1'
.word '6'
.word 'e'
.word 32
.word '['
.word 'v'
.word 'e'
.word 'r'
.word 's'
.word 'i'
.word 'o'
.word 'n'
.word 32
.word '0'
.word '.'
.word '0'
.word '.'
.word '0'
.word ']'
.word 10
.word 32
.word 32
.word 32
.word 32
.word 'b'
.word 'y'
.word 32
.word 't'
.word 'w'
.word 'd'
.word '2'
.word 32
.word 'a'
.word 'n'
.word 'd'
.word 32
.word 'C'
.word 'o'
.word 'l'
.word 'i'
.word 'n'
.word 10
.word 10
.word 0

server:
.word 's'
.word 'e'
.word 'r'
.word 'v'
.word 'e'
.word 'r'
.word 0

unknown_command:
.word 'U'
.word 'n'
.word 'k'
.word 'n'
.word 'o'
.word 'w'
.word 'n'
.word 32
.word 'c'
.word 'o'
.word 'm'
.word 'm'
.word 'a'
.word 'n'
.word 'd'
.word 58
.word 32
.word 0

empty_string:
.word 0

ps2_scancode:
; scancode lookup table
; 128 items
; usage:
; la r0, ps2_scancode
; addu r1, r0, r0
; lw r1, r1, 0
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x09
.word 0x60
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x71
.word 0x31
.word 0x00
.word 0x01
.word 0x02
.word 0x7A
.word 0x73
.word 0x61
.word 0x77
.word 0x32
.word 0x00
.word 0x00
.word 0x63
.word 0x78
.word 0x64
.word 0x65
.word 0x34
.word 0x33
.word 0x00
.word 0x00
.word 0x20
.word 0x76
.word 0x66
.word 0x74
.word 0x72
.word 0x35
.word 0x00
.word 0x00
.word 0x6E
.word 0x62
.word 0x68
.word 0x67
.word 0x79
.word 0x36
.word 0x00
.word 0x00
.word 0x00
.word 0x6D
.word 0x6A
.word 0x75
.word 0x37
.word 0x38
.word 0x00
.word 0x00
.word 0x2C
.word 0x6B
.word 0x69
.word 0x6F
.word 0x30
.word 0x39
.word 0x00
.word 0x00
.word 0x2E
.word 0x2F
.word 0x6C
.word 0x3B
.word 0x70
.word 0x2D
.word 0x00
.word 0x00
.word 0x00
.word 0x27
.word 0x00
.word 0x5B
.word 0x3D
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x0A
.word 0x5D
.word 0x00
.word 0x5C
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x06
.word 0x07
.word 0x08
.word 0x00
.word 0x00
.word 0x31
.word 0x00
.word 0x34
.word 0x37
.word 0x00
.word 0x00
.word 0x00
.word 0x30
.word 0x2E
.word 0x32
.word 0x35
.word 0x36
.word 0x38
.word 0x00
.word 0x00
.word 0x00
.word 0x2B
.word 0x33
.word 0x2D
.word 0x2A
.word 0x39
.word 0x00
.word 0x00

