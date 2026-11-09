#!/usr/bin/env python3
"""Run BASIC source through the native 4004 interpreter, without a host parser."""
from pathlib import Path
import os
import random
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import asm4
import cc4

HOST = ROOT / ('ntv4004.exe' if os.name == 'nt' else 'ntv4004')
IMAGE = ROOT / 'basic/basic.hex'


class Basic(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.image = IMAGE

    def execute(self, source, budget=5_000_000, status=0, timeout=30):
        with tempfile.TemporaryDirectory(prefix='4004 BASIC ') as directory:
            path = Path(directory, 'input.bas')
            path.write_bytes(source.encode('ascii'))
            result = subprocess.run([str(HOST), f'-n:{budget}', '-l:'+str(path), str(self.image)],
                                    capture_output=True, timeout=timeout)
        self.assertEqual(result.returncode, status, result.stderr)
        return result.stdout.decode('ascii').replace('\r\n', '\n')

    def check(self, program, expected):
        self.assertEqual(self.execute(program), 'BASIC4\n'+expected)

    def test_rebuild_and_hardware_limits(self):
        source = ROOT / 'basic/basic.c'
        assembly, compiler = cc4.compile_source(source.read_text(), source.stem, size=True)
        memory, symbols, _ = asm4.Assembler('4004').assemble(assembly)
        self.assertEqual(assembly, source.with_suffix('.asm').read_text())
        self.assertEqual(asm4.hex_file(memory), IMAGE.read_text())
        self.assertEqual(asm4.map_file(symbols), source.with_suffix('.map').read_text())
        self.assertLessEqual(compiler.rom_end, 4096)
        self.assertLessEqual(compiler.memory_top, 2048)
        self.assertLessEqual(compiler.slots_used, 128)
        self.assertTrue(compiler.shared_accesses)
        for stub in compiler.shared_accesses:
            self.assertNotIn('JMS', stub)
            self.assertIn('JUN Q', stub)

    def test_segmented_sieve(self):
        source = (ROOT/'basic/examples/sieve.bas').read_text()
        # The full benchmark retains ten passes over indices 0..8190.
        primes = sum(all(n%d for d in range(2, int(n**0.5)+1))
                     for n in range(3, 16384, 2))
        self.assertEqual(primes, 1899)
        self.check_program_limits(source)
        self.assertEqual(self.execute(source, budget=12_000_000_000, timeout=300),
                         f'BASIC4\n{primes} primes.\n')

    def check_program_limits(self, source):
        lines = source.splitlines()
        self.assertEqual(lines[-1], 'RUN')
        self.assertLessEqual(len(lines)-1, 32)
        self.assertLessEqual(sum(len(line.split(' ',1)[1])+1 for line in lines[:-1]), 384)

    def test_sieve_segment_boundaries(self):
        source = (ROOT/'basic/examples/sieve.bas').read_text()
        for count in (0, 1, 2, 31, 199, 200, 201, 399, 400, 401):
            program = source.replace('8191', str(count)).replace('IFT<10', 'IFT<1')
            expected = sum(all(n%d for d in range(2, int(n**0.5)+1))
                           for n in range(3, 2*count+2, 2))
            with self.subTest(count=count):
                self.assertEqual(self.execute(program, budget=100_000_000),
                                 f'BASIC4\n{expected} primes.\n')

    def test_e_spigot(self):
        from decimal import Decimal, localcontext
        source = (ROOT/'basic/examples/e.bas').read_text()
        with localcontext() as context:
            context.prec = 220
            digits = str(Decimal(1).exp()).replace('.', '')[:192]
        self.assertEqual(self.execute(source, budget=1_200_000_000),
                         'BASIC4\n'+digits+'\ndone\n')

    def test_array_and_scalar_storage(self):
        self.check('10 LET A=199\n20 LET @(A)=65535\n30 LET @(0)=3\n'
                   '40 PRINT @(A)\n50 PRINT @(0)\n60 PRINT A\n70 END\nRUN\n',
                   '65535\n3\n199\n')
        self.check('10 LET I=17\n20 INPUT @(I)\n30 PRINT @(17)\n40 END\nRUN\n1234\n',
                   '? 1234\n')
        for statement, code in (('LET @(200)=1',7), ('PRINT @(65535)',7),
                                ('PRINT @(99999)',2), ('LET @()=1',1),
                                ('PRINT @(1+1)',1), ('INPUT @(200)',7)):
            output = self.execute('10 '+statement+'\n20 END\nRUN\n')
            self.assertTrue(output.endswith(f'?ERROR {code}\n'),output)

    def test_trailing_semicolon(self):
        self.check('10 PRINT "Hello" ;\n20 PRINT 2+3 ;\n30 PRINT ""\n'
                   '40 PRINT "done"\n50 END\nRUN\n','Hello5\ndone\n')

    def test_examples(self):
        for name, expected in (
                ('hello', 'HELLO FROM BASIC\n'), ('count', '1\n2\n3\n4\n5\n'),
                ('fib', 'FIBONACCI\n0\n1\n1\n2\n3\n5\n8\n13\n21\n34\n'),
                ('squares', '1\n4\n9\n16\n25\n')):
            with self.subTest(name=name):
                self.check((ROOT/f'basic/examples/{name}.bas').read_text(), expected)

    def test_input_lf_crlf_and_multiple_variables(self):
        program = (ROOT/'basic/examples/input.bas').read_text()
        for source in (program, program.replace('\n', '\r\n')):
            self.check(source, 'ENTER A NUMBER\n? 43\n')
        self.check('10 INPUT A\n20 INPUT Z\n30 PRINT A+Z\n40 END\nRUN\n 2\n\n3\n',
                   '? ? 5\n')

    def test_precedence_and_unsigned_wrap(self):
        for expression, expected in (('2+3*4', 14), ('20/3/2', 3), ('9-3-2', 4),
                                     ('65535+1', 0), ('0-1', 65535), ('65535*2', 65534),
                                     ('0*65535', 0), ('65535/255', 257)):
            with self.subTest(expression=expression):
                self.check(f'10 PRINT {expression}\n20 END\nRUN\n', str(expected)+'\n')
        self.check('10 PRINT A+Z\n20 LET Z=65535\n30 PRINT Z\n40 END\nRUN\n',
                   '0\n65535\n')

    def test_comparisons_and_goto(self):
        rng = random.Random(4004)
        cases = [(0, 0), (65535, 0), (0, 65535), (32767, 32768)]
        cases += [(rng.randrange(65536), rng.randrange(65536)) for _ in range(12)]
        for left, right in cases:
            for op, answer in (('=', left==right), ('<', left<right), ('<=', left<=right),
                               ('>', left>right), ('>=', left>=right)):
                source = (f'10 IF {left}{op}{right} THEN 40\n20 PRINT 0\n30 GOTO 50\n'
                          '40 PRINT 1\n50 END\nRUN\n')
                with self.subTest(left=left,right=right,op=op):
                    self.check(source, str(int(answer))+'\n')
        self.check('10 IF 0=1 THEN 999\n20 PRINT 1\n30 END\nRUN\n', '1\n')

    def test_program_boundaries(self):
        self.check('10 REM '+'x'*379+'\nRUN\n', '')  # 383 bytes plus terminator
        self.check('10 REM '+'x'*379+'\n20 \nRUN\n', '?ERROR 6\n')
        self.check('10 REM '+'x'*380+'\nRUN\n', '?ERROR 6\n')
        lines=''.join(f'{i} REM\n' for i in range(1, 33))
        self.check(lines+'RUN\n', '')
        self.check(lines+'33 REM\nRUN\n', '?ERROR 5\n')
        self.check('65535 PRINT 1\nRUN\n', '1\n')
        # A final empty statement fills the last byte exactly; reject it safely.
        self.check('10 REM '+'x'*378+'\n20 \nRUN\n', '?ERROR 1\n')

    def test_errors(self):
        cases = (
            ('10 PRINT 65536\n20 END\nRUN\n', '\n?ERROR 2\n'),
            ('10 PRINT 1/0\n20 END\nRUN\n', '\n?ERROR 3\n'),
            ('10 GOTO 11\nRUN\n', '?ERROR 4\n'),
            ('20 END\n10 END\nRUN\n', '?ERROR 5\n'),
            ('10 END\n10 END\nRUN\n', '?ERROR 5\n'),
            ('0 END\nRUN\n', '?ERROR 5\n'),
            ('65536 END\nRUN\n', '?ERROR 2\n'),
            ('10 IF 1\nRUN\n', '?ERROR 1\n'),
            ('10 LET\nRUN\n', '?ERROR 1\n'),
            ('10 \nRUN\n', '?ERROR 1\n'),
            ('10 PRINT "UNCLOSED\nRUN\n', 'UNCLOSED\n?ERROR 1\n'),
            ('10 LET AA=1\nRUN\n', '?ERROR 1\n'),
            ('10 END EXTRA\nRUN\n', '?ERROR 1\n'),
            ('10 INPUT A\n20 END\nRUN\nx\n', '? ?ERROR 1\n'),
            ('10 INPUT A\n20 END\nRUN\n65536\n', '? ?ERROR 2\n'),
        )
        for source, expected in cases:
            with self.subTest(source=source):
                self.check(source, expected)

    def test_infinite_basic_loop_obeys_emulator_budget(self):
        self.assertEqual(self.execute('10 GOTO 10\nRUN\n', budget=100_000, status=2), 'BASIC4\n')


if __name__ == '__main__':
    unittest.main()
