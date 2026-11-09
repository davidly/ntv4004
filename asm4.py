#!/usr/bin/env python3
"""Assemble Intel 4004/4040 source written for Intel's MAC4 and MAC40.

  asm4.py prog.asm             write prog.hex (Intel HEX) and prog.map (symbols)
  asm4.py --4040 prog.asm      also accept the 4040 instructions, as MAC40 does
  asm4.py --listing prog.asm   print a listing

This is a project assembler for MAC4's language, so that programs build
without Intel's PDP-10 assembler. tests/asm.py checks that it produces
MAC4's bytes. It supports labels, EQU, SET, ORG, DB, DS, END, IF/ENDIF and
expressions with $, character constants, numbers with B, O, Q, D or H
suffixes, and the operators * / MOD SHL SHR + - NOT AND OR XOR, evaluated
modulo 65536. Macros are not supported.
"""
import argparse
from pathlib import Path
import re
import sys

SIGNIFICANT = 5  # MAC4 keeps five characters of each symbol

IMPLIED = {
    'NOP': 0x00, 'WRM': 0xE0, 'WMP': 0xE1, 'WRR': 0xE2, 'WPM': 0xE3, 'WR0': 0xE4, 'WR1': 0xE5, 'WR2': 0xE6,
    'WR3': 0xE7, 'SBM': 0xE8, 'RDM': 0xE9, 'RDR': 0xEA, 'ADM': 0xEB, 'RD0': 0xEC, 'RD1': 0xED, 'RD2': 0xEE,
    'RD3': 0xEF, 'CLB': 0xF0, 'CLC': 0xF1, 'IAC': 0xF2, 'CMC': 0xF3, 'CMA': 0xF4, 'RAL': 0xF5, 'RAR': 0xF6,
    'TCC': 0xF7, 'DAC': 0xF8, 'TCS': 0xF9, 'STC': 0xFA, 'DAA': 0xFB, 'KBP': 0xFC, 'DCL': 0xFD,
}
IMPLIED_4040 = {
    'HLT': 0x01, 'BBS': 0x02, 'LCR': 0x03, 'OR4': 0x04, 'OR5': 0x05, 'AN6': 0x06, 'AN7': 0x07, 'DB0': 0x08,
    'DB1': 0x09, 'SB0': 0x0A, 'SB1': 0x0B, 'EIN': 0x0C, 'DIN': 0x0D, 'RPM': 0x0E,
}
REGISTER = {'INC': 0x60, 'ADD': 0x80, 'SUB': 0x90, 'LD': 0xA0, 'XCH': 0xB0}
PAIR = {'SRC': 0x21, 'FIN': 0x30, 'JIN': 0x31}  # operands are even register numbers, as in MAC4
DATA = {'LDM': 0xD0, 'BBL': 0xC0}
LONG = {'JUN': 0x40, 'JMS': 0x50}
DIRECTIVES = {'EQU', 'SET', 'ORG', 'DB', 'DS', 'END', 'IF', 'ENDIF', 'MACRO', 'ENDM'}
OPERATORS = {'MOD', 'SHL', 'SHR', 'NOT', 'AND', 'OR', 'XOR'}
MNEMONICS = set(IMPLIED) | set(IMPLIED_4040) | set(REGISTER) | set(PAIR) | set(DATA) | set(LONG) | {'FIM', 'JCN', 'ISZ'}


class AssemblyError(Exception):
    pass


def code_field(line):
    """Return the part of a source line before any comment."""
    quoted = False
    for index, character in enumerate(line):
        if character == "'":
            quoted = not quoted
        elif character == ';' and not quoted:
            return line[:index]
    return line


TOKEN = re.compile(r"\s*(?:('(?:[^']|'')*')|([0-9][0-9A-Z]*)|([A-Z?@][A-Z0-9?@]*)|(\$)|(.))")


