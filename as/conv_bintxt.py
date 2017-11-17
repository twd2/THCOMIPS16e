import sys
import struct
import binascii

WIDTH = 16

if len(sys.argv) < 3:
  print('Usage: {} <binary file> <output bintxt file> [<word width>]'.format(sys.argv[0]))
  exit(1)

if len(sys.argv) >= 4:
  WIDTH = int(sys.argv[3])

with open(sys.argv[1], 'rb') as fin, \
     open(sys.argv[2], 'w', encoding='utf-8') as fout:
  addr = 0
  buf = fin.read(WIDTH // 8)
  while buf:
    bin_str = ''.join('{:08b}'.format(b) for b in buf[::-1]) # little-endian
    fout.write('{}\n'.format(bin_str).lower())
    addr += 1
    buf = fin.read(WIDTH // 8)
