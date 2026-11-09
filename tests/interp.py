#!/usr/bin/env python3
"""Run programs in ntv4004 and in Intel's INTERP/4 and INTERP/40 1.1, and require identical results.

Seeded random programs cover the instruction set; the examples must also
print the same output in the same instruction cycles.
"""
from decimal import Decimal, localcontext
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / 'intel'))
import asm4  # noqa: E402
import interp4  # noqa: E402
import mac4  # noqa: E402

NTV = ROOT / ('ntv4004.exe' if os.name == 'nt' else 'ntv4004')
READY = NTV.is_file() and all((mac4.UPSTREAM / name).is_file() for name in ('int4.sav', 'int40.sav'))
VALUE = re.compile(r'([0-9A-F]+)H')

SIMPLE = ['NOP', 'IAC', 'DAC', 'CMA', 'CMC', 'CLB', 'CLC', 'STC', 'RAL', 'RAR', 'TCC', 'TCS', 'DAA', 'KBP']
RAM = ['WRM', 'RDM', 'ADM', 'SBM', 'WR0', 'WR1', 'WR2', 'WR3', 'RD0', 'RD1', 'RD2', 'RD3', 'WMP', 'WRR']
EXTRA_4040 = ['OR4', 'OR5', 'AN6', 'AN7', 'SB0', 'SB1', 'LCR', 'EIN', 'DIN']


def random_program(seed, cpu):
    """A page-0 program of random instructions, with forward branches and calls to page 1."""
    rng = random.Random(seed)
    lines, pending, labels = [], [], 0

    def label():
        nonlocal labels
        labels += 1
        return f'L{labels}'

    for pair in range(0, 16, 2):
        lines.append(f'        FIM {pair},{rng.randrange(256)}')
    lines.append(f'        LDM {rng.randrange(16)}')
    if rng.random() < 0.5:
        lines.append('        STC')
    for _ in range(rng.randrange(25, 55)):
        # Place the targets of earlier forward branches.
        for item in [p for p in pending if p[0] <= 0]:
            lines.append(f'{item[1]}:')
            pending.remove(item)
        pending = [(steps - 1, name) for steps, name in pending]
        kind = rng.random()
        if kind < 0.25:
            lines.append(f'        {rng.choice(SIMPLE)}')
        elif kind < 0.45:
            lines.append(f'        {rng.choice(["ADD", "SUB", "LD", "XCH", "INC"])} {rng.randrange(16)}')
        elif kind < 0.5:
            lines.append(f'        LDM {rng.randrange(16)}')
        elif kind < 0.55:
            lines.append(f'        FIM {rng.randrange(0, 16, 2)},{rng.randrange(256)}')
        elif kind < 0.68:
            # The ports and banks INTERP numbers like the MCS-40 manual: banks 0 to 2.
            if rng.random() < 0.3:
                lines += [f'        LDM {rng.randrange(3)}', '        DCL']
            lines += [f'        SRC {rng.randrange(0, 16, 2)}', f'        {rng.choice(RAM)}']
        elif kind < 0.76:
            name = label()
            lines.append(f'        JCN {rng.randrange(16)},{name}')
            pending.append((rng.randrange(1, 4), name))
        elif kind < 0.81:
            name = label()
            lines.append(f'        ISZ {rng.randrange(16)},{name}')
            pending.append((rng.randrange(1, 4), name))
        elif kind < 0.86:
            lines.append(f'        JMS S{rng.randrange(4)}')
        elif kind < 0.9:
            lines.append(f'        FIN {rng.randrange(0, 16, 2)}')
        elif kind < 0.93:
            name, pair = label(), rng.randrange(0, 16, 2)
            lines += [f'        FIM {pair},{name}', f'        JIN {pair}']
            pending.append((rng.randrange(1, 3), name))
        elif cpu == '4040':
            lines.append(f'        {rng.choice(EXTRA_4040)}')
        else:
            lines.append(f'        {rng.choice(SIMPLE)}')
    lines += [f'{name}:' for _, name in pending]
    lines.append('DONE:   JUN DONE')
    lines.append('        ORG 100H')
    for number in range(4):
        lines.append(f'S{number}:')
        for _ in range(rng.randrange(1, 5)):
            if rng.random() < 0.6:
                lines.append(f'        {rng.choice(SIMPLE)}')
            else:
                lines.append(f'        {rng.choice(["ADD", "SUB", "XCH", "INC"])} {rng.randrange(16)}')
        lines.append(f'        BBL {rng.randrange(16)}')
    lines.append('        END')
    return '\n'.join(lines) + '\n'


