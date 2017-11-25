; r0 data
li r4, 0xEFFC ; vga control
lw r4, r1, 2 ; cursor addr
lw r4, r2, 3 ; cursor row
lw r4, r3, 4 ; cursor col
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
cmpi r5, -100 
bteqz _save
nop
lw r5, r6, 80
sw r5, r6, 0
addiu r5, 1
b _loop
nop

_save:
li r0, 0xEFFC ; vga control
sw r0, r1, 2 ; cursor addr
sw r0, r2, 3 ; cursor row
sw r0, r3, 4 ; cursor col
li r1, 29
sw r0, r1, 5 ; cursor_counter_limit

$:
b $
nop