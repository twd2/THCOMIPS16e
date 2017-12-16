import sys
import struct

class ASError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class ImmOutOfRangeError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class DuplicatedSymbolError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class SymbolNotFoundError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class BadOperandError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class UnknownInstructionError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class BadOffsetError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

# define pseudo-instructions

PSEUDO = {}

def pseudo_twd2():
    return [['nop']] * 3
PSEUDO['twd2'] = pseudo_twd2

def pseudo_li(rx, imm):
    imm = parse_imm(imm)
    if not -32768 <= imm <= 65535:
        raise ImmOutOfRangeError(imm)
    hi = (imm >> 8) & 0xff
    lo = imm & 0xff
    if hi == 0:
        return [['li', rx, str(lo)]]
    else:
        if lo >= 0x80:
            return [['li', rx, str((hi + 1) & 0xff)],
                    ['sll', rx, rx, str(8)],
                    ['addiu', rx, str(lo)]]
        elif lo == 0:
            return [['li', rx, str(hi)],
                    ['sll', rx, rx, str(8)]]
        else:
            return [['li', rx, str(hi)],
                    ['sll', rx, rx, str(8)],
                    ['addiu', rx, str(lo)]]
PSEUDO['li'] = pseudo_li

def pseudo_la(rx, sym):
    return [['_lahi', rx, sym],
            ['sll', rx, rx, str(8)],
            ['_lalo', rx, sym]]
PSEUDO['la'] = pseudo_la

def pseudo_push(rx):
    return [['addsp', '-1'],
            ['sw_sp', rx, '0']]
PSEUDO['push'] = pseudo_push

def pseudo_pop(rx):
    return [['lw_sp', rx, '0'],
            ['addsp', '1']]
PSEUDO['pop'] = pseudo_pop

def pseudo_call(label, rx='r7'):
    return [['mfpc', rx],
            ['addiu', rx, '3'],
            ['b', label]]
PSEUDO['call'] = pseudo_call

def pseudo_ret(rx='r7'):
    return [['jr', rx]]
PSEUDO['ret'] = pseudo_ret

def pseudo_jalr(rx='r7', ry='r0'):
    return [['mfpc', rx],
            ['addiu', rx, '3'],
            ['jr', ry]]
PSEUDO['jalr'] = pseudo_jalr

# define instructions

ACT = {}

def make0(op, remain):
    return ((op & 0b11111) << 11) | (remain & 0b11111111111)

