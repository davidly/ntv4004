#!/usr/bin/env python3
"""Run Intel's original MAC4 2.5 (4004) or MAC40 2.5 (4040) macro cross-assembler.

  mac4.py prog.asm                 write prog.hex (Intel HEX) and prog.map
  mac4.py --4040 prog.asm          assemble with MAC40, which knows the 4040 instructions
  mac4.py --expanded prog.asm      MAC40E, the expanded MAC40 2.4
"""
import argparse
import os
from pathlib import Path
import re
import sys
import tempfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from pdp10 import NATIVE, PDP10  # noqa: E402

UPSTREAM = HERE / 'upstream'
CONTROLS = '$O=3\n$I=2\n'  # listing to FOR22.DAT, source from FOR20.DAT; the object goes to FOR21.DAT
BUDGET = 1_000_000_000
SIGNIFICANT = 5  # characters MAC4 keeps of each symbol
IMAGES = {'4004': 'mac4.sav', '4040': 'mac40.sav', '4040e': 'mac40e.sav'}


class AssemblyError(Exception):
    pass


def code_field(line):
    """Return the part of a source line before any comment."""
    quoted = False
    for index, character in enumerate(line):
        if character == "'":
            quoted = not quoted  # a doubled quote toggles twice
        elif character == ';' and not quoted:
            return line[:index]
    return line


def check_source(lines):
    symbols = {}
    for number, line in enumerate(lines, 1):
        code = code_field(line).rstrip()
        for character in code:
            if not ' ' <= character <= 'Z':
                raise AssemblyError(f'line {number}: character {character!r} is outside the MAC4 alphabet; '
                                    'use uppercase source and numeric values for other characters')
        if len(code) > 72:
            raise AssemblyError(f'line {number}: code exceeds MAC4\'s 72-column limit (comments may be longer)')
        if code.startswith('$'):
            raise AssemblyError(f'line {number}: MAC4 control lines are set by this wrapper')
        for name in re.findall(r"'(?:[^']|'')*'|(?<![0-9A-Z?@])[A-Z?@][A-Z0-9?@]*", code):
            if not name.startswith("'"):
                other = symbols.setdefault(name[:SIGNIFICANT], name)
                if other != name:
                    raise AssemblyError(f'line {number}: {name} and {other} are the same symbol to MAC4, '
                                        f'which keeps only {SIGNIFICANT} characters')


def assemble_object(source, cpu='4004', bnpf=False, symbols=False):
    """Return MAC4's object file and listing.

    bnpf selects BNPF instead of Intel HEX, and symbols puts the symbol table
    before the object, the form INTERP/4 loads.
    """
    source.encode('ascii')
    lines = source.expandtabs(8).splitlines()
    check_source(lines)
    if not any(re.match(r'([A-Z?@][A-Z0-9?@]*:?)?\s+END\s*$', code_field(line)) for line in lines):
        lines.append('        END')
    controls = ('$T=1\n' if symbols else '') + ('$B=0\n' if bnpf else '') + CONTROLS
    with tempfile.TemporaryDirectory(prefix='mac4-') as directory:
        Path(directory, 'FOR20.DAT').write_text('\n'.join(lines) + '\n', encoding='ascii')
        image = UPSTREAM / IMAGES[cpu]
        if not image.is_file():
            raise AssemblyError(f'{image} not found; see intel/README.md')
        runner = PDP10(image, controls, directory)
        try:
            native = NATIVE.is_file() and not os.environ.get('PDP10_PYTHON')
            console = runner.run_native(BUDGET) if native else runner.run(BUDGET)
        except (RuntimeError, OSError, StopIteration, ZeroDivisionError) as error:
            raise AssemblyError(f'{image.name}: {error}\n{runner.output.getvalue()}') from error
        listing = Path(directory, 'FOR22.DAT').read_text(encoding='ascii').replace('\r', '')
        if 'NO PROGRAM ERRORS' not in console:
            # MAC4 flags each erroneous listing line in its second column.
            flagged = [line for line in listing.splitlines() if re.match(r' [A-Z] ', line)]
            raise AssemblyError('\n'.join(flagged + [console.strip().splitlines()[-1]]))
        return Path(directory, 'FOR21.DAT').read_text(encoding='ascii').replace('\r', ''), listing


