#!/bin/bash

cat jmp.asm > a.asm
echo >> a.asm
cat kernel.asm >> a.asm
echo >> a.asm
cat const.asm >> a.asm
echo >> a.asm
cat init.asm >> a.asm
echo >> a.asm
cat main.asm >> a.asm
echo >> a.asm
cat putchar.asm >> a.asm
echo >> a.asm
cat gets.asm >> a.asm
echo >> a.asm
cat strcmp.asm >> a.asm
echo >> a.asm
cat getchar.asm >> a.asm
echo >> a.asm
cat sd.asm >> a.asm
echo >> a.asm
cat print_hex.asm >> a.asm
echo >> a.asm
cat selftest.asm >> a.asm
echo >> a.asm
cat 2048.asm >> a.asm
echo >> a.asm
cat badapple.asm >> a.asm
echo >> a.asm
cat timer.asm >> a.asm
echo >> a.asm
cat delay.asm >> a.asm
echo >> a.asm
cat literal.asm >> a.asm
echo >> a.asm

python3 as.py a.asm