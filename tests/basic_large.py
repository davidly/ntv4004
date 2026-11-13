#!/usr/bin/env python3
"""Exercise compact program storage and the iterative native BASIC TTT search."""
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
from basic import Basic, ROOT
sys.path.insert(0, str(ROOT/'basic'))
from build import compile_profile


class Large(unittest.TestCase):
    execute = Basic.execute

    @classmethod
    def setUpClass(cls):
        cls.image = ROOT/'basic/large.hex'

    def check(self, program, expected):
        self.assertEqual(self.execute(program), 'BASIC4L\n'+expected)

    def test_rebuild_and_hardware_limits(self):
        assembly, image, symbols, compiler = compile_profile(True)
        for suffix, content in (('asm',assembly), ('hex',image), ('map',symbols)):
            self.assertEqual(content, (ROOT/f'basic/large.{suffix}').read_text())
        self.assertLessEqual(compiler.rom_end, 4096)
        self.assertLessEqual(compiler.memory_top, 2048)
        self.assertLessEqual(compiler.slots_used, 128)

    def test_packing_and_branching(self):
        source = ('1 LET T=0\n2 LET T=T+1\n3 IF T<3 THEN 2\n'
                  '4 IF 0=1 THEN 99\n5 GOTO 7\n6 PRINT "wrong"\n'
                  '7 PRINT "Mixed case: spaces stay";\n8 PRINT T\n255 END\nRUN\n')
        for text in (source, source.replace('\n','\r\n')):
            self.check(text, 'Mixed case: spaces stay3\n')
        self.check('1 LET @(63)=65535\n2 PRINT @(63)+1\nRUN\n','0\n')

        self.check('1 REM \"comment\n2 PRINT \"Mixed words\"\nRUN\n','Mixed words\n')

    def test_integer_tokens(self):
        # Cross both token-width transitions and the unsigned word boundary.
        values = (0, 1, 9, 10, 99, 100, 126, 127, 128, 129, 255, 256,
                  16382, 16383, 16384, 16385, 32767, 32768, 65534, 65535)
        program = ''.join(f'{i} PRINT {n}\n' for i, n in enumerate(values, 1))
        self.check(program+'RUN\n', ''.join(f'{n}\n' for n in values))
        self.check('1 LET A=16384\n2 LET @(63)=65535\n'
                   '3 PRINT @(63)+2\n4 PRINT 128*129\n5 PRINT 65535/255\n'
                   '6 PRINT "0 127 128 65535"\n7 PRINT 00000127\n'
                   '8 PRINT 1 2\nRUN\n',
                   '1\n16512\n257\n0 127 128 65535\n127\n12\n')
        self.check('1 GOTO 128\n127 PRINT "wrong"\n128 PRINT 128\n'
                   '129 IF 65535>16383 THEN 255\n254 PRINT "wrong"\n'
                   '255 PRINT 65535\nRUN\n', '128\n65535\n')
        # Overflow is diagnosed by execution; an unreachable bad literal is harmless.
        self.check('1 GOTO 3\n2 LET A=65536\n3 PRINT 42\nRUN\n', '42\n')
        for literal in ('65536', '999999999999999999999999'):
            with self.subTest(literal=literal):
                self.check('1 LET A='+literal+'\nRUN\n', '?ERROR 2\n')
        # Integer tokens allow this source to fit the 832-byte program buffer.
        self.check(''.join(f'{i} PRINT 127\n' for i in range(1,151))+'RUN\n',
                   '127\n'*150)

    def test_branch_cache(self):
        # Nine distinct targets force eviction from the eight-entry cache.
        # Weighted nodes distinguish a wrong cached offset from a valid jump.
        targets = (10, 100, 40, 190, 70, 220, 130, 240, 160)
        lines = {1: 'LET C=0', 2: 'LET T=0', 250: 'PRINT C',
                 251: 'PRINT T', 255: 'END'}
        for weight, label in enumerate(targets, 1):
            lines[label] = 'LET C=C+1'
            lines[label+1] = f'LET T=T+{weight}'
            lines[label+2] = 'IF C>=50 THEN 250'
            lines[label+3] = f'GOTO {targets[weight % len(targets)]}'
        program = ''.join(f'{label} {text}\n' for label, text in sorted(lines.items()))
        self.check(program+'RUN\n', '50\n240\n')
        for target in (0, 256, 65535):
            with self.subTest(target=target):
                self.check(f'1 GOTO {target}\nRUN\n', '?ERROR 4\n')

    def test_storage_boundaries(self):
        self.check('1 REM '+'x'*829+'\nRUN\n','')  # header, R, body, NUL = 832
        self.check('1 REM '+'x'*830+'\nRUN\n','?ERROR 6\n')
        self.check(''.join(f'{i} REM\n' for i in range(1,256))+'RUN\n','')
        for source, code in (('256 END',5), ('0 END',5), ('2 END\n1 END',5),
                             ('1 END\n1 END',5), ('1 PRINT @(64)',7),
                             ('1 GOTO 2',4), ('1 INPUT A',1), ('1 PRINT 1:2',1),
                             ('1 PRINT "a\x00b"',1), ('1 LET A=1/0',3)):
            with self.subTest(source=source):
                self.check(source+'\nRUN\n',('\n' if source == '1 PRINT @(64)' else '')+f'?ERROR {code}\n')

    def test_ttt(self):
        source = (ROOT/'basic/examples/ttt.bas').read_text()
        self.assertEqual(self.execute(source, budget=10_000_000_000, timeout=300),
                         'BASIC4L\n6493 moves\n')


if __name__ == '__main__':
    # Imported Basic is a helper, not a second run of its expensive benchmarks.
    del Basic
    unittest.main()
