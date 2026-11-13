#!/usr/bin/env python3
"""Build the native BASIC ROM profiles; BASIC input is parsed on the 4004."""
from pathlib import Path
import argparse
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import asm4
import cc4


def compile_profile(large=False, byte_array=False):
    if large and byte_array:
        raise ValueError('large and byte-array profiles are separate')
    source = (ROOT/'basic/basic.c').read_text()
    name = 'large' if large else 'byte' if byte_array else 'basic'
    if large:
        source = '#define LARGE 1\n'+source
    elif byte_array:
        source = '#define BYTE_ARRAY 1\n'+source
    assembly, compiler = cc4.compile_source(source, name, size=True)
    memory, symbols, _ = asm4.Assembler('4004').assemble(assembly)
    return assembly, asm4.hex_file(memory), asm4.map_file(symbols), compiler


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    profiles = parser.add_mutually_exclusive_group()
    profiles.add_argument('--large', action='store_true', help='build the larger-program profile')
    profiles.add_argument('--byte-array', action='store_true', help='build the byte-array profile')
    profiles.add_argument('--all', action='store_true', help='build all three profiles')
    args = parser.parse_args()
    selected = ((False, False), (True, False), (False, True)) if args.all else ((args.large, args.byte_array),)
    for large, byte_array in selected:
        assembly, image, symbols, compiler = compile_profile(large, byte_array)
        name = 'large' if large else 'byte' if byte_array else 'basic'
        for suffix, content in (('asm', assembly), ('hex', image), ('map', symbols)):
            (ROOT/f'basic/{name}.{suffix}').write_text(content, encoding='ascii', newline='\n')
        print(f'{name}: ROM end {compiler.rom_end}/4096 bytes; '
              f'RAM {compiler.memory_top}/2048 nibbles; status {compiler.slots_used}/128')


if __name__ == '__main__':
    main()
