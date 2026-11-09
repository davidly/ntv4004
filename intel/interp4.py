#!/usr/bin/env python3
"""Run a 4004 or 4040 program in Intel's INTERP/4 or INTERP/40 1.1 simulator.

  interp4.py prog.asm              assemble with MAC4 and run in INTERP/4
  interp4.py prog.hex              run an Intel HEX image (with prog.map, if present)
  interp4.py --4040 prog.asm       MAC40 and INTERP/40

INTERP prints each ROM and RAM port write. The console follows ntv4004:
ROM port 15 takes a character as two nibbles, high first, and returns
input the same way; ROM port 14 reads 1 when input is ready. The program
ends at its JUN to itself, where INTERP stops at a breakpoint.
"""
import argparse
import os
from pathlib import Path
import re
import sys
import tempfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import mac4  # noqa: E402
from pdp10 import NATIVE, PDP10  # noqa: E402

IMAGES = {'4004': 'int4.sav', '4040': 'int40.sav'}
CONSOLE, STATUS = 15, 14
PORT = re.compile(r'^PORT ([0-9A-F]+)H = ([0-9A-F]+)H$')
ASKED = re.compile(r'^PORT ([0-9A-F]+)H\.\.\.$')
TIME = re.compile(r'^TIME=(\d+) ')


class SimulationError(Exception):
    pass


def jump_to_self(memory):
    """Addresses of JUN instructions that jump to themselves, the program exits."""
    return [a for a, op in memory.items() if op >> 4 == 4 and ((op & 15) << 8 | memory.get(a + 1, 0)) == a]


def session(memory, symbols, cpu='4004', commands='', budget=2_000_000_000):
    """Run INTERP with commands after loading; return its transcript."""
    with tempfile.TemporaryDirectory(prefix='interp4-') as directory:
        Path(directory, 'FOR21.DAT').write_text(mac4.bnpf_object(memory, symbols), encoding='ascii')
        image = mac4.UPSTREAM / IMAGES[cpu]
        if not image.is_file():
            raise SimulationError(f'{image} not found; see intel/README.md')
        # The object file holds the symbol table (TO unit 3) and then BNPF (unit 3).
        runner = PDP10(image, f'$F\nLOAD 0 3 TO 3.\nBASE HEX.\n{commands}$E\n', directory)
        try:
            native = NATIVE.is_file() and not os.environ.get('PDP10_PYTHON')
            text = runner.run_native(budget) if native else runner.run(budget)
        except (RuntimeError, OSError, StopIteration, ZeroDivisionError) as error:
            raise SimulationError(f'{image.name}: {error}\n{runner.output.getvalue()[-2000:]}') from error
    return text.replace('\r', '')


def run_program(memory, symbols=None, cpu='4004', keys=b'', limit=10_000_000, end=None):
    """Return (console output, instruction cycles, transcript).

    keys are the console input. INTERP prompts for each RDR value and reads
    it as the next command line, so the answers must be supplied in order:
    two nibbles per character from port 15, and from port 14, 1 while input
    remains. The order depends on the program, so each run's prompts
    correct the answers and the session runs again until they agree.
    """
    exits = [end] if end is not None else jump_to_self(memory)
    if len(exits) != 1:
        raise SimulationError(f'the program needs exactly one JUN to itself to end; found {len(exits)}')
    nibbles = []
    for ch in keys.replace(b'\n', b'\r'):
        nibbles += [ch >> 4, ch & 15]
    commands = f'BREAK 0{exits[0]:X}H.\nCYCLE 0{limit:X}H.\nGO.\n'
    answers = nibbles + [0]
    for _ in range(len(nibbles) + 1000):
        # INTERP takes a few hundred PDP-10 instructions per 4004 instruction cycle.
        text = session(memory, symbols or {}, cpu, commands + ''.join(f'0{a:X}H\n' for a in answers) + '.\nTIME.\n',
                       budget=2_000_000_000 + 500 * limit)
        asked = [int(m.group(1), 16) for m in map(ASKED.match, (line.strip() for line in text.splitlines())) if m]
        wanted, used = [], 0
        for port in asked:
            if port == CONSOLE:
                wanted.append(nibbles[used] if used < len(nibbles) else 0)
                used += 1
            else:
                wanted.append(1 if used < len(nibbles) and port == STATUS else 0)
        if wanted == answers[:len(wanted)] and len(asked) < len(answers):
            break
        # Guess that the remaining reads take console nibbles; a spare answer
        # lets the next run show any further prompt.
        answers = wanted + nibbles[used:] + [0]
    output, high = bytearray(), None
    for line in text.splitlines():
        match = PORT.match(line.strip())
        if match and int(match.group(1), 16) == CONSOLE:
            nibble = int(match.group(2), 16)
            if high is None:
                high = nibble
            else:
                character = (high << 4 | nibble) & 0x7f
                output.append(10 if character == 13 else character)
                high = None
    if 'BREAK AT' not in text:
        tail = [line for line in text.splitlines() if 'ERROR' in line or 'CYCLE AT' in line]
        raise SimulationError('program did not reach its end: ' + ('; '.join(tail) or text[-500:]))
    times = [int(m.group(1)) for m in map(TIME.match, text.splitlines()) if m]
    return bytes(output), times[-1], text


def load_program(path, cpu):
    """Return memory and symbols for MAC4 source or an Intel HEX file."""
    path = Path(path)
    if path.suffix.lower() == '.hex':
        memory, base = {}, 0
        for line in path.read_text(encoding='ascii').splitlines():
            line = line.strip()
            if not line.startswith(':'):
                continue
            raw = bytes.fromhex(line[1:])
            if raw[3] == 1 or raw[0] == 0:
                break
            if raw[3] == 0:
                address = base + int.from_bytes(raw[1:3], 'big')
                memory.update((address + i, b) for i, b in enumerate(raw[4:-1]))
        symbols = {}
        mapping = path.with_suffix('.map')
        if mapping.is_file():
            for line in mapping.read_text(encoding='ascii').splitlines():
                fields = line.split()
                if len(fields) == 2 and not fields[0].startswith('#'):
                    symbols[fields[1][:5]] = int(fields[0], 16)
        return memory, symbols
    memory, symbols, _ = mac4.assemble_source(path.read_text(encoding='ascii'), cpu)
    return memory, symbols


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('program', type=Path)
    parser.add_argument('--4040', dest='cpu', action='store_const', const='4040', default='4004',
                        help='MAC40 and INTERP/40')
    parser.add_argument('-l', '--input', type=Path, help='console input file')
    parser.add_argument('-n', '--limit', type=int, default=10_000_000, help='instruction cycle limit')
    parser.add_argument('-p', action='store_true', help='report instruction cycles')
    parser.add_argument('--transcript', action='store_true', help='print INTERP\'s whole transcript')
    args = parser.parse_args()
    try:
        memory, symbols = load_program(args.program, args.cpu)
        keys = args.input.read_bytes() if args.input else b''
        output, cycles, text = run_program(memory, symbols, args.cpu, keys, args.limit)
        if args.transcript:
            print(text, end='')
        else:
            sys.stdout.write(output.decode('latin-1'))
        if args.p:
            print(f'{cycles} instruction cycles', file=sys.stderr)
    except (OSError, ValueError, mac4.AssemblyError, SimulationError) as error:
        print(f'INTERP/4: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
