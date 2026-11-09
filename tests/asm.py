#!/usr/bin/env python3
"""Check that asm4.py assembles exactly the bytes and symbols that Intel's MAC4 and MAC40 do."""
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / 'intel'))
import asm4  # noqa: E402
import mac4  # noqa: E402

READY = all((mac4.UPSTREAM / name).is_file() for name in ('mac4.sav', 'mac40.sav'))


def every_instruction(cpu):
    """Every instruction with every register, data or condition operand."""
    lines = ['        ORG 0']
    for name in sorted(asm4.IMPLIED) + (sorted(asm4.IMPLIED_4040) if cpu == '4040' else []):
        lines.append(f'        {name}')
    for name in sorted(asm4.REGISTER):
        lines += [f'        {name} {r}' for r in range(16)]
    for name in sorted(asm4.PAIR):
        lines += [f'        {name} {r}' for r in range(0, 16, 2)]
    lines += [f'        FIM {r},{r * 17 + 3}' for r in range(0, 16, 2)]
    for name in sorted(asm4.DATA):
        lines += [f'        {name} {d}' for d in range(16)]
    lines += ['        ORG 200H', 'HERE:   NOP']
    lines += [f'        JCN {c},HERE' for c in range(16)]
    lines += [f'        ISZ {r},HERE' for r in range(16)]
    lines += ['        JUN 0', '        JUN 0FFFH', '        JMS 123H', '        JMS HERE', '        END']
    return '\n'.join(lines) + '\n'


DIRECTIVES = '''K       EQU 5
L       SET 3
        ORG 10H
A1:     DB 'AB',1,K+1
        DB 'X','IT''S'
        LDM K*2-L
L       SET 4
        LDM L
        LDM 'A' AND 0FH
        FIM 4,A1+1
        FIM 6,(A1 SHR 4)
        FIM 8,0FFH XOR 0F0H OR 1
        JUN $+2
        DS 3
        LDM 1011B
        LDM 17Q
        LDM 17O
        LDM 10D
        LDM 13 MOD 5
        LDM 3 SHL 2
        LDM 24/5
        LDM -1 AND 0FH
        IF K-5
        LDM 1
        ENDIF
        IF K
        LDM 2
        ENDIF
LONGNAME:  NOP
        JUN LONGNAME
        ORG 0FCH
        JCN 4,A1
        JCN 0CH,$+2
        END
'''


@unittest.skipUnless(READY, 'needs the MAC4 and MAC40 images; see intel/README.md')
class Assembler(unittest.TestCase):
    def compare(self, source, cpu='4004'):
        memory, symbols, _ = mac4.assemble_source(source, cpu)
        ours, our_symbols, _ = asm4.Assembler(cpu).assemble(source)
        self.assertEqual(ours, memory)
        self.assertEqual({name[:5]: value for name, value in our_symbols.items()}, symbols)

    def test_every_instruction(self):
        self.compare(every_instruction('4004'))

    def test_every_4040_instruction(self):
        self.compare(every_instruction('4040'), '4040')

    def test_directives_and_expressions(self):
        self.compare(DIRECTIVES)

    def test_examples(self):
        for path in sorted((ROOT / 'examples').glob('*.asm')):
            with self.subTest(example=path.name):
                source = path.read_text(encoding='ascii')
                self.compare(source, '4040' if '4040' in path.stem else '4004')

    def test_errors(self):
        for source, message in (('        LDM 16\n', 'out of range'), ('        FIM 3,1\n', 'even register'),
                                ('        HLT\n', '4040 instruction'), ('        JUN NOWHERE\n', 'undefined'),
                                ('        ORG 0FEH\n        ISZ 2,0\n', 'page'), ('        ORG 0FEH\n        JCN 4,$\n', 'page'), ('SUB:    NOP\n', 'reserved'),
                                ('LONGNAME: NOP\nLONGNAMX: NOP\n', 'same symbol'), ('LONGNAME: JUN LONGN\n', 'same symbol'), ('A:  NOP\nA:  NOP\n', 'more than once')):
            with self.subTest(source=source), self.assertRaisesRegex(asm4.AssemblyError, message):
                asm4.Assembler().assemble(source)


if __name__ == '__main__':
    unittest.main()
