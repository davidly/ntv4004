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
