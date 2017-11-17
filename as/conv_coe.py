import sys
import struct
import binascii

WIDTH = 16

if len(sys.argv) < 3:
  print('Usage: {} <binary file> <output coe file> [<word width>]'.format(sys.argv[0]))
  exit(1)

if len(sys.argv) >= 4:
  WIDTH = int(sys.argv[3])

with open(sys.argv[1], 'rb') as fin, \
     open(sys.argv[2], 'w', encoding='utf-8') as fout:
  fout.write("""memory_initialization_radix={};
memory_initialization_vector=
""".format(WIDTH))
  addr = 0
  buf = fin.read(WIDTH // 8)
  while buf:
    hex_str = binascii.hexlify(buf[::-1]).decode() # little-endian
    fout.write('{},\n'.format(hex_str).lower())
    addr += 1
    buf = fin.read(WIDTH // 8)
  fout.write('0' * (WIDTH // 4) + ';\n')