def run_ntv(memory, cpu):
    """Return the final state, port writes and console output from ntv4004."""
    with tempfile.TemporaryDirectory(prefix='ntv4004 test ') as directory:
        Path(directory, 'p.hex').write_text(asm4.hex_file(memory), encoding='ascii')
        result = subprocess.run([str(NTV), *(['-4'] if cpu == '4040' else []), '-r', '-t', '-n:1000000', 'p.hex'],
                                cwd=directory, capture_output=True, text=True, timeout=60)
        log = Path(directory, 'ntv4004.log').read_text(encoding='ascii')
    if result.returncode:
        raise AssertionError(result.stderr)
    report = result.stderr
    found = re.search(r'acc (\w) carry (\d) regs (\w{16}) (\w{8}) pc \w+ sp (\d) stack((?: \w{3}){8}) '
                      r'src (\w\w) cm (\d) bank \d rombank \d cycles (\d+)', report)
    if not found:
        raise AssertionError(report)
    ram = {int(line.split()[1]): line.split()[2] for line in report.splitlines() if line.startswith('ram ')}
    ports = []
    for line in log.splitlines():
        rom = re.match(r'output ROM port (\d+), value ([0-9a-f])', line)
        ramport = re.match(r'output RAM bank (\d+) chip (\d+) port, value ([0-9a-f])', line)
        if rom:
            ports.append((int(rom.group(1)), int(rom.group(2), 16)))
        elif ramport:
            ports.append((0x1F + 4 * int(ramport.group(1)) + int(ramport.group(2)), int(ramport.group(3), 16)))
    acc, carry, regs, bank1, sp, stack, src, cm, cycles = found.groups()
    return {
        'acc': int(acc, 16), 'carry': int(carry), 'regs': regs, 'bank1': bank1, 'sp': int(sp),
        # Levels above the pointer hold stale returns, which INTERP records differently.
        'stack': [int(s, 16) for s in stack.split()][:int(sp) + 1], 'src': int(src, 16), 'cm': int(cm),
        'ram': ram[int(cm)], 'cycles': int(cycles), 'ports': ports,
    }


def run_interp(memory, symbols, cpu):
    """Return the same state as run_ntv from INTERP."""
    end = interp4.jump_to_self(memory)
    assert len(end) == 1
    text = interp4.session(memory, symbols, cpu, f'BREAK 0{end[0]:X}H.\nCYCLE 0F4240H.\nGO.\nTIME.\nDISPLAY CPU.\n'
                                                 'DISPLAY RAM 0 TO 0FH.\n')
    lines = [line for line in text.splitlines() if line.strip()]
    if not any(line.startswith('BREAK AT') for line in lines):
        raise AssertionError('INTERP did not reach the end:\n' + text[-1500:])
    ports = []
    for line in lines:
        match = interp4.PORT.match(line.strip())
        if match:
            ports.append((int(match.group(1), 16), int(match.group(2), 16)))
    cycles = int(re.search(r'TIME=(\d+)', text).group(1))
    top = lines.index(next(line for line in lines if line.strip().startswith('C AC')))
    first = [int(v, 16) for v in VALUE.findall(lines[top + 1])]
    second = [int(v, 16) for v in VALUE.findall(lines[top + 3])]
    ram = ''
    for line in lines[top + 4:top + 20]:
        values = [int(v, 16) for v in VALUE.findall(line)]
        ram += ''.join(f'{v:X}' for v in values[1:])
    return {
        'acc': first[1], 'carry': first[0], 'regs': ''.join(f'{v:X}' for v in first[2:18]),
        'bank1': ''.join(f'{v:X}' for v in second[:8]), 'sp': second[8], 'stack': second[9:10 + second[8]],
        'src': first[18], 'cm': first[19] & 7, 'ram': ram, 'cycles': cycles, 'ports': ports,
    }


