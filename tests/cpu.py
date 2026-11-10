#!/usr/bin/env python3
"""Check ntv4004 against the MCS-40 User's Manual's instruction definitions.

These tests need only a built ntv4004 and Python; tests/interp.py compares
ntv4004 with Intel's own simulator when its images are available.
"""
from decimal import Decimal, localcontext
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import asm4  # noqa: E402

NTV = ROOT / ('ntv4004.exe' if os.name == 'nt' else 'ntv4004')
STATE = re.compile(r'acc (\w) carry (\d) regs (\w{16}) (\w{8}) pc (\w+) sp (\d) stack((?: \w{3}){8}) '
                   r'src (\w\w) cm (\d) bank (\d) rombank (\d) cycles (\d+)')


def run(source, cpu='4004', keys=None, options=(), limit=100_000):
    """Assemble source, run it, and return (state, stdout, return code)."""
    memory, _, _ = asm4.Assembler(cpu).assemble(source + '        END\n')
    with tempfile.TemporaryDirectory(prefix='ntv4004 cpu ') as directory:
        Path(directory, 'p.hex').write_text(asm4.hex_file(memory), encoding='ascii')
        command = [str(NTV), '-r', f'-n:{limit}', *(['-4'] if cpu == '4040' else []), *options]
        if keys is not None:
            Path(directory, 'keys.txt').write_bytes(keys)
            command.append('-l:keys.txt')
        result = subprocess.run(command + ['p.hex'], cwd=directory, capture_output=True, timeout=60)
    found = STATE.search(result.stderr.decode())
    if not found:
        raise AssertionError(result.stderr.decode())
    acc, carry, regs, bank1, pc, sp, stack, src, cm, bank, rombank, cycles = found.groups()
    ram = {int(line.split()[1]): line.split()[2] for line in result.stderr.decode().splitlines() if line.startswith('ram ')}
    state = {'acc': int(acc, 16), 'carry': int(carry), 'regs': [int(c, 16) for c in regs],
             'bank1': [int(c, 16) for c in bank1], 'pc': int(pc, 16), 'sp': int(sp),
             'stack': [int(s, 16) for s in stack.split()], 'src': int(src, 16), 'cm': int(cm),
             'cycles': int(cycles), 'ram': ram}
    return state, result.stdout.replace(b'\r\n', b'\n'), result.returncode  # Windows writes CRLF


def end():
    return 'DONE:   JUN DONE\n'


