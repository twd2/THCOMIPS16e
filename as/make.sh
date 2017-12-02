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
cat delay.asm >> a.asm
echo >> a.asm
cat strcmp.asm >> a.asm
echo >> a.asm
cat literal.asm >> a.asm
echo >> a.asm

python3 as.py a.asm