def read_symbols(text):
    """Return {name: address} from the symbol table that $T=1 puts before the object."""
    table = text.split('$', 1)[0]
    found = {}
    for line in table.splitlines():
        fields = line.split()
        if len(fields) == 3 and fields[2].endswith('Q') and not fields[1].startswith('BLOCK'):
            found[fields[1]] = int(fields[2][:-1], 8)
    return found


def read_hex(text):
    """Return {address: byte} from MAC4's Intel HEX records."""
    memory = {}
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith(':'):
            continue
        raw = bytes.fromhex(line[1:])
        if len(raw) < 5 or len(raw) != raw[0] + 5 or sum(raw) & 255:
            raise AssemblyError('invalid MAC4 HEX record')
        if raw[0] == 0:
            return memory
        address = int.from_bytes(raw[1:3], 'big')
        memory.update((address + i, b) for i, b in enumerate(raw[4:-1]))
    raise AssemblyError('MAC4 object file has no end record')


def hex_file(memory):
    """Standard Intel HEX: 16-byte records and an end record."""
    lines, addresses, index = [], sorted(memory), 0
    while index < len(addresses):
        start, data = addresses[index], []
        while index < len(addresses) and addresses[index] == start + len(data) and len(data) < 16:
            data.append(memory[addresses[index]])
            index += 1
        record = bytes([len(data), start >> 8, start & 255, 0, *data])
        lines.append(':' + (record + bytes([-sum(record) & 255])).hex().upper())
    return '\n'.join(lines + [':00000001FF']) + '\n'


def map_file(symbols):
    return ''.join(f'{address:04X} {name}\n' for name, address in sorted(symbols.items(), key=lambda item: (item[1], item[0])))


def bnpf_object(memory, symbols):
    """Write memory and symbols in MAC4's $T=1 $B=0 form, which INTERP/4 loads.

    BNPF writes each byte as B, eight bits from the most significant (N for
    1, P for 0) and F. MAC4 prints four bytes per line after the decimal
    address of the first, from address 0 to the end of the program.
    """
    lines = [f' {number:03d} {name:<5} {address:06o}Q' for number, (name, address) in
             enumerate(sorted(symbols.items(), key=lambda item: item[1]) or [('START', 0)], 1)]
    lines.append(' $')
    end = max(memory) + 1 if memory else 1
    for start in range(0, end, 4):
        cells = [memory.get(a, 0) for a in range(start, min(start + 4, end))]
        bnpf = '  '.join('B' + ''.join('N' if b & (128 >> bit) else 'P' for bit in range(8)) + 'F' for b in cells)
        lines.append(f' {start} {bnpf} ')
    lines.append(' $')
    return '\n'.join(lines) + '\n'


def assemble_source(source, cpu='4004'):
    """Return the memory image, the symbols and the listing."""
    text, listing = assemble_object(source, cpu, symbols=True)
    return read_hex(text.split('$', 1)[1]), read_symbols(text), listing


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('source', type=Path)
    parser.add_argument('-o', '--output', type=Path, help='HEX path (default: source.hex); a .map is written beside it')
    parser.add_argument('--listing', type=Path, help='save the assembler listing')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--4040', dest='cpu', action='store_const', const='4040', default='4004', help='use MAC40')
    group.add_argument('--expanded', dest='cpu', action='store_const', const='4040e', help='use MAC40E')
    args = parser.parse_args()
    try:
        memory, symbols, listing = assemble_source(args.source.read_text(encoding='ascii'), args.cpu)
        destination = args.output or args.source.with_suffix('.hex')
        destination.write_text(hex_file(memory), encoding='ascii')
        destination.with_suffix('.map').write_text(map_file(symbols), encoding='ascii')
        if args.listing:
            args.listing.write_text(listing, encoding='ascii')
        print(f'{args.source}: assembled to {destination}')
    except (OSError, ValueError, AssemblyError) as error:
        print(f'MAC4: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