@unittest.skipUnless(NTV.is_file(), 'build ntv4004 first (m.sh or m.bat)')
class Instructions(unittest.TestCase):
    def accumulator(self, setup, operation, cpu='4004'):
        state, _, _ = run(setup + f'        {operation}\n' + end(), cpu)
        return state['acc'], state['carry']

    def test_add_and_subtract(self):
        # ADD adds the register and the carry; SUB adds the complement and the inverted carry.
        self.assertEqual(self.accumulator('        FIM 0,09H\n        LDM 8\n        CLC\n', 'ADD 1'), (1, 1))
        self.assertEqual(self.accumulator('        FIM 0,09H\n        LDM 5\n        STC\n', 'ADD 1'), (15, 0))
        self.assertEqual(self.accumulator('        FIM 0,03H\n        LDM 5\n        CLC\n', 'SUB 1'), (2, 1))
        self.assertEqual(self.accumulator('        FIM 0,03H\n        LDM 5\n        STC\n', 'SUB 1'), (1, 1))
        self.assertEqual(self.accumulator('        FIM 0,03H\n        LDM 2\n        CLC\n', 'SUB 1'), (15, 0))
        self.assertEqual(self.accumulator('        FIM 0,00H\n        LDM 0\n        CLC\n', 'SUB 1'), (0, 1))

    def test_accumulator_group(self):
        cases = [
            ('LDM 15\n        CLC', 'IAC', (0, 1)), ('LDM 6\n        STC', 'IAC', (7, 0)),
            ('LDM 0\n        STC', 'DAC', (15, 0)), ('LDM 5\n        CLC', 'DAC', (4, 1)),
            ('LDM 5\n        STC', 'CLB', (0, 0)), ('LDM 5\n        STC', 'CLC', (5, 0)),
            ('LDM 5\n        CLC', 'CMC', (5, 1)), ('LDM 5\n        CLC', 'CMA', (10, 0)),
            ('LDM 9\n        CLC', 'RAL', (2, 1)), ('LDM 9\n        STC', 'RAL', (3, 1)),
            ('LDM 9\n        CLC', 'RAR', (4, 1)), ('LDM 8\n        STC', 'RAR', (12, 0)),
            ('LDM 7\n        STC', 'TCC', (1, 0)), ('LDM 7\n        CLC', 'TCC', (0, 0)),
            ('LDM 7\n        STC', 'TCS', (10, 0)), ('LDM 7\n        CLC', 'TCS', (9, 0)),
            ('LDM 0\n        CLC', 'STC', (0, 1)),
            # DAA adds 6 when the carry is set or the accumulator exceeds 9, and only sets the carry.
            ('LDM 12\n        CLC', 'DAA', (2, 1)), ('LDM 5\n        STC', 'DAA', (11, 1)),
            ('LDM 7\n        CLC', 'DAA', (7, 0)), ('LDM 10\n        CLC', 'DAA', (0, 1)),
            ('LDM 9\n        CLC', 'DAA', (9, 0)),
        ]
        for setup, operation, expected in cases:
            with self.subTest(operation=operation, setup=setup):
                self.assertEqual(self.accumulator(f'        {setup}\n', operation), expected)

    def test_keyboard_process(self):
        table = {0: 0, 1: 1, 2: 2, 4: 3, 8: 4}
        for value in range(16):
            with self.subTest(value=value):
                self.assertEqual(self.accumulator(f'        LDM {value}\n        STC\n', 'KBP'), (table.get(value, 15), 1))

    def test_registers(self):
        state, _, _ = run('        FIM 0,12H\n        FIM 14,0FEH\n        LD 1\n        XCH 15\n        INC 14\n'
                          '        INC 0\n        INC 3\n' + end())
        self.assertEqual(state['regs'][:4], [2, 2, 0, 1])
        self.assertEqual(state['regs'][14:], [0, 2])
        self.assertEqual(state['acc'], 14)

    def test_jump_conditions(self):
        # C1 inverts, C2 tests ACC = 0, C3 tests CY = 1, C4 tests TEST = 0 (the pin is 0 here).
        for condition in range(16):
            for acc in (0, 5):
                for carry in (0, 1):
                    jump = ((condition & 4) and acc == 0) or ((condition & 2) and carry) or (condition & 1)
                    if condition & 8:
                        jump = not jump
                    source = (f'        LDM {acc}\n        {"STC" if carry else "CLC"}\n        LDM 0\n        XCH 2\n'
                              f'        LDM {acc}\n        JCN {condition},TAKEN\n        JUN DONE\nTAKEN:  LDM 1\n'
                              f'        XCH 2\n' + end())
                    with self.subTest(condition=condition, acc=acc, carry=carry):
                        self.assertEqual(run(source)[0]['regs'][2], 1 if jump else 0)

    def test_increment_and_skip(self):
        state, _, _ = run('        FIM 0,0DH\nLOOP:   INC 2\n        ISZ 1,LOOP\n' + end())
        self.assertEqual((state['regs'][1], state['regs'][2]), (0, 3))
        self.assertEqual(state['cycles'], 2 + 3 * 3)

    def test_page_boundaries(self):
        # JCN and ISZ in the last two bytes of a page jump within the next page.
        state, _, _ = run('        JUN 0FEH\n        ORG 0FEH\n        ISZ 0,NEXT\n        LDM 5\nNEXT:\n' + end())
        self.assertEqual((state['acc'], state['pc']), (0, 0x101))
        state, _, _ = run('        JUN 0FEH\n        ORG 0FEH\n        JCN 8,THERE\n        LDM 5\n        NOP\n        NOP\n'
                          'THERE:\n' + end())
        self.assertEqual((state['acc'], state['pc']), (0, 0x103))
        # FIN and JIN at the last byte of a page use the next page.
        state, _, _ = run('        FIM 0,10H\n        JUN 0FFH\n        ORG 0FFH\n        FIN 2\n' + end() +
                          '        ORG 110H\n        DB 0A5H\n        ORG 10H\n        DB 5AH\n')
        self.assertEqual(state['regs'][2:4], [10, 5])
        state, _, _ = run('        FIM 0,05H\n        JUN 0FFH\n        ORG 0FFH\n        JIN 0\n        ORG 105H\n' + end())
        self.assertEqual(state['pc'], 0x105)
        state, _, _ = run('        FIM 0,DATA\n        FIN 4\n' + end() + 'DATA:   DB 3CH\n')
        self.assertEqual(state['regs'][4:6], [3, 12])

    def test_4004_stack(self):
        three = '        JMS A\n' + end() + 'A:      JMS B\n        BBL 1\nB:      JMS C\n        BBL 2\nC:      BBL 3\n'
        state, _, _ = run(three)
        self.assertEqual((state['acc'], state['pc'], state['sp']), (1, 2, 0))
        # A fourth call overwrites the deepest return address, so the outer BBL returns into D.
        four = ('        JMS A\n' + end() + 'A:      JMS B\n        BBL 1\nB:      JMS C\n        BBL 2\nC:      JMS D\n'
                '        BBL 3\nD:      LDM 9\n        XCH 7\n        BBL 4\n')
        state, _, code = run(four)
        self.assertEqual(code, 2)  # it never reaches DONE
        state, _, _ = run(four, '4040')
        self.assertEqual((state['acc'], state['pc'], state['regs'][7]), (1, 2, 9))

    def test_4040_stack(self):
        source = '        JMS L1\n' + end()
        for level in range(1, 8):
            source += f'L{level}:     ' + (f'JMS L{level + 1}\n' if level < 7 else 'LDM 0\n') + f'        BBL {level}\n'
        state, _, _ = run(source, '4040')
        self.assertEqual((state['acc'], state['pc']), (1, 2))

    def test_4040_instructions(self):
        state, _, _ = run('        FIM 4,9CH\n        FIM 6,63H\n        LDM 2\n        OR4\n        XCH 8\n        LDM 1\n'
                          '        OR5\n        XCH 9\n        LDM 7\n        AN6\n        XCH 10\n        LDM 15\n        AN7\n'
                          '        XCH 11\n        LDM 5\n        DCL\n        LCR\n        XCH 12\n        SB1\n        LDM 7\n'
                          '        XCH 0\n        LDM 1\n        OR4\n        XCH 13\n        SB0\n' + end(), '4040')
        self.assertEqual(state['regs'][8:14], [11, 13, 6, 3, 5, 1])
        self.assertEqual((state['regs'][0], state['bank1'][0]), (0, 7))
        # The 4004 decodes 01H-0FH as NOP.
        state, _, _ = run('        DB 1\n        DB 0BH\n        LDM 3\n' + end())
        self.assertEqual((state['acc'], state['cycles']), (3, 3))

    def test_halt(self):
        state, _, code = run('        LDM 6\n        HLT\n        LDM 1\n' + end(), '4040')
        self.assertEqual((code, state['acc'], state['pc'], state['cycles']), (0, 6, 2, 2))

    def test_rom_banks(self):
        # DB1 then JUN: the JUN comes from the old bank and the target from the new one.
        state, _, _ = run('        DB1\n        JUN 20H\n        ORG 20H\n        LDM 2\n        JUN 20H\n        ORG 1020H\n'
                          '        LDM 3\n        DB0\n        JUN 40H\n        ORG 40H\n        XCH 5\n' + end(), '4040')
        self.assertEqual((state['regs'][5], state['pc']), (3, 0x41))
        # An entry address in bank 1 starts there.
        state, _, _ = run('        ORG 1000H\n        LDM 7\nDONE:   JUN 1\n', '4040', options=('-a:0x1000',))
        self.assertEqual((state['acc'], state['pc'], state['cycles']), (7, 1, 1))

    def test_ram(self):
        # Each DCL bank has 16 registers of 16 main and 4 status characters.
        source = ''
        for bank in range(8):
            source += f'        LDM {bank}\n        DCL\n        FIM 0,{bank * 17}\n        SRC 0\n        LDM {bank + 1}\n'
            source += '        WRM\n        WR2\n'
        source += '        LDM 3\n        DCL\n        FIM 0,33H\n        SRC 0\n        RDM\n        XCH 4\n        RD2\n'
        source += '        XCH 5\n        STC\n        LDM 1\n        ADM\n        XCH 6\n        CLC\n        LDM 6\n        SBM\n'
        state, _, _ = run(source + end())
        for bank in range(8):
            register, character = (bank * 17) >> 4, (bank * 17) & 15
            row = state['ram'][bank][register * 20:register * 20 + 20]
            self.assertEqual((int(row[character], 16), int(row[18], 16)), (bank + 1, bank + 1))
        self.assertEqual(state['regs'][4:7], [4, 4, 6])
        self.assertEqual((state['acc'], state['carry']), (2, 1))