@unittest.skipUnless(READY, 'needs a built ntv4004 and the INTERP/4 images; see intel/README.md')
class Interp(unittest.TestCase):
    def compare(self, source, cpu):
        memory, symbols, _ = asm4.Assembler(cpu).assemble(source)
        ntv, intel = run_ntv(memory, cpu), run_interp(memory, symbols, cpu)
        self.assertEqual(ntv, intel, source)

    def test_random_4004(self):
        for seed in range(150):
            with self.subTest(seed=seed):
                self.compare(random_program(seed, '4004'), '4004')

    def test_random_4040(self):
        for seed in range(150):
            with self.subTest(seed=seed):
                self.compare(random_program(1000 + seed, '4040'), '4040')

    def run_both(self, path, keys=b''):
        memory, symbols = interp4.load_program(path, '4004')
        output, cycles, _ = interp4.run_program(memory, symbols, keys=keys, limit=20_000_000)
        result = subprocess.run([str(NTV), '-p', path.name], cwd=path.parent, input=keys, capture_output=True, timeout=600)
        self.assertEqual(result.stdout.replace(b'\r\n', b'\n'), output)
        self.assertIn(f'{cycles} instruction cycles,'.encode(), result.stderr)
        return output

    def test_examples(self):
        examples = ROOT / 'examples'
        self.assertEqual(self.run_both(examples / 'hello.hex'), b'Hello from the Intel 4004!\n')
        a, b, numbers = 1, 1, []
        for _ in range(70):
            numbers.append(a)
            a, b = b, a + b
        self.assertEqual(self.run_both(examples / 'fib.hex'), ''.join(f'{n}\n' for n in numbers).encode())
        self.assertEqual(self.run_both(examples / 'echo.hex', b'Hello, 4004 world.\n'), b'HELLO, 4004 WORLD.')
        # The benchmarks print the same as the 8008 and 8080 versions.
        self.assertEqual(self.run_both(examples / 'sieve.hex'), b'1899 primes.\n')
        with localcontext() as context:
            context.prec = 220
            digits = str(Decimal(1).exp()).replace('.', '')[:192].encode()
        self.assertEqual(self.run_both(examples / 'e.hex'), digits + b'\ndone.\n')
        self.assertEqual(self.run_both(examples / 'ttt.hex'), b'moves: 6493\niterations: 1\n')
        # C compiled by cc4.py, including ttt's recursion through the save stack in RAM.
        compiled = examples / 'c'
        self.assertEqual(self.run_both(compiled / 'hello.hex'), b'Hello from C on the Intel 4004!\n')
        self.assertEqual(self.run_both(compiled / 'ttt.hex'), b'move count:      6493\niteration count: 1\n')
        self.assertTrue(self.run_both(compiled / 'queens.hex').endswith(b'\n92 solutions\n'))
        self.assertTrue(self.run_both(compiled / 'hanoi.hex').endswith(b'10 discs: 1023 moves\n'))

    def test_status_port(self):
        # Poll port 14 before each character; INTERP's answers follow the program's reads.
        source = """        FIM 14,0E0H
        FIM 12,0F0H
POLL:   SRC 14
        RDR
        JCN 4,DONE
        SRC 12
        RDR
        XCH 0
        RDR
        XCH 1
        LD 0
        WRR
        LD 1
        WRR
        INC 2
        JUN POLL
DONE:   JUN DONE
        END
"""
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory, 'status.hex')
            memory, symbols, _ = asm4.Assembler().assemble(source)
            path.write_text(asm4.hex_file(memory), encoding='ascii')
            self.assertEqual(self.run_both(path, b'4004'), b'4004')


if __name__ == '__main__':
    unittest.main()
