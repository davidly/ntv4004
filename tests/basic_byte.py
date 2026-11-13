#!/usr/bin/env python3
"""Check the byte-array BASIC profile, including the standard BASIC behavior."""
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
from basic import Basic, ROOT
sys.path.insert(0, str(ROOT/'basic'))
from build import compile_profile


class Byte(Basic):
    banner = 'BASIC4B'
    byte_array = True
    program_lines = 48
    program_bytes = 512

    @classmethod
    def setUpClass(cls):
        cls.image = ROOT/'basic/byte.hex'

    def test_array_and_scalar_storage(self):
        self.check('10 LET A=199\n20 LET @(A)=65535\n30 LET @(0)=256\n'
                   '40 LET Z=65535\n50 PRINT @(A)\n60 PRINT @(0)\n'
                   '70 PRINT Z\n80 PRINT @(A)+1\n90 LET @(A)=@(A)+1\n'
                   '100 PRINT @(199)\n110 PRINT A\n120 END\nRUN\n',
                   '255\n0\n65535\n256\n0\n199\n')
        self.check('10 INPUT A\n20 INPUT @(0)\n30 INPUT @(199)\n'
                   '40 PRINT A\n50 PRINT @(0)\n60 PRINT @(199)\n'
                   '70 END\nRUN\n65535\n256\n65535\n',
                   '? ? ? 65535\n0\n255\n')
        for index in ('200', '256', '65535', '99999'):
            with self.subTest(index=index):
                code = 2 if index == '99999' else 7
                self.check(f'10 PRINT @({index})\nRUN\n', f'\n?ERROR {code}\n')
        self.check('10 LET A=65535\n20 PRINT @(A)\nRUN\n', '\n?ERROR 7\n')

    def test_byte_store_boundaries(self):
        values = (0, 1, 127, 128, 255, 256, 257, 511, 32768, 65535)
        program = '10 INPUT A\n20 LET @(199)=A\n30 PRINT A\n40 PRINT @(199)\n50 END\n'
        for value in values:
            with self.subTest(value=value):
                self.check(program+f'RUN\n{value}\n', f'? {value}\n{value%256}\n')

    def test_run_and_new_clear_both_stores(self):
        output = self.console('LET A=65535\nLET Z=32768\nLET @(0)=255\n'
            'LET @(199)=128\nNEW\nPRINT A\nPRINT Z\nPRINT @(0)\nPRINT @(199)\n'
            '10 PRINT @(199)\n20 LET @(199)=255\n30 END\nRUN\nRUN\nBYE\n')
        self.assertIn('> NEW\n> PRINT A\n0\n> PRINT Z\n0\n> PRINT @(0)\n0\n> PRINT @(199)\n0\n', output)
        self.assertEqual(output.count('> RUN\n0\nREADY (UPPERCASE)\n'), 2)
        self.assertNotIn('?ERROR', output)

    def test_input_error_preserves_byte(self):
        output = self.console('LET @(199)=23\nINPUT @(199)\n65536\n'
                              'PRINT @(199)\nINPUT A\n65535\nPRINT A\nBYE\n')
        self.assertEqual(output.count('?ERROR 2'), 1)
        self.assertIn('> PRINT @(199)\n23\n', output)
        self.assertIn('> PRINT A\n65535\n', output)
        for statement in ('LET @(200)=1', 'INPUT @(200)'):
            with self.subTest(statement=statement):
                self.check('10 '+statement+'\nRUN\n', '?ERROR 7\n')

    def test_build_profile(self):
        with self.assertRaises(ValueError):
            compile_profile(large=True, byte_array=True)
        _, _, _, compiler = compile_profile(byte_array=True)
        self.assertEqual(compiler.memory_top, 2008)
        self.assertLessEqual(compiler.rom_end, 4096)
        self.assertLessEqual(compiler.slots_used, 128)


if __name__ == '__main__':
    del Basic  # Run the inherited tests once, through Byte.
    unittest.main()