@unittest.skipUnless(NTV.is_file(), 'build ntv4004 first (m.sh or m.bat)')
class Console(unittest.TestCase):
    def test_output_and_input(self):
        source = ('        FIM 14,0F0H\n        SRC 14\nLOOP:   RDR\n        XCH 0\n        RDR\n        XCH 1\n'
                  '        LD 0\n        WRR\n        LD 1\n        WRR\n        JUN LOOP\n')
        state, output, code = run(source, keys=b'abc\n')
        self.assertEqual((output, code), (b'abc\n', 0))  # LF input becomes CR, CR output becomes LF

    def test_status(self):
        source = ('        FIM 14,0E0H\n        SRC 14\n        RDR\n        XCH 3\n        FIM 14,0F0H\n        SRC 14\n'
                  '        RDR\n        RDR\n        FIM 14,0E0H\n        SRC 14\n        RDR\n        XCH 4\n' + end())
        state, _, _ = run(source, keys=b'A')
        self.assertEqual(state['regs'][3:5], [1, 0])

    def test_port_display(self):
        # -o shows writes to other ROM ports and to RAM output ports, bit 3 first.
        source = ('        FIM 0,30H\n        SRC 0\n        LDM 5\n        WRR\n        LDM 2\n        DCL\n'
                  '        FIM 0,40H\n        SRC 0\n        LDM 0CH\n        WMP\n' + end())
        self.assertEqual(run(source, options=('-o',))[1], b'ROM port 3: .*.*\nRAM bank 2 chip 1: **..\n')
        self.assertEqual(run(source)[1], b'')

    def test_interrupts(self):
        # A timer interrupt forces JMS 003H and ends a HLT; BBS returns, restoring the SRC address.
        handler = '        ORG 0\n        JUN START\n        NOP\n        INC 15\n        BBS\n'
        count = 'START:  FIM 0,0F0H\n        SRC 0\n        EIN\nWAIT:   HLT\n        LD 15\n' + \
                ''.join('        DAC\n' for _ in range(5)) + '        JCN 0CH,WAIT\n        DIN\n' + end()
        state, _, code = run(handler + count, '4040', options=('-I:1000',))
        self.assertEqual((state['regs'][15], state['src'], state['sp'], state['cycles'], code), (5, 0xF0, 0, 5014, 0))
        # Without EIN no interrupt is taken, so HLT ends the program.
        state, _, _ = run(handler + count.replace('        EIN\n', ''), '4040', options=('-I:1000',))
        self.assertEqual((state['regs'][15], state['pc']), (0, 0x9))
        # No interrupt is taken while one is served: a handler longer than the period runs to BBS each time.
        slow = ('        ORG 0\n        JUN START\n        NOP\n        JUN SLOW\nSLOW:   INC 15\n        FIM 0,0\n'
                'SPIN:   ISZ 1,SPIN\n        ISZ 0,SPIN\n        BBS\n')
        spin = 'START:  EIN\nMAIN:   ISZ 3,MAIN\n        DIN\n' + end()
        state, _, code = run(slow + spin, '4040', options=('-I:20',))
        self.assertEqual((state['regs'][15], state['sp'], code), (7, 0, 0))  # one main instruction between each
        # BBS restores the index register bank; a jump to itself waits while an interrupt can still come.
        bank = ('        ORG 0\n        JUN START\n        NOP\n        SB0\n        INC 14\n        LD 14\n'
                '        DAC\n        DAC\n        DAC\n        JCN 0CH,BACK\n        DIN\nBACK:   BBS\n'
                'START:  SB1\n        LDM 9\n        XCH 0\n        EIN\n' + end())
        state, _, code = run(bank, '4040', options=('-I:50',))
        self.assertEqual((state['regs'][14], state['bank1'][0], code), (3, 9, 0))
        result = subprocess.run([str(NTV), '-I:50', 'none.hex'], capture_output=True, timeout=60)
        self.assertIn(b'need the 4040', result.stderr)

    def test_examples(self):
        expected = {
            'hello': b'Hello from the Intel 4004!\n',
            'fib': ''.join(f'{n}\n' for n in fibonacci(70)).encode(),
            'sieve': b'1899 primes.\n',
            'e': e_digits() + b'\ndone.\n',
            'ttt': b'moves: 6493\niterations: 1\n',
        }
        for name, output in expected.items():
            with self.subTest(example=name):
                result = subprocess.run([str(NTV), f'{name}.hex'], cwd=ROOT / 'examples', capture_output=True, timeout=60)
                self.assertEqual((result.stdout.replace(b'\r\n', b'\n'), result.returncode), (output, 0))
        result = subprocess.run([str(NTV), 'echo.hex'], cwd=ROOT / 'examples', input=b'Hi there. More', capture_output=True,
                                timeout=60)
        self.assertEqual(result.stdout, b'HI THERE.')

    def e_math(self, setups, helper):
        source = (ROOT/'examples/e.asm').read_text()
        routines = 'TIMES10:'+source.split('TIMES10:',1)[1].rsplit('        END',1)[0]
        registers = (0,1,2,3,4,5,6,14,15)
        records = []
        # Batch cases in ROM: hundreds of process launches are slow on Windows.
        for start in range(0,len(setups),32):
            batch = setups[start:start+32]
            program = '        JUN TEST\n        ORG 0A0H\n'+routines
            program += '        ORG 200H\nTEST:\n'
            for setup in batch:
                program += setup+f'        JMS {helper}\n        FIM 8,0F0H\n        SRC 8\n'
                for reg in registers:
                    # ASCII 0..?: subtract '0' to recover each raw nibble.
                    program += f'        LDM 3\n        WRR\n        LD {reg}\n        WRR\n'
            _, output, code = run(program+'HALT:   JUN HALT\n')
            self.assertEqual(code,0)
            self.assertEqual(len(output),len(batch)*len(registers))
            for offset in range(0,len(output),len(registers)):
                regs = dict(zip(registers,(ch-48 for ch in output[offset:offset+len(registers)])))
                self.assertEqual((regs[14],regs[15]),(10,11))
                records.append(regs)
        return records

    def test_e_division(self):
        cases = {(n, (n%10)*n + ((n*37//11+3)%n)) for n in range(2,200)}
        for n in (2,3,15,16,17,31,32,127,128,191,192,199):
            cases.update((n,q*n+r) for q in (0,1,8,9) for r in (0,n-1))
        cases.update((1,x) for x in (0,1,15,16,27,255,256,4095))
        cases = sorted(cases)
        setups = [(f'        FIM 0,{n}\n        FIM 2,255\n'
                   f'        FIM 4,{x>>4}\n        FIM 6,{(x&15)<<4}\n'
                   '        FIM 14,0ABH\n        STC\n') for n,x in cases]
        for (n,x),regs in zip(cases,self.e_math(setups,'DIVIDE')):
            with self.subTest(n=n,x=x):
                self.assertEqual((regs[4]*256+regs[5]*16+regs[6],regs[2]*16+regs[3]),divmod(x,n))
                self.assertEqual((regs[0],regs[1]),(n>>4,n&15))

    def test_e_multiply_by_ten(self):
        cases = {(a,a%10) for a in range(256)}
        cases.update((a,x) for a in (0,1,15,16,25,127,128,199,255)
                     for x in (15,16,255,256,4095))
        cases = sorted(cases)
        setups = [(f'        FIM 0,199\n        FIM 4,{x>>4}\n'
                   f'        FIM 6,{(x&15)<<4}\n        FIM 12,{a}\n'
                   '        FIM 14,0ABH\n        STC\n') for a,x in cases]
        for (a,x),regs in zip(cases,self.e_math(setups,'TIMES10')):
            with self.subTest(a=a,x=x):
                self.assertEqual(regs[4]*256+regs[5]*16+regs[6],(x+10*a)&4095)
                self.assertEqual((regs[0],regs[1]),(12,7))

    def test_sieve_flags(self):
        source = (ROOT/'examples/sieve.asm').read_text()
        primes = [True]*16384
        primes[0] = primes[1] = False
        for n in range(2,128):
            if primes[n]:
                for multiple in range(n*n,len(primes),n): primes[multiple] = False
        flags = [primes[2*i+3] for i in range(8191)]+[False]
        self.assertEqual(sum(flags),1899)
        for passes in (1,2,10):
            with self.subTest(passes=passes):
                program = source.replace('LOOPS   EQU 10',f'LOOPS   EQU {passes}')
                state, output, code = run(program,limit=10_000_000)
                self.assertEqual((code,output),(0,b'1899 primes.\n'))
                for bank in range(8):
                    expected = ''.join(format(sum(int(flags[bank*1024+4*c+b])<<b
                                                  for b in range(4)),'X') for c in range(256))
                    # Dump order is 16 main characters, then four status, per chip register.
                    main = ''.join(state['ram'][bank][i:i+16] for i in range(0,320,20))
                    self.assertEqual(main,expected)

    def test_ttt_search_and_counter(self):
        source = (ROOT/'examples/ttt.asm').read_text()
        # Assert each root really returns a draw, without modifying the board
        # or cached count. A wrong score loops until the emulator budget fails.
        checked = source.replace('ROOTDN: FIM 0,ROOTM',
            'ROOTDN: CLC\n        LDM 5\n        SUB 12\n        JCN 4,ROOTOK\n'
            'BAD:    JUN BAD\nROOTOK: FIM 0,ROOTM')
        self.assertNotEqual(checked,source)
        state, output, code = run(checked,limit=2_000_000)
        self.assertEqual((code,output),(0,b'moves: 6493\niterations: 1\n'))
        self.assertEqual(state['ram'][0][300:310],'0'*10)  # board fully undone
        # Exercise carries in the cached binary count separately from search.
        counter = 'ENTER:'+source.split('ENTER:',1)[1].split('COUNTED:',1)[0]
        for count in (0,15,16,255,256,4095,4096,6492,65535):
            with self.subTest(count=count):
                setup = (f'        FIM 6,{(count>>4)&15}\n        FIM 14,{count&15}\n'
                         '        FIM 0,0E0H\n        SRC 0\n'
                         f'        LDM {(count>>8)&15}\n        WR2\n'
                         f'        LDM {(count>>12)&15}\n        WR3\n        JUN ENTER\n'
                         '        ORG 100H\n'+counter+'COUNTED: JUN COUNTED\n')
                state, _, code = run(setup)
                self.assertEqual(code,0)
                high = state['ram'][0][14*20+18:14*20+20]
                actual = (int(high[1],16)<<12)|(int(high[0],16)<<8)|(state['regs'][7]<<4)|state['regs'][15]
                self.assertEqual(actual,(count+1)&65535)

    def test_ttt_decimal_output(self):
        source = (ROOT/'examples/ttt.asm').read_text()
        source = source.replace('        ORG 0\n','        ORG 0\n        JUN SETUP\n',1)
        source = source.replace('        LD 15','TPRNT:  LD 15',1).rsplit('        END',1)[0]
        for count in (0,1,9,10,16,99,100,255,999,1000,4095,6493,9999):
            with self.subTest(count=count):
                setup = ('        ORG 600H\nSETUP:  LDM 0\n        DCL\n'
                         f'        FIM 6,{(count>>4)&15}\n        FIM 14,{count&15}\n'
                         '        FIM 0,0E0H\n        SRC 0\n'
                         f'        LDM {(count>>8)&15}\n        WR2\n'
                         f'        LDM {(count>>12)&15}\n        WR3\n        JUN TPRNT\n')
                _, output, code = run(source+setup)
                self.assertEqual((code,output),(0,f'moves: {count}\niterations: 1\n'.encode()))

    def test_ttt_winner(self):
        from itertools import combinations, product
        lines = ((0,1,2),(3,4,5),(6,7,8),(0,3,6),(1,4,7),(2,5,8),(0,4,8),(2,4,6))
        source = (ROOT/'examples/ttt.asm').read_text()
        routines = source[source.index('; DISPATCH THE LAST MOVE'):].rsplit('        END',1)[0]
        cases = set()
        for piece in (1,2):
            for last in range(9):
                board = [0]*9
                board[last] = piece
                cases.add((tuple(board),last))
                for a,b in combinations([i for i in range(9) if i != last],2):
                    for va,vb in product((1,2),repeat=2):
                        board = [0]*9
                        board[last],board[a],board[b] = piece,va,vb
                        cases.add((tuple(board),last))
                # A completed line elsewhere is not a win through this move.
                for line in lines:
                    if last not in line:
                        board = [0]*9
                        board[last] = piece
                        for cell in line: board[cell] = piece
                        cases.add((tuple(board),last))
        cases = sorted(cases)
        registers = (2,6,7,8,9,10,11,12,13,15)
        for start in range(0,len(cases),24):
            batch = cases[start:start+24]
            program = '        LDM 0\n        DCL\n        JUN TEST\n'+routines
            program += '        ORG 500H\nTEST:\n'
            for board,last in batch:
                program += '        FIM 4,0F0H\n'
                for value in board:
                    program += f'        LDM {value}\n        SRC 4\n        WRM\n        INC 5\n'
                program += ('        FIM 6,5AH\n        FIM 8,67H\n        FIM 10,89H\n'
                            '        FIM 12,0BCH\n        FIM 14,0ABH\n'
                            f'        FIM 4,{240+last}\n        JMS WINNER\n        XCH 2\n'
                            '        FIM 0,0F0H\n        SRC 0\n')
                for reg in registers:
                    program += f'        LDM 3\n        WRR\n        LD {reg}\n        WRR\n'
            _, output, code = run(program+'HALT:   JUN HALT\n')
            self.assertEqual(code,0)
            self.assertEqual(len(output),len(batch)*len(registers))
            for index,(board,last) in enumerate(batch):
                with self.subTest(board=board,last=last):
                    values = [c-48 for c in output[index*10:(index+1)*10]]
                    winner = any(last in line and all(board[i] == board[last] for i in line)
                                 for line in lines)
                    self.assertEqual(values,[int(winner),5,10,6,7,8,9,11,12,11])

    def test_checked_in_examples_match_their_source(self):
        for path in sorted((ROOT / 'examples').glob('*.asm')):
            with self.subTest(example=path.name):
                memory, symbols, _ = asm4.Assembler().assemble(path.read_text(encoding='ascii'))
                self.assertEqual(path.with_suffix('.hex').read_text(encoding='ascii'), asm4.hex_file(memory))
                self.assertEqual(path.with_suffix('.map').read_text(encoding='ascii'), asm4.map_file(symbols))

    def test_errors(self):
        self.assertEqual(run('LOOP:   JUN LOOP2\nLOOP2:  NOP\n        JUN LOOP\n')[2], 2)  # cycle limit
        with tempfile.TemporaryDirectory() as directory:
            Path(directory, 'high.hex').write_text(asm4.hex_file({0x1000: 0}), encoding='ascii')
            result = subprocess.run([str(NTV), 'high.hex'], cwd=directory, capture_output=True, timeout=60)
            self.assertIn(b'needs the 4040', result.stderr)


def e_digits():
    """The 192 digits of e that the spigot prints."""
    with localcontext() as context:
        context.prec = 220
        return str(Decimal(1).exp()).replace('.', '')[:192].encode()


def fibonacci(count):
    a, b = 1, 1
    for _ in range(count):
        yield a
        a, b = b, a + b


if __name__ == '__main__':
    unittest.main()
