#!/usr/bin/env python3
"""Build either native BASIC ROM profile; BASIC input is parsed on the 4004."""
from pathlib import Path
import argparse
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import asm4
import cc4


def compile_profile(large=False):
    source = (ROOT/'basic/basic.c').read_text()
    name = 'large' if large else 'basic'
    if large:
        source = '#define LARGE 1\n'+source
    assembly, compiler = cc4.compile_source(source, name, size=True)
    memory, symbols, _ = asm4.Assembler('4004').assemble(assembly)
    return assembly, asm4.hex_file(memory), asm4.map_file(symbols), compiler


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--large', action='store_true', help='build the larger-program profile')
    parser.add_argument('--all', action='store_true', help='build both profiles')
    args = parser.parse_args()
    for large in ((False, True) if args.all else (args.large,)):
        assembly, image, symbols, compiler = compile_profile(large)
        name = 'large' if large else 'basic'
        for suffix, content in (('asm', assembly), ('hex', image), ('map', symbols)):
            (ROOT/f'basic/{name}.{suffix}').write_text(content, encoding='ascii', newline='\n')
        print(f'{name}: ROM end {compiler.rom_end}/4096 bytes; '
              f'RAM {compiler.memory_top}/2048 nibbles; status {compiler.slots_used}/128')


if __name__ == '__main__':
    main()
