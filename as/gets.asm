li r7, 1 ; not done

_ps2_loop:
beqz r7, _done
nop
li r1, 0x0700 ; color
li r2, 0xe002 ; ps2 base
li r3, 0x0001
_wait_ps2:
lw r2, r4, 0x01 ; ps2 control
and r4, r3
beqz r4, _wait_ps2
nop
lw r2, r0, 0x00 ; ps2 data
b _check
nop
_set_done:
li r7, 0
b _putchar
nop 
_check:
cmpi r0, 0 
bteqz _done
nop
cmpi r0, 10 
bteqz _set_done
nop

_putchar:
; r0 data
li r4, 0xEFFB ; vga control
lw r4, r1, 0 ; cursor addr
lw r4, r3, 3 ; cursor pos
li r2, 0xFF00
and r2, r3
sra r2, r2, 4 ; cursor row
li r4, 0xFF
and r3, r4 ; cursor col
li r4, 0xf000 ; graphics memory base
li r5, 0x0700 ; color

cmpi r0, 10 ; \n
bteqz _newline
nop
cmpi r0, 13 ; \r
bteqz _enter
nop
b _char
nop

_newline: ;\n
subu r1, r3, r1
addiu r1, 80
addiu r2, 1
li r3, 0
cmpi r2, 30 
bteqz _scroll
nop
b _save
nop

_enter: ;\r
subu r1, r3, r1
li r3, 0
b _save
nop

_char:
or r0, r5
addu r1, r4, r6
sw r6, r0, 0
addiu r1, 1
addiu r3, 1
cmpi r3, 80 
bteqz _nextline
nop
b _save
nop
_nextline:
addiu r2, 1
li r3, 0
cmpi r2, 30 
bteqz _scroll
nop
b _save
nop

_scroll:
addiu r1, -80
addiu r2, -1
move r5, r4
_loop:
cmpi r5, -81 ; r5 + 80 <= 0xffff
bteqz _save
nop
lw r5, r6, 80
sw r5, r6, 0
addiu r5, 1
b _loop
nop

_save:
li r0, 0xEFFB ; vga control
sw r0, r1, 0 ; cursor addr
sll r2, r2, 4
and r2, r3 
sw r0, r2, 3 ; cursor pos
b _ps2_loop
nop

_done:
b $
nop