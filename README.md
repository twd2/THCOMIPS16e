# THCOMIPS16e
Yet Another Implementation of THCO MIPS16e

## Instruction Set

ADDIU ADDIU3 ADDU SUBU

ADDSP

AND OR NOT MOVE

B BEQZ BNEZ

BTEQZ CMP CMPI

JR

LI

LW SW

LW_SP SW_SP MTSP

MTIH MFIH

MFPC

SLL SRA

SLLV SRAV

NOP

## Features

**Hardware**

* [x] Basic ISA
* [x] Extend ISA
* [x] Interrupt
* [x] Extensible internal bus design
* [x] VGA display 640x480 @ 60Hz
* [x] PS/2
* [x] SD card boot
* [x] SD card read/write DMA
* [x] GPIO
* [x] Can execute millions of instructions per second

**Software**

* [x] Modern Assembler with pseudo-instructions (la, li) support
* [x] POST (power-on self-test)
* [x] PS/2 Keyboard Driver
* [x] A tiny operating system (shell) with Super Cow Powers
* [x] 2048 game
* [x] BadApple animation
* [x] Danmuku (using clock interruption)

## References

* [SD Specifications Part 1 Physical Layer Simplified Specification](https://www.sdcard.org/downloads/pls/)
* [How to Use MMC/SDC](http://elm-chan.org/docs/mmc/mmc_e.html)
* [VGA Signal Timing](http://tinyvga.com/vga-timing)

## Note

*Because this is a course project, any plagiarism will be reported to the professor and TAs.*