class Expression:
    """Intel assembler expressions, evaluated modulo 65536."""

    def __init__(self, text, symbols, location, final, names=None):
        self.tokens = []
        position = 0
        text = text.rstrip()
        while position < len(text):
            match = TOKEN.match(text, position)
            if not match or match.end() == position:
                break
            position = match.end()
            string, number, name, dollar, other = match.groups()
            if string is not None:
                self.tokens.append(('string', string[1:-1].replace("''", "'")))
            elif number is not None:
                self.tokens.append(('number', parse_number(number)))
            elif name is not None:
                self.tokens.append(('op', name) if name in OPERATORS else ('name', name))
            elif dollar:
                self.tokens.append(('number', location))
            elif other.strip():
                self.tokens.append(('op', other))
        self.index = 0
        self.symbols, self.final, self.names = symbols, final, names or {}

    def peek(self):
        return self.tokens[self.index] if self.index < len(self.tokens) else (None, None)

    def take(self):
        token = self.peek()
        self.index += 1
        return token

    def value(self):
        result = self.logical_or()
        if self.index != len(self.tokens):
            raise AssemblyError(f'unexpected {self.peek()[1]!r} in expression')
        return result & 0xFFFF

    def logical_or(self):
        left = self.logical_and()
        while self.peek() in (('op', 'OR'), ('op', 'XOR')):
            operator = self.take()[1]
            right = self.logical_and()
            left = left | right if operator == 'OR' else left ^ right
        return left

    def logical_and(self):
        left = self.logical_not()
        while self.peek() == ('op', 'AND'):
            self.take()
            left &= self.logical_not()
        return left

    def logical_not(self):
        if self.peek() == ('op', 'NOT'):
            self.take()
            return ~self.logical_not() & 0xFFFF
        return self.additive()

    def additive(self):
        left = self.term()
        while self.peek() in (('op', '+'), ('op', '-')):
            operator = self.take()[1]
            right = self.term()
            left = (left + right if operator == '+' else left - right) & 0xFFFF
        return left

    def term(self):
        left = self.unary()
        while self.peek() in (('op', '*'), ('op', '/'), ('op', 'MOD'), ('op', 'SHL'), ('op', 'SHR')):
            operator = self.take()[1]
            right = self.unary()
            if operator == '*':
                left = left * right
            elif operator in ('/', 'MOD'):
                if right == 0:
                    raise AssemblyError('division by zero')
                left = left // right if operator == '/' else left % right
            elif operator == 'SHL':
                left = left << right
            else:
                left = left >> right
            left &= 0xFFFF
        return left

    def unary(self):
        if self.peek() in (('op', '-'), ('op', '+')):
            operator = self.take()[1]
            value = self.unary()
            return -value & 0xFFFF if operator == '-' else value
        return self.primary()

    def primary(self):
        kind, value = self.take()
        if kind == 'number':
            return value
        if kind == 'string':
            if not 1 <= len(value) <= 2:
                raise AssemblyError('a character constant in an expression has one or two characters')
            return int.from_bytes(value.encode('ascii'), 'big')
        if kind == 'name':
            key = value[:SIGNIFICANT]
            if key in self.names and self.names[key] != value:
                # MAC4 would silently use the other symbol.
                raise AssemblyError(f'{value} and {self.names[key]} are the same symbol to MAC4, '
                                    f'which keeps only {SIGNIFICANT} characters')
            if key in self.symbols:
                return self.symbols[key]
            if self.final:
                raise AssemblyError(f'undefined symbol {value}')
            return 0
        if (kind, value) == ('op', '('):
            result = self.logical_or()
            if self.take() != ('op', ')'):
                raise AssemblyError('missing )')
            return result
        raise AssemblyError(f'missing operand near {value!r}')


def parse_number(text):
    match = re.fullmatch(r'([0-9A-F]+)([BOQDH]?)', text)
    if not match:
        raise AssemblyError(f'invalid number {text}')
    digits, suffix = match.groups()
    if not suffix and digits[-1] in 'BD' and len(digits) > 1 and all(c in '0123456789' for c in digits[:-1]):
        digits, suffix = digits[:-1], digits[-1]
    base = {'B': 2, 'O': 8, 'Q': 8, 'H': 16}.get(suffix, 10)
    try:
        return int(digits, base) & 0xFFFF
    except ValueError:
        raise AssemblyError(f'invalid number {text}') from None


def split_operands(text):
    """Split on commas outside quotes and parentheses."""
    parts, current, depth, quoted = [], '', 0, False
    for character in text:
        if character == "'":
            quoted = not quoted
        elif not quoted and character == '(':
            depth += 1
        elif not quoted and character == ')':
            depth -= 1
        elif not quoted and depth == 0 and character == ',':
            parts.append(current)
            current = ''
            continue
        current += character
    if current.strip() or parts:
        parts.append(current)
    return [part.strip() for part in parts]


