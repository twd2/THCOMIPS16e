.org 0x0
.set noat
.set noreorder

; .global _start
start:
  lui $1, 0xcafe
  ori $1, $1, 0xbabe
  mthi $1
  mfhi $2
  mfhi $3
  mfhi $4
  mfhi $5
  lui $1, 0xdead
  ori $1, $1, 0xbeef
  mtlo $1
  mflo $2
  mflo $3
  mflo $4
  mflo $5
  mfhi $1
  div $0, $1, $2
  mflo $3
  mfhi $4
  divu $0, $1, $2
  divu $0, $1, $2
  mflo $5
  mfhi $6
  beq $2, $0, start
  divu $0, $1, $2
  ori $1, $0, 0x0
  lui $9, 0xfa50
  ori $10, $0, 0x0001
L1:
  beq $10, $9, L1
  ori $0, $0, 0x0 ; nop
  ori $10, $9, 0x0000
  beq $10, $9, L2
  ori $0, $0, 0x0 ; nop
  ori $10, $9, 0xffff
L2:
  bne $10, $9, L2
  ori $0, $0, 0x0 ; nop
  bne $10, $1, L3
  ori $0, $0, 0x0 ; nop
  ori $10, $1, 0xffff
L3:
  bgezal $9, start
  ori $0, $0, 0x0 ; nop
  bgezal $0, L4
  ori $0, $0, 0x0 ; nop
  ori $1, $0, 0xffff
L4:
  lui $1, 0x0001
  bgezal $1, L5
  ori $0, $0, 0x0 ; nop
  ori $1, $0, 0xaaaa
L5:
  ori $1, $0, 0x05af
  ori $2, $1, 0xfa50
  ori $6, $1, 0xfa50
  ori $3, $1, 0x0
  ori $4, $1, 0x0
  ori $5, $1, 0x0
  ori $1, $0, 0x05af
  ori $2, $0, 0x0
  sw $1, 4($0)
  lw $2, 4($0)
  ori $3, $2, 0x0
  ori $4, $2, 0x0
  ori $5, $2, 0x0
  lw $2, 0($0)
  ori $3, $1, 0x0
  ori $4, $2, 0x0
  ori $5, $2, 0x0
  ori $7, $0, 0x1
  addu $8, $8, $7
  ori $1, $0, 0x0
  jalr $30, $1
  ori $0, $0, 0x0 ; nop
  ori $0, $0, 0x0
  ori $0, $0, 0x0
