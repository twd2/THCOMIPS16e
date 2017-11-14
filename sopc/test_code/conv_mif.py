import sys
import struct
import binascii

WIDTH = 32

if len(sys.argv) >= 4:
  WIDTH = int(sys.argv[3])

with open(sys.argv[1], 'rb') as fin, \
     open(sys.argv[2], 'w') as fout:
  fout.write("""DEPTH = 1024;
WIDTH = {};
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN
""".format(WIDTH))
  addr = 0
  buf = fin.read(WIDTH // 8)
  while buf:
    hex_str = binascii.hexlify(buf).decode() # big-endian
    fout.write('{:08x}: {};\n'.format(addr, hex_str).upper())
    addr += 1
    buf = fin.read(WIDTH // 8)
  fout.write('END;\n')