def make1(op, rx, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | (remain & 0b11111111)

def make2(op, rx, ry, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | ((ry & 0b111) << 5) | (remain & 0b11111)

def make3(op, rx, ry, rz, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | ((ry & 0b111) << 5) | ((rz & 0b111) << 2) | (remain & 0b11)

def make_addiu(rx, imm):
    if not -128 <= imm <= 255:
        raise ImmOutOfRangeError(imm)
    return make1(0b01001, reg(rx), imm & 0b11111111)
ACT['addiu'] = make_addiu

def make_addiu3(rx, ry, imm):
    if not -8 <= imm <= 7:
        raise ImmOutOfRangeError(imm)
    return make2(0b01000, reg(rx), reg(ry), imm & 0b1111)
ACT['addiu3'] = make_addiu3

def make_addsp3(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00000, reg(rx), imm)
ACT['addsp3'] = make_addsp3
ACT['add_sp3'] = make_addsp3

def make_addsp(imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01100, 0b011, imm)
ACT['addsp'] = make_addsp
ACT['add_sp'] = make_addsp

def make_addu(rx, ry, rz):
    return make3(0b11100, reg(rx), reg(ry), reg(rz), 0b01)
ACT['addu'] = make_addu

def make_and(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01100)
ACT['and'] = make_and

def make_b(imm):
    if not -1024 <= imm <= 1023:
        raise ImmOutOfRangeError(imm)
    return make0(0b00010, imm)
ACT['b'] = make_b

def make_beqz(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00100, reg(rx), imm)
ACT['beqz'] = make_beqz

def make_bnez(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00101, reg(rx), imm)
ACT['bnez'] = make_bnez

def make_bteqz(imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01100, 0b000, imm)
ACT['bteqz'] = make_bteqz

def make_btnez(imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01100, 0b001, imm)
ACT['btnez'] = make_btnez

def make_cmp(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01010)
ACT['cmp'] = make_cmp

def make_cmpi(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01110, reg(rx), imm)
ACT['cmpi'] = make_cmpi

def make_jr(rx):
    return make1(0b11101, reg(rx), 0)
ACT['jr'] = make_jr

def make_li(rx, imm):
    if not 0 <= imm <= 255:
        raise ImmOutOfRangeError(imm)
    return make1(0b01101, reg(rx), imm)
ACT['li'] = make_li

def make_lw(rx, ry, imm):
    if not -16 <= imm <= 15:
        raise ImmOutOfRangeError(imm)
    return make2(0b10011, reg(rx), reg(ry), imm)
ACT['lw'] = make_lw

def make_lw_sp(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b10010, reg(rx), imm)
ACT['lw_sp'] = make_lw_sp
ACT['lwsp'] = make_lw_sp

def make_mfih(rx):
    return make1(0b11110, reg(rx), 0)
ACT['mfih'] = make_mfih

def make_mfpc(rx):
    return make1(0b11101, reg(rx), 0b01000000)
ACT['mfpc'] = make_mfpc

def make_move(rx, ry):
    return make2(0b01111, reg(rx), reg(ry), 0)
ACT['move'] = make_move

def make_mtih(rx):
    return make1(0b11110, reg(rx), 0b00000001)
ACT['mtih'] = make_mtih

def make_mtsp(ry):
    return make2(0b01100, 0b100, reg(ry), 0)
ACT['mtsp'] = make_mtsp

def make_not(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01111)
ACT['not'] = make_not

def make_nop():
    return make0(0b00001, 0)
ACT['nop'] = make_nop

def make_or(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01101)
ACT['or'] = make_or

def make_sll(rx, ry, imm):
    if not 1 <= imm <= 8:
        raise ImmOutOfRangeError(imm)
    if imm == 8:
        imm = 0
    return make3(0b00110, reg(rx), reg(ry), imm, 0)
ACT['sll'] = make_sll

def make_sllv(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b00100)
ACT['sllv'] = make_sllv

def make_sra(rx, ry, imm):
    if not 1 <= imm <= 8:
        raise ImmOutOfRangeError(imm)
    if imm == 8:
        imm = 0
    return make3(0b00110, reg(rx), reg(ry), imm, 0b11)
ACT['sra'] = make_sra

def make_srav(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b00111)
ACT['srav'] = make_srav

def make_subu(rx, ry, rz):
    return make3(0b11100, reg(rx), reg(ry), reg(rz), 0b11)
ACT['subu'] = make_subu

def make_sw(rx, ry, imm):
    if not -16 <= imm <= 15:
        raise ImmOutOfRangeError(imm)
    return make2(0b11011, reg(rx), reg(ry), imm)
ACT['sw'] = make_sw

def make_sw_sp(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b11010, reg(rx), imm)
ACT['sw_sp'] = make_sw_sp
ACT['swsp'] = make_sw_sp

cp0_name_alias = {'status': 0, 'cause': 1, 'epc': 2, 'ecs': 3,
                  'tmp0': 4, 'tmp1': 5, 'tmp2': 6}

def make_mfc0(rx, imm):
    imm = cp0_name_alias.get(imm, imm)
    if not 0 <= imm <= 7:
        raise ImmOutOfRangeError(imm)
    return make2(0b11110, reg(rx), imm, 0b00000)
ACT['mfc0'] = make_mfc0

def make_mtc0(rx, imm):
    imm = cp0_name_alias.get(imm, imm)
    if not 0 <= imm <= 7:
        raise ImmOutOfRangeError(imm)
    return make2(0b11110, reg(rx), imm, 0b00001)
ACT['mtc0'] = make_mtc0

def make_eret():
    return make0(0b11110, 0b00010)
ACT['eret'] = make_eret

def make_syscall(imm=0):
    if not -1024 <= imm <= 2047:
        raise ImmOutOfRangeError(imm)
    return make0(0b11111, imm)
ACT['syscall'] = make_syscall

def make__word(imm):
    if not -32768 <= imm <= 65535:
        raise ImmOutOfRangeError(imm)
    return imm & 0xffff
ACT['.word'] = make__word

def make__lahi(rx, imm):
    if not -32768 <= imm <= 65535:
        raise ImmOutOfRangeError(imm)
    hi = (imm >> 8) & 0xff
    lo = imm & 0xff
    if lo >= 0x80:
        hi += 1
    return make_li(rx, hi & 0xff)
ACT['_lahi'] = make__lahi

def make__lalo(rx, imm):
    if not -32768 <= imm <= 65535:
        raise ImmOutOfRangeError(imm)
    hi = (imm >> 8) & 0xff
    lo = imm & 0xff
    return make_addiu(rx, lo)
ACT['_lalo'] = make__lalo

def reg(r):
    if r[0] not in list('$Rr'):
        raise BadOperandError(r)
    try:
        return int(r[1:])
    except ValueError:
        raise BadOperandError(r) from None

def parse_imm(imm):
    if imm[0] == "'":
        return parse_char(imm)
    elif len(imm) >= 2 and (imm[0:2] == '0x' or imm[0:2] == '0X'):
        return int(imm, 16)
    elif len(imm) >= 2 and (imm[0:2] == '0b' or imm[0:2] == '0B'):
        return int(imm, 2)
    else:
        return int(imm)

def parse_char(imm):
    if imm[0] != "'" or len(imm) != 3 or imm[2] != "'":
        raise BadOperandError(imm)
    return ord(imm[1])

def asm(code):
    code = '\n'.join([l.split(';')[0] for l in code.split('\n')])
    code = code.replace(':', ':\n')

    # pass 1: build inst list and symbol table
    inst_list = []
    syms = {}
    extern_syms = set()
    for line in code.split('\n'):
        line = line.split(';')[0].strip()
        if not line:
            continue
        if line[-1] == ':': # label
            sym = line[:-1]
            if sym in syms:
                raise DuplicatedSymbolError(sym)
            syms[sym] = len(inst_list)
        else: # inst
            l = list(filter(lambda s: bool(s), line.replace(',', ' ').split(' ')))
            inst = l[0].lower()
            if inst == '.org':
                org = parse_imm(l[1])
                if org < len(inst_list):
                    raise BadOffsetError(org)
                inst_list.extend([['nop']] * (org - len(inst_list)))
            elif inst == '.extern':
                sym = l[1]
                if sym in syms:
                    raise DuplicatedSymbolError(sym)
                syms[sym] = parse_imm(l[2])
                extern_syms.add(sym)
            elif inst in PSEUDO:
                inst_list.extend(PSEUDO[inst](*l[1:]))
            else:
                inst_list.append(l)

    print('{} instructions. Resolving symbols...'.format(len(inst_list)))

    # pass 2: symbol/imm resolve
    for pc, inst in enumerate(inst_list):
        op = inst[0].lower()
        if op in ['b', 'bteqz', 'btnez']:
            sym = inst[1]
            if sym not in syms:
                raise SymbolNotFoundError(sym)
            inst[1] = syms[sym] - (pc + 1)
        elif op in ['beqz', 'bnez']:
            sym = inst[2]
            if sym not in syms:
                raise SymbolNotFoundError(sym)
            inst[2] = syms[sym] - (pc + 1)
        elif op in ['_lahi', '_lalo']:
            sym = inst[2]
            if sym not in syms:
                raise SymbolNotFoundError(sym)
            inst[2] = syms[sym]
        else:
            for i in range(len(inst)):
                arg = inst[i]
                if arg[0] in list("'-0123456789"):
                    inst[i] = parse_imm(arg)
    print(inst_list)

    print('{} instructions. Generating target code...'.format(len(inst_list)))

    addr_to_sym = dict((v, k) for k, v in syms.items())

    # pass 3: generate target code
    mc = []
    for inst in inst_list:
        if len(mc) in addr_to_sym:
            print('In symbol {}...'.format(addr_to_sym[len(mc)]))
        if inst[0].lower() not in ACT:
            raise UnknownInstructionError(inst[0])
        try:
            mc.append(ACT[inst[0].lower()](*inst[1:]))
        except TypeError:
            raise BadOperandError(inst) from None

    # pass 4: generate binary
    buffer = b''
    for c in mc:
        buffer += struct.pack('<H', c) # little-endian
    
    for sym in extern_syms:
        syms.pop(sym)

    return buffer, syms

def main():
    if len(sys.argv) < 2:
        print('Usage: {} <asm file> [<output file>]'.format(sys.argv[0]))
        exit(1)
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        buffer, syms = asm(f.read())
    out_filename = 'a.out'
    if len(sys.argv) >= 3:
        out_filename = sys.argv[2]
    with open(out_filename, 'wb') as f:
        f.write(buffer)
        # 4K bytes padding
        remainder = len(buffer) % 4096
        if remainder:
            f.write(bytes([0] * (4096 - remainder)))
    with open(out_filename + '.sym', 'w', encoding='utf-8') as f:
        for k, v in sorted(syms.items(), key=lambda t: t[1]):
            f.write('.extern {}, 0x{:04x}\n'.format(k, v))

if __name__ == '__main__':
    main()