LINE = re.compile(r'^(?:([A-Z?@][A-Z0-9?@]*):?)?\s+([A-Z][A-Z0-9]*)?\s*(.*)$|^([A-Z?@][A-Z0-9?@]*):\s*$')


class Assembler:
    def __init__(self, cpu='4004'):
        self.cpu = cpu
        self.implied = dict(IMPLIED, **(IMPLIED_4040 if cpu == '4040' else {}))

    def parse(self, line):
        code = code_field(line).rstrip()
        if not code.strip():
            return None, None, ''
        match = LINE.match(code)
        if not match:
            raise AssemblyError('cannot parse the line')
        if match.group(4):
            return match.group(4), None, ''
        label, operation, operands = match.groups()[:3]
        # A name in column 1 without a colon is a label only before EQU or SET.
        if label and not code.startswith(label + ':') and operation not in ('EQU', 'SET'):
            raise AssemblyError(f'{label}: labels need a colon unless they name an EQU or SET')
        return label, operation, operands

    def define(self, label, value, redefinable=False):
        key = label[:SIGNIFICANT]
        if label in MNEMONICS or label in DIRECTIVES or label in OPERATORS:
            raise AssemblyError(f'{label} is reserved and cannot be a label')
        if key in self.names and self.names[key] != label:
            raise AssemblyError(f'{label} and {self.names[key]} are the same symbol to MAC4, '
                                f'which keeps only {SIGNIFICANT} characters')
        if not self.final:
            if key in self.fixed or (key in self.symbols and not redefinable):
                raise AssemblyError(f'{label} is defined more than once')
            self.names[key] = label
            if not redefinable:
                self.fixed.add(key)
        elif not redefinable and self.symbols.get(key) != value:
            raise AssemblyError(f'{label} changed value between passes')
        self.symbols[key] = value

    def evaluate(self, text):
        if not text:
            raise AssemblyError('missing operand')
        return Expression(text, self.symbols, self.location, self.final, self.names).value()

    def emit(self, *values):
        for value in values:
            if self.location > 0x1FFF:
                raise AssemblyError('code beyond the 8K ROM address space')
            if self.final:
                if self.location in self.memory:
                    raise AssemblyError(f'address {self.location:04X}H is assembled twice')
                self.memory[self.location] = value & 0xFF
            self.location += 1

    def limited(self, text, maximum, what):
        value = self.evaluate(text)
        if value > maximum:
            raise AssemblyError(f'{what} {value} is out of range (0 to {maximum})')
        return value

    def short_target(self, text, length):
        """An 8-bit address on the page of the instruction that follows."""
        target = self.evaluate(text)
        if self.final and (target & 0xF00) != ((self.location + length) & 0xF00):
            raise AssemblyError(f'{text} is not on the page of the next instruction')
        return target & 0xFF

    def instruction(self, operation, operands):
        parts = split_operands(operands)

        def need(count):
            if len(parts) != count:
                raise AssemblyError(f'{operation} takes {count} operand{"s" if count != 1 else ""}')

        if operation in self.implied:
            need(0)
            self.emit(self.implied[operation])
        elif operation in IMPLIED_4040:
            raise AssemblyError(f'{operation} is a 4040 instruction; assemble with --4040')
        elif operation in REGISTER:
            need(1)
            self.emit(REGISTER[operation] | self.limited(parts[0], 15, 'register'))
        elif operation in PAIR or operation == 'FIM':
            need(2 if operation == 'FIM' else 1)
            register = self.limited(parts[0], 14, 'register pair')
            if register & 1:
                raise AssemblyError(f'{operation} names a register pair by its even register, 0 to 14')
            if operation == 'FIM':
                self.emit(0x20 | register, self.limited(parts[1], 255, 'data'))
            else:
                self.emit(PAIR[operation] | register)
        elif operation in DATA:
            need(1)
            self.emit(DATA[operation] | self.limited(parts[0], 15, 'data'))
        elif operation in LONG:
            need(1)
            target = self.limited(parts[0], 0xFFF, 'address')
            self.emit(LONG[operation] | target >> 8, target & 0xFF)
        elif operation == 'JCN':
            need(2)
            condition = self.limited(parts[0], 15, 'condition')
            self.emit(0x10 | condition, self.short_target(parts[1], 2))
        elif operation == 'ISZ':
            need(2)
            register = self.limited(parts[0], 15, 'register')
            self.emit(0x70 | register, self.short_target(parts[1], 2))
        else:
            raise AssemblyError(f'unknown instruction {operation}')

    def line(self, label, operation, operands):
        if operation == 'IF':
            self.conditions.append(self.active and self.evaluate(operands) != 0)
            return
        if operation == 'ENDIF':
            if not self.conditions:
                raise AssemblyError('ENDIF without IF')
            self.conditions.pop()
            return
        if not self.active:
            return
        if operation in ('MACRO', 'ENDM'):
            raise AssemblyError('macros are not supported by this assembler')
        if operation in ('EQU', 'SET'):
            if not label:
                raise AssemblyError(f'{operation} needs a name')
            self.define(label, self.evaluate(operands), operation == 'SET')
            return
        if label:
            self.define(label, self.location)
        if operation is None:
            return
        if operation == 'ORG':
            self.location = self.limited(operands, 0x1FFF, 'address')
        elif operation == 'DS':
            self.location += self.evaluate(operands)
        elif operation == 'DB':
            for part in split_operands(operands):
                if part.startswith("'") and part.endswith("'") and len(part) > 3:
                    self.emit(*part[1:-1].replace("''", "'").encode('ascii'))
                else:
                    value = self.evaluate(part)
                    if value > 0xFF and value < 0xFF80:
                        raise AssemblyError(f'data {value} does not fit in a byte')
                    self.emit(value)
        elif operation == 'END':
            self.ended = True
        else:
            self.instruction(operation, operands)

    @property
    def active(self):
        return all(self.conditions)

    def assemble(self, source):
        lines = source.expandtabs(8).splitlines()
        self.symbols, self.names, self.fixed = {}, {}, set()
        for self.final in (False, True):
            self.location, self.memory, self.conditions, self.ended = 0, {}, [], False
            listing = []
            for number, text in enumerate(lines, 1):
                start = self.location
                try:
                    code = code_field(text).rstrip()
                    for character in code:
                        if not ' ' <= character <= 'Z':
                            raise AssemblyError(f'character {character!r} is outside the MAC4 alphabet')
                    if len(code) > 72:
                        raise AssemblyError("code exceeds MAC4's 72-column limit")
                    self.line(*self.parse(text))
                except AssemblyError as error:
                    raise AssemblyError(f'line {number}: {error}\n    {text}') from None
                if self.final:
                    data = ''.join(f'{self.memory[a]:02X}' for a in range(start, self.location) if a in self.memory)
                    listing.append(f'{start:04X} {data:<8} {text}')
                if self.ended:
                    break
            if self.conditions:
                raise AssemblyError('IF without ENDIF')
        symbols = {self.names[key]: value for key, value in self.symbols.items()}
        return self.memory, symbols, '\n'.join(listing) + '\n'


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
    return ''.join(f'{value:04X} {name}\n' for name, value in sorted(symbols.items(), key=lambda item: (item[1], item[0])))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('source', type=Path)
    parser.add_argument('-o', '--output', type=Path, help='HEX path (default: source.hex); a .map is written beside it')
    parser.add_argument('--4040', dest='cpu', action='store_const', const='4040', default='4004',
                        help='accept the 4040 instructions')
    parser.add_argument('--listing', action='store_true', help='print a listing')
    args = parser.parse_args()
    try:
        memory, symbols, listing = Assembler(args.cpu).assemble(args.source.read_text(encoding='ascii'))
        if not memory:
            raise AssemblyError('the program has no code')
        destination = args.output or args.source.with_suffix('.hex')
        destination.write_text(hex_file(memory), encoding='ascii', newline='\n')
        destination.with_suffix('.map').write_text(map_file(symbols), encoding='ascii', newline='\n')
        if args.listing:
            print(listing, end='')
    except (OSError, UnicodeError, AssemblyError) as error:
        print(f'asm4: {args.source}: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
