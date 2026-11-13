#!/usr/bin/env python3
"""Compile a small subset of C for the Intel 4004.

  cc4.py prog.c            write prog.asm (MAC4 source), prog.hex and prog.map
  cc4.py -S prog.c         write only prog.asm
  cc4.py --stats prog.c    also report ROM and RAM use

The output is MAC4 source, assembled here with asm4.py; Intel's MAC4 accepts
it too. The language is C without pointers, structures or floating point:

* int (16 bits), unsigned (16 bits), char (8 bits, unsigned) and void.
  _Bool arrays are packed four flags to a 4002 RAM character. __nibble is a
  4-bit unsigned type for the 4004.
* Global and local scalars and one-dimensional arrays. Scalars live in the
  4002 status characters, one register (4 nibbles) each, or four __nibbles
  to a register; arrays live in main memory. Global initializers must be
  constant.
* Functions with parameters and return values, including recursion. Single-use
  leaf functions without user labels are inlined. The
  4004's three-level stack is left to the runtime library: calls jump, and
  return through a table indexed by a return number stored with the callee.
  A call that can reach the caller again first saves the caller's
  variables on a stack in RAM.
* if, else, while, do, for, switch/case/default, goto and labels, break,
  continue, return, and every C operator except pointer and member operators.
  sizeof uses 8-bit C bytes, including for packed _Bool and __nibble objects.
* putchar, getchar, puts, and printf with a constant format and %d %u %x %c
  %s (a string constant) and %%.
* Hardware built-ins, compiled inline: __rom_out(chip, v) and __rom_in(chip)
  for the 4001 ROM ports, __ram_out(bank, chip, v) for the 4002 output
  ports, __test() for the TEST pin and __kbp(v) for KBP.
* With --4040: an __interrupt function for the 4040's interrupt, __ei(),
  __di() and __halt() for EIN, DIN and HLT, and volatile variables.
* #include (ignored), #define with or without parameters, #undef, #if,
  #ifdef, #ifndef, #elif, #else and #endif. __CC4__ is predefined.
"""
import argparse
from pathlib import Path
import re
import sys

import asm4


class CompileError(Exception):
    pass


# ---------------------------------------------------------------- lexing

PUNCTUATORS = ['<<=', '>>=', '...', '->', '++', '--', '<<', '>>', '<=', '>=', '==', '!=', '&&', '||', '+=', '-=',
               '*=', '/=', '%=', '&=', '^=', '|=', '##', '[', ']', '(', ')', '{', '}', '.', '&', '*', '+', '-',
               '~', '!', '/', '%', '<', '>', '^', '|', '?', ':', ';', '=', ',', '#']
TOKEN = re.compile(r'''\s*(?:(?P<num>0[xX][0-9a-fA-F]+[uUlL]*|[0-9]+[uUlL]*)|(?P<id>[A-Za-z_][A-Za-z0-9_]*)'''
                   r'''|(?P<chr>'(?:\\.|[^'\\])+')|(?P<str>"(?:\\.|[^"\\])*")|(?P<op>'''
                   + '|'.join(re.escape(p) for p in PUNCTUATORS) + '))')
ESCAPES = {'n': 10, 't': 9, 'r': 13, '0': 0, 'a': 7, 'b': 8, 'f': 12, 'v': 11, '\\': 92, "'": 39, '"': 34, '?': 63}


class Token:
    def __init__(self, kind, value, line):
        self.kind, self.value, self.line = kind, value, line

    def at(self, line):
        return Token(self.kind, self.value, line)

    def __repr__(self):
        return f'{self.kind}:{self.value!r}'


def unescape(text, line):
    out, i = [], 0
    while i < len(text):
        c = text[i]
        if c != '\\':
            out.append(ord(c))
            i += 1
            continue
        i += 1
        c = text[i]
        if c == 'x':
            digits = re.match(r'[0-9a-fA-F]+', text[i + 1:])
            if not digits:
                raise CompileError(f'line {line}: bad \\x escape')
            out.append(int(digits.group(), 16) & 255)
            i += 1 + len(digits.group())
        elif c in '01234567':
            digits = re.match(r'[0-7]{1,3}', text[i:]).group()
            out.append(int(digits, 8) & 255)
            i += len(digits)
        elif c in ESCAPES:
            out.append(ESCAPES[c])
            i += 1
        else:
            raise CompileError(f'line {line}: unknown escape \\{c}')
    return bytes(out)


def tokenize(text, line):
    tokens, pos = [], 0
    while True:
        match = TOKEN.match(text, pos)
        if not match or match.end() == pos:
            if text[pos:].strip():
                raise CompileError(f'line {line}: unexpected character {text[pos:].strip()[0]!r}')
            return tokens
        pos = match.end()
        if match.group('num'):
            digits = match.group('num').rstrip('uUlL')
            if 'l' in match.group('num').lower():
                raise CompileError(f'line {line}: long constants are not supported')
            value = int(digits, 16) if digits[:2].lower() == '0x' else int(digits, 8 if digits.startswith('0') else 10)
            unsigned = 'u' in match.group('num').lower() or value > 0x7FFF
            if value > 0xFFFF:
                raise CompileError(f'line {line}: {digits} does not fit in 16 bits')
            tokens.append(Token('num', (value, 'unsigned' if unsigned else 'int'), line))
        elif match.group('id'):
            tokens.append(Token('id', match.group('id'), line))
        elif match.group('chr'):
            data = unescape(match.group('chr')[1:-1], line)
            if len(data) != 1:
                raise CompileError(f'line {line}: a character constant must have one character')
            tokens.append(Token('num', (data[0], 'int'), line))
        elif match.group('str'):
            tokens.append(Token('str', unescape(match.group('str')[1:-1], line), line))
        else:
            tokens.append(Token('op', match.group('op'), line))


# ---------------------------------------------------------------- preprocessing

def strip_comments(text):
    """Replace comments with spaces, keeping the line structure."""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c in '"\'':
            j = i + 1
            while j < n and text[j] != c and text[j] != '\n':
                j += 2 if text[j] == '\\' else 1
            out.append(text[i:j + 1])
            i = j + 1
        elif text.startswith('/*', i):
            j = text.find('*/', i + 2)
            if j < 0:
                raise CompileError('unterminated comment')
            out.append(' ' + '\n' * text.count('\n', i, j))
            i = j + 2
        elif text.startswith('//', i):
            j = text.find('\n', i)
            i = n if j < 0 else j
        else:
            out.append(c)
            i += 1
    return ''.join(out)


class Preprocessor:
    def __init__(self):
        self.macros = {'__CC4__': (None, [Token('num', (1, 'int'), 0)])}  # name -> (parameters or None, body tokens)

    def run(self, text):
        tokens, stack = [], []  # stack entries: [this branch taken, some branch taken]
        lines = strip_comments(text.replace('\\\n', ' ')).split('\n')
        for number, line in enumerate(lines, 1):
            active = all(taking for taking, _ in stack)
            stripped = line.strip()
            if not stripped.startswith('#'):
                if active:
                    tokens += self.expand(tokenize(line, number))
                continue
            directive, rest = re.match(r'(\w*)\s*(.*)', stripped[1:].strip()).groups()
            if directive in ('ifdef', 'ifndef'):
                taken = (rest.split()[0] in self.macros) == (directive == 'ifdef') if rest else False
                stack.append([taken, taken])
            elif directive == 'if':
                taken = active and self.condition(rest, number)
                stack.append([taken, taken])
            elif directive == 'elif':
                if not stack:
                    raise CompileError(f'line {number}: #elif without #if')
                taken = not stack[-1][1] and all(t for t, _ in stack[:-1]) and self.condition(rest, number)
                stack[-1] = [taken, stack[-1][1] or taken]
            elif directive == 'else':
                if not stack:
                    raise CompileError(f'line {number}: #else without #if')
                stack[-1] = [not stack[-1][1], True]
            elif directive == 'endif':
                if not stack:
                    raise CompileError(f'line {number}: #endif without #if')
                stack.pop()
            elif not active or directive in ('', 'include', 'pragma'):
                pass
            elif directive == 'define':
                match = re.match(r'([A-Za-z_]\w*)(\(([^)]*)\))?\s*(.*)', rest)
                if not match:
                    raise CompileError(f'line {number}: bad #define')
                parameters = None
                if match.group(2) is not None:
                    parameters = [p.strip() for p in match.group(3).split(',') if p.strip()]
                self.macros[match.group(1)] = (parameters, tokenize(match.group(4), number))
            elif directive == 'undef':
                self.macros.pop(rest.split()[0] if rest else '', None)
            elif directive == 'error':
                raise CompileError(f'line {number}: #error {rest}')
            else:
                raise CompileError(f'line {number}: unsupported directive #{directive}')
        if stack:
            raise CompileError('#if without #endif')
        return tokens + [Token('eof', None, len(lines))]

    def condition(self, text, line):
        raw, out, i = tokenize(text, line), [], 0
        while i < len(raw):
            t = raw[i]
            if t.kind == 'id' and t.value == 'defined':
                parenthesized = i + 1 < len(raw) and raw[i + 1].value == '('
                name = raw[i + 2 if parenthesized else i + 1]
                out.append(Token('num', (1 if name.value in self.macros else 0, 'int'), line))
                i += 4 if parenthesized else 2
            else:
                out.append(t)
                i += 1
        out = [Token('num', (0, 'int'), line) if t.kind == 'id' else t for t in self.expand(out)]
        parser = Parser(out + [Token('eof', None, line)])
        value = fold(parser.expression())
        if value is None or parser.peek().kind != 'eof':
            raise CompileError(f'line {line}: #if needs a constant expression')
        return value != 0

    def expand(self, tokens, hidden=frozenset()):
        out, i = [], 0
        while i < len(tokens):
            t = tokens[i]
            if t.kind != 'id' or t.value not in self.macros or t.value in hidden:
                out.append(t)
                i += 1
                continue
            parameters, body = self.macros[t.value]
            if parameters is None:
                out += self.expand([b.at(t.line) for b in body], hidden | {t.value})
                i += 1
                continue
            if i + 1 >= len(tokens) or tokens[i + 1].value != '(':
                out.append(t)
                i += 1
                continue
            arguments, depth, j = [[]], 0, i + 2
            while j < len(tokens):
                v = tokens[j].value if tokens[j].kind == 'op' else None
                if v == '(':
                    depth += 1
                elif v == ')':
                    if depth == 0:
                        break
                    depth -= 1
                elif v == ',' and depth == 0:
                    arguments.append([])
                    j += 1
                    continue
                arguments[-1].append(tokens[j])
                j += 1
            if j >= len(tokens):
                raise CompileError(f'line {t.line}: unterminated call of macro {t.value}')
            if arguments == [[]]:
                arguments = []
            if len(arguments) != len(parameters):
                raise CompileError(f'line {t.line}: macro {t.value} takes {len(parameters)} arguments')
            values = {p: self.expand(a, hidden) for p, a in zip(parameters, arguments)}
            substituted = []
            for b in body:
                substituted += values[b.value] if b.kind == 'id' and b.value in values else [b.at(t.line)]
            out += self.expand(substituted, hidden | {t.value})
            i = j + 1
        return out


# ---------------------------------------------------------------- parsing

class Node:
    def __init__(self, kind, line, **fields):
        self.kind, self.line = kind, line
        self.__dict__.update(fields)


class Var:
    def __init__(self, name, ctype, length, function, line):
        self.name, self.ctype, self.length, self.function, self.line = name, ctype, length, function, line
        self.slot = None  # status register, for scalars
        self.base = None  # main-memory nibble address, for arrays
        self.init = None
        self.volatile = False


class Function:
    def __init__(self, name, ctype, line):
        self.name, self.ctype, self.line = name, ctype, line
        self.params, self.locals, self.body, self.temps = [], [], None, []
        self.label = self.ret_slot = None
        self.interrupt = False
        self.user_labels, self.gotos = {}, []


SPECIFIERS = {'__interrupt', '__nibble', 'int', 'char', 'unsigned', 'signed', 'short', 'long', 'void', '_Bool', 'static', 'extern',
              'register', 'auto', 'const', 'volatile', 'float', 'double', 'struct', 'union', 'enum', 'typedef'}
KEYWORDS = SPECIFIERS | {'if', 'else', 'while', 'do', 'for', 'switch', 'case', 'default',
                         'goto', 'break', 'continue', 'return', 'sizeof'}
BINARY = {'||': 1, '&&': 2, '|': 3, '^': 4, '&': 5, '==': 6, '!=': 6, '<': 7, '>': 7, '<=': 7, '>=': 7,
          '<<': 8, '>>': 8, '+': 9, '-': 9, '*': 10, '/': 10, '%': 10}
ASSIGNMENTS = {'=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>='}
COMPARISONS = {'<', '>', '<=', '>=', '==', '!='}


class Parser:
    def __init__(self, tokens):
        self.tokens, self.pos = tokens, 0
        self.globals, self.functions, self.scopes, self.function = {}, {}, [], None
        self.switches, self.return_types, self.unevaluated = [], {}, 0
        self.qualifiers = set()

    def peek(self, ahead=0):
        return self.tokens[min(self.pos + ahead, len(self.tokens) - 1)]

    def next(self):
        t = self.peek()
        self.pos += 1
        return t

    def error(self, message, token=None):
        return CompileError(f'line {(token or self.peek()).line}: {message}')

    def is_op(self, value, ahead=0):
        t = self.peek(ahead)
        return t.kind == 'op' and t.value == value

    def accept(self, value):
        if self.is_op(value):
            return self.next()
        return None

    def expect(self, value):
        if not self.is_op(value):
            t = self.peek()
            raise self.error(f'expected {value!r}' + (f' before {t.value!r}' if t.kind != 'eof' else ' at the end'))
        return self.next()

    def identifier(self):
        t = self.next()
        if t.kind != 'id' or t.value in KEYWORDS:
            raise self.error('expected a name', t)
        return t.value

    def at_type(self):
        t = self.peek()
        return t.kind == 'id' and t.value in SPECIFIERS

    def specifiers(self):
        words, line = [], self.peek().line
        while self.at_type():
            words.append(self.next().value)
        self.qualifiers = set(words)  # volatile and __interrupt, for the declarator
        if not words:
            return None
        if words == ['__interrupt']:
            return 'int'
        for word in ('float', 'double', 'struct', 'union', 'enum', 'typedef'):
            if word in words:
                raise CompileError(f'line {line}: {word} is not supported')
        if 'long' in words:
            raise CompileError(f'line {line}: long is not supported; int is 16 bits')
        if 'void' in words:
            return 'void'
        if '__nibble' in words:
            return 'nibble'
        if '_Bool' in words:
            return 'bool'
        if 'char' in words:
            return 'char'
        if 'unsigned' in words:
            return 'unsigned'
        return 'int'

    # declarations

    def program(self):
        while self.peek().kind != 'eof':
            line = self.peek().line
            ctype = self.specifiers()
            if ctype is None:
                if self.peek().kind == 'id' and self.is_op('(', 1):
                    ctype = 'int'  # an old-style function definition
                else:
                    raise self.error('expected a declaration')
            if self.accept(';'):
                continue
            while True:
                if self.is_op('*'):
                    raise self.error('pointers are not supported')
                name = self.identifier()
                if self.accept('('):
                    self.function_definition(ctype, name, line)
                    break
                var = self.declarator(ctype, name, None, line)
                if name in self.globals:
                    raise self.error(f'{name} is declared twice')
                self.globals[name] = var
                if self.accept('='):
                    if var.length is not None:
                        raise self.error('array initializers are not supported')
                    var.init = self.assignment()
                    if fold(var.init) is None:
                        raise self.error(f'the initializer of {name} is not constant')
                if not self.accept(','):
                    self.expect(';')
                    break
        return self.globals, self.functions

    def declarator(self, ctype, name, function, line):
        if ctype == 'void':
            raise self.error(f'{name} cannot be void')
        length = None
        if self.accept('['):
            length = fold(self.expression())
            if length is None or not 0 < length <= 0x7FFF:
                raise self.error(f'the length of {name} must be a positive constant')
            self.expect(']')
        elif ctype == 'bool':
            ctype = 'char'  # scalar _Bool: a char that holds 0 or 1
            var = Var(name, ctype, None, function, line)
            var.boolean, var.volatile = True, 'volatile' in self.qualifiers
            return var
        var = Var(name, ctype, length, function, line)
        var.boolean, var.volatile = False, 'volatile' in self.qualifiers
        return var

    def function_definition(self, ctype, name, line):
        self.return_types[name] = ctype
        interrupt = '__interrupt' in getattr(self, 'qualifiers', ())
        typed, names = [], []
        if self.accept(')'):
            pass
        elif self.at_type():
            if self.peek().value == 'void' and self.is_op(')', 1):
                self.next()
            else:
                while True:
                    ptype = self.specifiers()
                    if ptype is None or self.is_op('*'):
                        raise self.error('pointers are not supported')
                    typed.append((ptype, self.identifier() if self.peek().kind == 'id' else None))
                    if self.is_op('['):
                        raise self.error('array parameters are not supported')
                    if not self.accept(','):
                        break
            self.expect(')')
        else:
            while True:
                names.append(self.identifier())
                if not self.accept(','):
                    break
            self.expect(')')
        if self.accept(';'):
            return  # a prototype
        if names:  # old-style parameter declarations
            types = {}
            while self.at_type():
                ptype = self.specifiers()
                while True:
                    if self.is_op('*'):
                        raise self.error('pointers are not supported')
                    pname = self.identifier()
                    if self.is_op('['):
                        raise self.error('array parameters are not supported')
                    types[pname] = ptype
                    if not self.accept(','):
                        break
                self.expect(';')
            typed = [(types.get(n, 'int'), n) for n in names]
        if name in self.functions:
            raise CompileError(f'line {line}: function {name} is defined twice')
        f = Function(name, ctype, line)
        f.interrupt = interrupt
        self.functions[name] = f
        self.function = f
        self.scopes = [{}]
        for ptype, pname in typed:
            if ptype == 'void':
                raise self.error(f'parameter {pname} cannot be void')
            var = Var(pname, ptype, None, f, line)
            var.boolean = ptype == 'bool'
            if var.boolean:
                var.ctype = 'char'
            f.params.append(var)
            self.scopes[0][pname] = var
        if not self.is_op('{'):
            raise self.error(f'expected the body of {name}')
        f.body = self.compound()
        for jump in f.gotos:
            if jump.name not in f.user_labels:
                raise CompileError(f'line {jump.line}: label {jump.name} is not defined in {name}')
        self.function, self.scopes = None, []

    # statements

    def compound(self):
        line = self.expect('{').line
        self.scopes.append({})
        body = []
        while not self.accept('}'):
            if self.peek().kind == 'eof':
                raise self.error('missing }')
            body.append(self.statement())
        self.scopes.pop()
        return Node('block', line, body=body)

    def local_declaration(self):
        line = self.peek().line
        ctype = self.specifiers()
        items = []
        while True:
            if self.is_op('*'):
                raise self.error('pointers are not supported')
            name = self.identifier()
            var = self.declarator(ctype, name, self.function, line)
            init = None
            if self.accept('='):
                if var.length is not None:
                    raise self.error('array initializers are not supported')
                init = self.assignment()
            self.function.locals.append(var)
            self.scopes[-1][name] = var
            items.append((var, init))
            if not self.accept(','):
                break
        self.expect(';')
        return Node('decl', line, items=items)

    def statement(self):
        t = self.peek()
        line = t.line
        if self.is_op('{'):
            return self.compound()
        if self.accept(';'):
            return Node('empty', line)
        if self.at_type():
            return self.local_declaration()
        if t.kind == 'id':
            word = t.value
            if word not in KEYWORDS and self.is_op(':', 1):
                self.next()
                self.expect(':')
                if word in self.function.user_labels:
                    raise self.error(f'label {word} is defined twice', t)
                self.function.user_labels[word] = line
                return Node('label', line, name=word, body=self.statement())
            if word == 'goto':
                self.next()
                name = self.identifier()
                self.expect(';')
                jump = Node('goto', line, name=name)
                self.function.gotos.append(jump)
                return jump
            if word == 'switch':
                self.next()
                self.expect('(')
                c = self.expression()
                self.expect(')')
                if c.kind == 'str' or self.void_expression(c):
                    raise self.error('switch needs an integer expression', t)
                switch = Node('switch', line, c=c, cases=[], default=None)
                self.switches.append(switch)
                switch.body = self.statement()
                self.switches.pop()
                return switch
            if word in ('case', 'default'):
                self.next()
                if not self.switches:
                    raise self.error(f'{word} is not in a switch', t)
                switch = self.switches[-1]
                value = None
                if word == 'case':
                    value = fold(self.conditional())
                    if value is None:
                        raise self.error('case needs an integer constant expression', t)
                    if any(case.value == value for case in switch.cases):
                        raise self.error('duplicate case value', t)
                elif switch.default is not None:
                    raise self.error('duplicate default label', t)
                self.expect(':')
                case = Node('case', line, value=value)
                if word == 'case':
                    switch.cases.append(case)
                else:
                    switch.default = case
                case.body = self.statement()
                return case
            if word == 'if':
                self.next()
                self.expect('(')
                c = self.expression()
                self.expect(')')
                then = self.statement()
                other = None
                if self.peek().kind == 'id' and self.peek().value == 'else':
                    self.next()
                    other = self.statement()
                return Node('if', line, c=c, then=then, other=other)
            if word == 'while':
                self.next()
                self.expect('(')
                c = self.expression()
                self.expect(')')
                return Node('while', line, c=c, body=self.statement())
            if word == 'do':
                self.next()
                body = self.statement()
                if not (self.peek().kind == 'id' and self.peek().value == 'while'):
                    raise self.error('expected while')
                self.next()
                self.expect('(')
                c = self.expression()
                self.expect(')')
                self.expect(';')
                return Node('do', line, c=c, body=body)
            if word == 'for':
                self.next()
                self.expect('(')
                self.scopes.append({})
                if self.at_type():
                    init = self.local_declaration()
                else:
                    init = None if self.is_op(';') else Node('expr', line, e=self.expression())
                    self.expect(';')
                c = None if self.is_op(';') else self.expression()
                self.expect(';')
                step = None if self.is_op(')') else self.expression()
                self.expect(')')
                body = self.statement()
                self.scopes.pop()
                return Node('for', line, init=init, c=c, step=step, body=body)
            if word in ('break', 'continue'):
                self.next()
                self.expect(';')
                return Node(word, line)
            if word == 'return':
                self.next()
                e = None if self.is_op(';') else self.expression()
                self.expect(';')
                return Node('return', line, e=e)
        e = self.expression()
        self.expect(';')
        return Node('expr', line, e=e)

    # expressions

    def expression(self):
        e = self.assignment()
        while self.is_op(','):
            line = self.next().line
            e = Node('binary', line, op=',', l=e, r=self.assignment())
        return e

    def assignment(self):
        left = self.conditional()
        t = self.peek()
        if t.kind == 'op' and t.value in ASSIGNMENTS:
            self.next()
            self.lvalue(left, t)
            return Node('assign', t.line, op=t.value, target=left, value=self.assignment())
        return left

    def lvalue(self, e, t):
        if e.kind not in ('var', 'index'):
            raise self.error('the left side cannot be assigned', t)

    def conditional(self):
        c = self.binary(1)
        if self.is_op('?'):
            line = self.next().line
            a = self.expression()
            self.expect(':')
            return Node('cond', line, c=c, a=a, b=self.conditional())
        return c

    def binary(self, level):
        left = self.unary()
        while True:
            t = self.peek()
            precedence = BINARY.get(t.value) if t.kind == 'op' else None
            if precedence is None or precedence < level:
                return left
            self.next()
            left = Node('binary', t.line, op=t.value, l=left, r=self.binary(precedence + 1))

    def unary(self):
        t = self.peek()
        if t.kind == 'op':
            if t.value in ('++', '--'):
                self.next()
                target = self.unary()
                self.lvalue(target, t)
                return Node('incdec', t.line, op=t.value, prefix=True, target=target)
            if t.value in ('-', '+', '~', '!'):
                self.next()
                return Node('unary', t.line, op=t.value, x=self.unary())
            if t.value in ('&', '*'):
                raise self.error('pointers are not supported')
            if t.value == '(' and self.peek(1).kind == 'id' and self.peek(1).value in SPECIFIERS:
                self.next()
                ctype = self.specifiers()
                if self.is_op('*'):
                    raise self.error('pointers are not supported')
                self.expect(')')
                return Node('cast', t.line, ctype=ctype, x=self.unary())
        if t.kind == 'id' and t.value == 'sizeof':
            self.next()
            if self.is_op('(') and self.peek(1).value in SPECIFIERS:
                self.next()
                qualifiers = self.qualifiers
                ctype = self.specifiers()
                self.qualifiers = qualifiers
                length = 1
                if self.accept('['):
                    length = fold(self.conditional())
                    if length is None or not 0 < length <= 0x7FFF:
                        raise self.error('sizeof array needs a positive constant length', t)
                    self.expect(']')
                self.expect(')')
                size = self.type_size(ctype, t) * length
            else:
                self.unevaluated += 1
                operand = self.unary()
                self.unevaluated -= 1
                size = self.operand_size(operand, t)
            if size > 0xFFFF:
                raise self.error('sizeof result does not fit in 16 bits', t)
            return Node('num', t.line, value=size, ctype='unsigned')
        return self.postfix(self.primary())

    def postfix(self, e):
        while True:
            t = self.peek()
            if self.is_op('['):
                self.next()
                if e.kind != 'var' or e.var.length is None:
                    raise self.error('only arrays can be indexed', t)
                index = self.expression()
                self.expect(']')
                e = Node('index', t.line, var=e.var, index=index)
            elif t.kind == 'op' and t.value in ('++', '--'):
                self.next()
                self.lvalue(e, t)
                e = Node('incdec', t.line, op=t.value, prefix=False, target=e)
            else:
                if e.kind == 'var' and e.var.length is not None and not self.unevaluated:
                    raise self.error(f'array {e.var.name} needs an index; pointers are not supported', t)
                return e

    def void_expression(self, e):
        if e.kind == 'cast':
            return e.ctype == 'void'
        if e.kind == 'call':
            return self.return_types.get(e.name) == 'void'
        if e.kind == 'binary' and e.op == ',':
            return self.void_expression(e.r)
        if e.kind == 'cond':
            return self.void_expression(e.a) or self.void_expression(e.b)
        return False

    def type_size(self, ctype, token):
        if ctype == 'void':
            raise self.error('sizeof cannot be applied to void', token)
        return 2 if ctype in ('int', 'unsigned') else 1

    def operand_size(self, e, token):
        # No integer promotion for a bare object, cast, assignment or ++/--.
        if self.void_expression(e):
            raise self.error('sizeof cannot be applied to void', token)
        if e.kind == 'str':
            return len(e.data) + 1
        if e.kind == 'var' and e.var.length is not None:
            return self.type_size(e.var.ctype, token) * e.var.length
        if any(n.kind == 'var' and n.var.length is not None for n in walk(e)):
            raise self.error('pointers are not supported', token)
        if e.kind in ('var', 'index'):
            ctype = e.var.ctype
        elif e.kind == 'cast':
            ctype = e.ctype
        elif e.kind in ('assign', 'incdec'):
            return self.operand_size(e.target, token)
        elif e.kind == 'binary' and e.op == ',':
            if e.r.kind in ('str', 'var') and (e.r.kind == 'str' or e.r.var.length is not None):
                raise self.error('pointers are not supported', token)
            return self.operand_size(e.r, token)
        elif e.kind == 'call':
            ctype = self.return_types.get(e.name, 'int')
        else:
            ctype = etype(e)
        return self.type_size(ctype, token)

    def lookup(self, name):
        for scope in reversed(self.scopes):
            if name in scope:
                return scope[name]
        return self.globals.get(name)

    def primary(self):
        t = self.next()
        if t.kind == 'num':
            return Node('num', t.line, value=t.value[0], ctype=t.value[1])
        if t.kind == 'str':
            data = t.value
            while self.peek().kind == 'str':
                data += self.next().value
            return Node('str', t.line, data=data)
        if t.kind == 'op' and t.value == '(':
            e = self.expression()
            self.expect(')')
            return e
        if t.kind == 'id' and t.value not in SPECIFIERS:
            if self.is_op('('):
                self.next()
                args = []
                if not self.accept(')'):
                    while True:
                        args.append(self.assignment())
                        if not self.accept(','):
                            break
                    self.expect(')')
                return Node('call', t.line, name=t.value, args=args)
            var = self.lookup(t.value)
            if var is None:
                raise self.error(f'{t.value} is not declared', t)
            return Node('var', t.line, var=var)
        raise self.error('expected an expression' if t.kind != 'eof' else 'unexpected end of file', t)


# ---------------------------------------------------------------- constants and types

def s16(v):
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


def etype(e):
    """'unsigned' or 'int': the type an expression has after promotion."""
    kind = e.kind
    if kind == 'num':
        return e.ctype
    if kind in ('var', 'index'):
        return 'unsigned' if e.var.ctype == 'unsigned' else 'int'
    if kind == 'call':
        return getattr(e, 'returns', 'int')
    if kind == 'unary':
        return 'int' if e.op == '!' else etype(e.x)
    if kind == 'binary':
        if e.op in COMPARISONS or e.op in ('&&', '||'):
            return 'int'
        if e.op == ',':
            return etype(e.r)
        if e.op in ('<<', '>>'):
            return etype(e.l)
        return 'unsigned' if 'unsigned' in (etype(e.l), etype(e.r)) else 'int'
    if kind in ('assign', 'incdec'):
        return etype(e.target)
    if kind == 'cond':
        return 'unsigned' if 'unsigned' in (etype(e.a), etype(e.b)) else 'int'
    if kind == 'cast':
        return 'unsigned' if e.ctype == 'unsigned' else 'int'
    return 'int'


def divide(a, b, unsigned, line):
    if b == 0:
        raise CompileError(f'line {line}: division by zero')
    if unsigned:
        return a // b, a % b
    a, b = s16(a), s16(b)
    q = abs(a) // abs(b) * (1 if (a < 0) == (b < 0) else -1)
    return q & 0xFFFF, (a - q * b) & 0xFFFF


def fold(e):
    """The 16-bit value of a constant expression, or None."""
    kind = e.kind
    if kind == 'num':
        return e.value & 0xFFFF
    if kind == 'unary':
        x = fold(e.x)
        if x is None:
            return None
        return {'-': -x, '+': x, '~': ~x, '!': int(x == 0)}[e.op] & 0xFFFF
    if kind == 'cast':
        x = fold(e.x)
        if x is None:
            return None
        return {'char': x & 0xFF, 'nibble': x & 15, 'bool': int(x != 0)}.get(e.ctype, x)
    if kind == 'cond':
        c = fold(e.c)
        if c is None:
            return None
        return fold(e.a if c else e.b)
    if kind != 'binary' or e.op == ',':
        return None
    left, right = fold(e.l), fold(e.r)
    if left is None or right is None:
        return None
    unsigned = 'unsigned' in (etype(e.l), etype(e.r))
    a, b = (left, right) if unsigned else (s16(left), s16(right))
    op = e.op
    if op in ('/', '%'):
        return divide(left, right, unsigned, e.line)[op == '%']
    if op == '<<':
        return (left << right) & 0xFFFF if right < 16 else 0
    if op == '>>':
        if etype(e.l) == 'unsigned':
            return left >> right if right < 16 else 0
        return (s16(left) >> min(right, 15)) & 0xFFFF
    value = {'+': a + b, '-': a - b, '*': a * b, '&': a & b, '|': a | b, '^': a ^ b, '<': a < b, '>': a > b,
             '<=': a <= b, '>=': a >= b, '==': a == b, '!=': a != b, '&&': bool(a) and bool(b),
             '||': bool(a) or bool(b)}[op]
    return int(value) & 0xFFFF


def walk(e):
    """Every expression node in e."""
    if e is None:
        return
    yield e
    for field in ('x', 'l', 'r', 'c', 'a', 'b', 'target', 'value', 'index'):
        child = getattr(e, field, None)
        if isinstance(child, Node):
            yield from walk(child)
    for child in getattr(e, 'args', []):
        yield from walk(child)


def has_effects(e):
    return any(n.kind in ('assign', 'incdec', 'call') for n in walk(e))


def statements(s):
    """Every statement in s, and the expressions it contains."""
    if s is None:
        return
    yield s
    for field in ('then', 'other', 'body', 'init'):
        child = getattr(s, field, None)
        if isinstance(child, Node):
            yield from statements(child)
    if s.kind == 'block':
        for child in s.body:
            yield from statements(child)


def expressions(s):
    for st in statements(s):
        for field in ('c', 'e', 'step'):
            child = getattr(st, field, None)
            if isinstance(child, Node):
                yield from walk(child)
        if st.kind == 'decl':
            for _, init in st.items:
                yield from walk(init)


def pack(variables, owner):
    """Give each variable a status register, four nibbles to one; return [(slot, variables)]."""
    out, open_slot = [], None
    for v in variables:
        if v.ctype == 'nibble':
            if open_slot is None or len(open_slot[1]) == 4:
                open_slot = (Slot(f'{owner} {v.name}'), [])
                out.append(open_slot)
            v.slot, v.nib = open_slot[0], len(open_slot[1])
            open_slot[1].append(v)
        else:
            v.slot, v.nib = Slot(f'{owner} {v.name}'), None
            out.append((v.slot, [v]))
    return out


def references(e):
    return {n.var for n in walk(e) if n.kind == 'var'}


def own_expressions(s):
    """The expressions of statement s itself, not of the statements it contains."""
    if s.kind == 'decl':
        return [init for _, init in s.items if init is not None]
    return [getattr(s, field) for field in ('c', 'e', 'step') if isinstance(getattr(s, field, None), Node)]


def live_after_calls(f):
    """For each call in f, the variables that may be read after it returns: those of
    its statement, of every later statement, and of every loop around it."""
    order, loops_of, inside = [], {}, {}

    def visit(s, loops):
        index = len(order)
        order.append((s, set().union(*map(references, own_expressions(s))), loops))
        inner = loops + [s] if s.kind in ('while', 'do', 'for') else loops
        children = (s.body if s.kind == 'block' else [getattr(s, n) for n in ('init', 'then', 'other', 'body')
                                                       if isinstance(getattr(s, n, None), Node)])
        for child in children:
            visit(child, inner)
        if s.kind in ('while', 'do', 'for'):
            loops_of[id(s)] = set().union(*(refs for _, refs, _ in order[index:]))
        inside[id(s)] = inner

    visit(f.body, [])
    later, live = set(), {}
    for s, refs, loops in reversed(order):
        later |= refs
        around = set().union(*(loops_of[id(loop)] for loop in inside[id(s)]))
        for e in own_expressions(s):
            for n in walk(e):
                if n.kind == 'call':
                    live[id(n)] = later | around
    if f.gotos:
        # A backward jump can revisit any earlier read after a recursive call.
        all_refs = set().union(*(references(e) for e in expressions(f.body)))
        live = {call: refs | all_refs for call, refs in live.items()}
    return live


# ---------------------------------------------------------------- the runtime library
#
# Registers: A is R4 (high) to R7 (low), B is R8 to R11. R0R1 addresses
# status registers as register and bank, so a scalar's address is one byte.
# Helpers may use R0 to R3 and R12 to R15. Compiled code runs at stack level
# 0, since calls between C functions jump, so helpers may nest two deep.

RUNTIME = {}
REQUIRES = {}


def runtime(entries, text, requires=(), align=False):
    block = {'entries': entries.split(), 'text': text.strip('\n'), 'align': align}
    for entry in block['entries']:
        RUNTIME[entry] = block
        REQUIRES[entry] = list(requires)


runtime('QLDA', '''
; A = THE STATUS REGISTER AT R0R1 (REGISTER, BANK).
QLDA:   LD 1
        DCL
        SRC 0
        RD0
        XCH 4
        RD1
        XCH 5
        RD2
        XCH 6
        RD3
        XCH 7
        BBL 0''')
runtime('QLDB', '''
; B = THE STATUS REGISTER AT R0R1.
QLDB:   LD 1
        DCL
        SRC 0
        RD0
        XCH 8
        RD1
        XCH 9
        RD2
        XCH 10
        RD3
        XCH 11
        BBL 0''')
runtime('QSTAC QSTA', '''
; STORE A, OR ITS LOW BYTE, IN THE STATUS REGISTER AT R0R1.
QSTAC:  LDM 0
        XCH 4
        LDM 0
        XCH 5
QSTA:   LD 1
        DCL
        SRC 0
        LD 4
        WR0
        LD 5
        WR1
        LD 6
        WR2
        LD 7
        WR3
        BBL 0''')
runtime('QLDI', '''
; A = THE INT AT MAIN-MEMORY ADDRESS A (BANK, REGISTER, CHARACTER).
QLDI:   LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 4
        INC 1
        SRC 0
        RDM
        XCH 5
        INC 1
        SRC 0
        RDM
        XCH 6
        INC 1
        SRC 0
        RDM
        XCH 7
        BBL 0''')
runtime('QLDIC', '''
; A = THE CHAR AT MAIN-MEMORY ADDRESS A.
QLDIC:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 6
        INC 1
        SRC 0
        RDM
        XCH 7
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        BBL 0''')
runtime('QLDBI', '''
; B = THE INT AT MAIN-MEMORY CHARACTER R0R1 OF BANK ACC.
QLDBI:  DCL
        SRC 0
        RDM
        XCH 8
        INC 1
        SRC 0
        RDM
        XCH 9
        INC 1
        SRC 0
        RDM
        XCH 10
        INC 1
        SRC 0
        RDM
        XCH 11
        BBL 0''')
runtime('QLDBC', '''
; B = THE CHAR AT MAIN-MEMORY CHARACTER R0R1 OF BANK ACC.
QLDBC:  DCL
        SRC 0
        RDM
        XCH 10
        INC 1
        SRC 0
        RDM
        XCH 11
        LDM 0
        XCH 8
        LDM 0
        XCH 9
        BBL 0''')
# A __NIBBLE SCALAR IS STATUS CHARACTER K OF THE REGISTER AT R0R1.
for k in range(4):
    runtime(f'QLDN{k}', f'''
; A = STATUS CHARACTER {k} OF THE REGISTER AT R0R1, A NIBBLE.
QLDN{k}:  LD 1
        DCL
        SRC 0
        RD{k}
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
    runtime(f'QLBN{k}', f'''
; B = STATUS CHARACTER {k} OF THE REGISTER AT R0R1, A NIBBLE.
QLBN{k}:  LD 1
        DCL
        SRC 0
        RD{k}
        XCH 11
        LDM 0
        XCH 10
        LDM 0
        XCH 9
        LDM 0
        XCH 8
        BBL 0''')
    runtime(f'QSTN{k}', f'''
; STORE A'S LOW NIBBLE IN STATUS CHARACTER {k} AT R0R1; A = THAT NIBBLE.
QSTN{k}:  LD 1
        DCL
        SRC 0
        LD 7
        WR{k}
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
runtime('QLDIN', '''
; A = THE __NIBBLE AT MAIN-MEMORY ADDRESS A.
QLDIN:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
runtime('QSTIN', '''
; STORE B'S LOW NIBBLE AT MAIN-MEMORY ADDRESS A; A = THAT NIBBLE.
QSTIN:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 11
        WRM
        LD 11
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
runtime('QLBIN', '''
; B = THE __NIBBLE AT MAIN-MEMORY CHARACTER R0R1 OF BANK ACC.
QLBIN:  DCL
        SRC 0
        RDM
        XCH 11
        LDM 0
        XCH 10
        LDM 0
        XCH 9
        LDM 0
        XCH 8
        BBL 0''')
runtime('QSTIC QSTI QMOVB', '''
; STORE B, OR ITS LOW BYTE, AT MAIN-MEMORY ADDRESS A; THEN A = B.
QSTIC:  LDM 0
        XCH 8
        LDM 0
        XCH 9
        LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 10
        WRM
        INC 1
        SRC 0
        LD 11
        WRM
        JUN QMOVB
QSTI:   LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 8
        WRM
        INC 1
        SRC 0
        LD 9
        WRM
        INC 1
        SRC 0
        LD 10
        WRM
        INC 1
        SRC 0
        LD 11
        WRM
QMOVB:  LD 8
        XCH 4
        LD 9
        XCH 5
        LD 10
        XCH 6
        LD 11
        XCH 7
        BBL 0''')
runtime('QXAB', '''
; EXCHANGE A AND B.
QXAB:   LD 4
        XCH 8
        XCH 4
        LD 5
        XCH 9
        XCH 5
        LD 6
        XCH 10
        XCH 6
        LD 7
        XCH 11
        XCH 7
        BBL 0''')
runtime('QADD', '''
; A = A + B.
QADD:   CLC
        LD 7
        ADD 11
        XCH 7
        LD 6
        ADD 10
        XCH 6
        LD 5
        ADD 9
        XCH 5
        LD 4
        ADD 8
        XCH 4
        BBL 0''')
runtime('QSUB', '''
; A = A - B. SUB TAKES ONE MORE WHEN THE CARRY IS 1, AND SETS IT WHEN
; NOTHING IS BORROWED, SO CMC PASSES EACH BORROW ON.
QSUB:   CLC
        LD 7
        SUB 11
        XCH 7
        CMC
        LD 6
        SUB 10
        XCH 6
        CMC
        LD 5
        SUB 9
        XCH 5
        CMC
        LD 4
        SUB 8
        XCH 4
        BBL 0''')
runtime('QNEG QINC', '''
; A = -A, OR A = A + 1.
QNEG:   LD 4
        CMA
        XCH 4
        LD 5
        CMA
        XCH 5
        LD 6
        CMA
        XCH 6
        LD 7
        CMA
        XCH 7
QINC:   ISZ 7,QINCX
        ISZ 6,QINCX
        ISZ 5,QINCX
        INC 4
QINCX:  BBL 0''')
runtime('QDEC', '''
; A = A - 1. DAC SETS THE CARRY WHEN NOTHING IS BORROWED.
QDEC:   LD 7
        DAC
        XCH 7
        JCN 2,QDECX
        LD 6
        DAC
        XCH 6
        JCN 2,QDECX
        LD 5
        DAC
        XCH 5
        JCN 2,QDECX
        LD 4
        DAC
        XCH 4
QDECX:  BBL 0''')
runtime('QCPL', '''
; A = ~A.
QCPL:   LD 4
        CMA
        XCH 4
        LD 5
        CMA
        XCH 5
        LD 6
        CMA
        XCH 6
        LD 7
        CMA
        XCH 7
        BBL 0''')
runtime('QINCV', '''
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA''', ('QLDA', 'QINC', 'QSTA'))
runtime('QINCC', '''
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC''', ('QLDA', 'QINC', 'QSTA'))
runtime('QDECV', '''
; DECREMENT THE INT AT R0R1, LEAVING IT IN A.
QDECV:  JMS QLDA
        JMS QDEC
        JUN QSTA''', ('QLDA', 'QDEC', 'QSTA'))
runtime('QDECC', '''
; DECREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QDECC:  JMS QLDA
        JMS QDEC
        JUN QSTAC''', ('QLDA', 'QDEC', 'QSTA'))
runtime('QBOOL', '''
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
runtime('QSLT QULT QSGE QUGE QSGT QUGT QSLE QULE QFLIP QCMP QCMPR', '''
; COMPARE A WITH B, RETURNING 1 OR 0 IN THE ACCUMULATOR. THE SIGNED
; COMPARISONS FLIP THE SIGN BITS AND COMPARE UNSIGNED.
QSLT:   JMS QFLIP
QULT:   JMS QCMP
        JCN 2,QCF
QCT:    BBL 1
QSGE:   JMS QFLIP
QUGE:   JMS QCMP
        JCN 2,QCT
QCF:    BBL 0
QSGT:   JMS QFLIP
QUGT:   JMS QCMPR
        JCN 2,QCF
        BBL 1
QSLE:   JMS QFLIP
QULE:   JMS QCMPR
        JCN 2,QCT
        BBL 0
QFLIP:  CLC
        LDM 8
        ADD 4
        XCH 4
        CLC
        LDM 8
        ADD 8
        XCH 8
        BBL 0
; THE CARRY IS 1 IF A >= B (QCMP) OR B >= A (QCMPR).
QCMP:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        CMC
        LD 5
        SUB 9
        CMC
        LD 4
        SUB 8
        BBL 0
QCMPR:  CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        CMC
        LD 9
        SUB 5
        CMC
        LD 8
        SUB 4
        BBL 0''')
runtime('QEQ QNE', '''
; A == B OR A != B, RETURNING 1 OR 0 IN THE ACCUMULATOR.
QEQ:    CLC
        LD 4
        SUB 8
        JCN 0CH,QEF
        CLC
        LD 5
        SUB 9
        JCN 0CH,QEF
        CLC
        LD 6
        SUB 10
        JCN 0CH,QEF
        CLC
        LD 7
        SUB 11
        JCN 0CH,QEF
        BBL 1
QEF:    BBL 0
QNE:    CLC
        LD 4
        SUB 8
        JCN 0CH,QNT
        CLC
        LD 5
        SUB 9
        JCN 0CH,QNT
        CLC
        LD 6
        SUB 10
        JCN 0CH,QNT
        CLC
        LD 7
        SUB 11
        JCN 0CH,QNT
        BBL 0
QNT:    BBL 1''')
runtime('QEQ8', '''
; A == B IN THEIR LOW BYTES, RETURNING 1 OR 0: --SIZE'S NARROW EQUALITY.
QEQ8:   CLC
        LD 7
        SUB 11
        JCN 0CH,QE8F
        CLC
        LD 6
        SUB 10
        JCN 0CH,QE8F
        BBL 1
QE8F:   BBL 0''')
runtime('QGE8', '''
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0''')
runtime('QLE8', '''
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0''')
runtime('QTST QNOTZ', '''
; A != 0 OR A == 0, RETURNING 1 OR 0 IN THE ACCUMULATOR.
QTST:   LD 4
        JCN 0CH,QTT
        LD 5
        JCN 0CH,QTT
        LD 6
        JCN 0CH,QTT
        LD 7
        JCN 0CH,QTT
        BBL 0
QTT:    BBL 1
QNOTZ:  LD 4
        JCN 0CH,QZF
        LD 5
        JCN 0CH,QZF
        LD 6
        JCN 0CH,QZF
        LD 7
        JCN 0CH,QZF
        BBL 1
QZF:    BBL 0''')
runtime('QTEST', '''
; 1 IN THE ACCUMULATOR IF THE TEST PIN IS HIGH; JCN 1 JUMPS WHEN IT IS LOW.
QTEST:  JCN 1,QTS0
        BBL 1
QTS0:   BBL 0''')
runtime('QODD', '''
; THE LOW BIT OF A, IN THE ACCUMULATOR.
QODD:   LD 7
        RAR
        JCN 2,QOD1
        BBL 0
QOD1:   BBL 1''')
runtime('QAND1', '''
; A = A & 1.
QAND1:  LD 7
        RAR
        TCC
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0''')
runtime('QMUL', '''
; A = A * B: SHIFT THE PRODUCT IN R12-R15 LEFT AND ADD B FOR EACH BIT OF A.
QMUL:   LDM 0
        XCH 3
QMLP:   CLC
        LD 15
        RAL
        XCH 15
        LD 14
        RAL
        XCH 14
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        JCN 0AH,QMNO
        CLC
        LD 15
        ADD 11
        XCH 15
        LD 14
        ADD 10
        XCH 14
        LD 13
        ADD 9
        XCH 13
        LD 12
        ADD 8
        XCH 12
QMNO:   ISZ 3,QMLP
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0''')
runtime('QUDIV', '''
; A = A / B UNSIGNED, WITH THE REMAINDER IN R12-R15: 16 TIMES, SHIFT A INTO
; THE REMAINDER, AND SUBTRACT B, SETTING A QUOTIENT BIT, IF IT FITS. A'S
; LEADING ZERO NIBBLES ARE SKIPPED: THEIR QUOTIENT BITS ARE 0.
QUDIV:  FIM 12,0
        FIM 14,0
        LDM 0
        XCH 3
QDSK:   LD 4
        JCN 0CH,QDLP
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        CLC
        LDM 4
        ADD 3
        XCH 3
        JCN 0AH,QDSK
        BBL 0
QDLP:   CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        LD 15
        RAL
        XCH 15
        LD 14
        RAL
        XCH 14
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        JCN 2,QDSUB
        CLC
        LD 15
        SUB 11
        CMC
        LD 14
        SUB 10
        CMC
        LD 13
        SUB 9
        CMC
        LD 12
        SUB 8
        JCN 0AH,QDNO
QDSUB:  CLC
        LD 15
        SUB 11
        XCH 15
        CMC
        LD 14
        SUB 10
        XCH 14
        CMC
        LD 13
        SUB 9
        XCH 13
        CMC
        LD 12
        SUB 8
        XCH 12
        INC 7
QDNO:   ISZ 3,QDLP
        BBL 0''')
runtime('QUMOD QREMA', '''
; A = A % B UNSIGNED.
QUMOD:  JMS QUDIV
QREMA:  LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0''', ('QUDIV',))
runtime('QSDIV QSMOD QSPRE', '''
; SIGNED / AND %: DIVIDE THE MAGNITUDES. THE QUOTIENT IS NEGATIVE WHEN THE
; SIGNS DIFFER (R0), THE REMAINDER WHEN THE DIVIDEND IS NEGATIVE (R1).
QSDIV:  JMS QSPRE
        JMS QUDIV
        LD 0
        JCN 4,QSDX
        JMS QNEG
QSDX:   BBL 0
QSMOD:  JMS QSPRE
        JMS QUDIV
        JMS QREMA
        LD 1
        JCN 4,QSDX
        JMS QNEG
        BBL 0
QSPRE:  LDM 0
        XCH 0
        LDM 0
        XCH 1
        LD 4
        RAL
        JCN 0AH,QSP1
        JMS QNEG
        LDM 1
        XCH 0
        LDM 1
        XCH 1
QSP1:   LD 8
        RAL
        JCN 0AH,QSP2
        LD 8
        CMA
        XCH 8
        LD 9
        CMA
        XCH 9
        LD 10
        CMA
        XCH 10
        LD 11
        CMA
        XCH 11
        ISZ 11,QSP3
        ISZ 10,QSP3
        ISZ 9,QSP3
        INC 8
QSP3:   LD 0
        RAR
        CMC
        TCC
        XCH 0
QSP2:   BBL 0''', ('QUDIV', 'QUMOD', 'QNEG'))
runtime('QSHL1', '''
; A = A << 1.
QSHL1:  CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        BBL 0''')
runtime('QSHR1 QUSR1 QSHRC', '''
; A = A >> 1, SIGNED (QSHR1) OR UNSIGNED (QUSR1).
QSHR1:  LD 4
        RAL
        JUN QSHRC
QUSR1:  CLC
QSHRC:  LD 4
        RAR
        XCH 4
        LD 5
        RAR
        XCH 5
        LD 6
        RAR
        XCH 6
        LD 7
        RAR
        XCH 7
        BBL 0''')
runtime('QSHL QSHR QUSHR', '''
; A = A << B, OR A >> B SIGNED OR UNSIGNED.
QSHL:   JMS QBIG
        JCN 4,QSLL
        FIM 4,0
        FIM 6,0
        BBL 0
QSLL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QSHL1
        JUN QSLL
QSLX:   BBL 0
QUSHR:  JMS QBIG
        JCN 4,QURL
        FIM 4,0
        FIM 6,0
        BBL 0
QURL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QUSR1
        JUN QURL
QSHR:   JMS QBIG
        JCN 4,QSRL
        LDM 15
        XCH 11
QSRL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QSHR1
        JUN QSRL
; 1 IF B > 15.
QBIG:   LD 8
        JCN 0CH,QBIG1
        LD 9
        JCN 0CH,QBIG1
        LD 10
        JCN 0CH,QBIG1
        BBL 0
QBIG1:  BBL 1''', ('QSHL1', 'QSHR1'))
runtime('QAND QOR QXOR', '''
; A = A & B, A | B OR A ^ B, A BIT AT A TIME: R1 = THE SUM OF THE TWO BITS,
; WHOSE BIT 1 IS THE AND, BIT 0 THE EXCLUSIVE OR, AND SUM + 1'S BIT 1 THE OR.
QAND:   LDM 0
        JUN QLOG
QOR:    LDM 1
        JUN QLOG
QXOR:   LDM 2
QLOG:   XCH 2
        LDM 0
        XCH 3
QLGL:   CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        TCC
        XCH 1
        CLC
        LD 11
        RAL
        XCH 11
        LD 10
        RAL
        XCH 10
        LD 9
        RAL
        XCH 9
        LD 8
        RAL
        XCH 8
        TCC
        ADD 1
        XCH 1
        LD 2
        JCN 4,QLGA
        RAR
        JCN 2,QLGO
        LD 1
        RAR
        JUN QLGS
QLGO:   LD 1
        IAC
        RAR
        RAR
        JUN QLGS
QLGA:   LD 1
        RAR
        RAR
QLGS:   LD 15
        RAL
        XCH 15
        LD 14
        RAL
        XCH 14
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        ISZ 3,QLGL
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0''')
runtime('QPRTD QPRTU QPDIG', '''
; PRINT A IN DECIMAL, SIGNED (QPRTD) OR UNSIGNED (QPRTU). QPDIG PRINTS THE
; NUMBER OF TIMES B GOES INTO A, AND LEAVES THE REST, UNLESS IT IS A
; LEADING ZERO (R2 = 0).
QPRTD:  LD 4
        RAL
        JCN 0AH,QPRTU
        FIM 14,0F0H
        SRC 14
        LDM 2
        WRR
        LDM 13
        WRR
        JMS QNEG
QPRTU:  LDM 0
        XCH 2
        FIM 8,27H
        FIM 10,10H
        JMS QPDIG
        FIM 8,03H
        FIM 10,0E8H
        JMS QPDIG
        FIM 8,00H
        FIM 10,64H
        JMS QPDIG
        FIM 8,00H
        FIM 10,0AH
        JMS QPDIG
        FIM 14,0F0H
        SRC 14
        LDM 3
        WRR
        LD 7
        WRR
        BBL 0
QPDIG:  LDM 0
        XCH 3
QPDL:   CLC
        LD 7
        SUB 11
        XCH 15
        CMC
        LD 6
        SUB 10
        XCH 14
        CMC
        LD 5
        SUB 9
        XCH 13
        CMC
        LD 4
        SUB 8
        XCH 12
        JCN 0AH,QPDO
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        INC 3
        JUN QPDL
QPDO:   LD 3
        JCN 0CH,QPDP
        LD 2
        JCN 4,QPDX
QPDP:   LDM 1
        XCH 2
        FIM 14,0F0H
        SRC 14
        LDM 3
        WRR
        LD 3
        WRR
QPDX:   BBL 0''', ('QNEG',))
runtime('QPRTX QPHEX', '''
; PRINT A IN HEXADECIMAL WITHOUT LEADING ZEROS.
QPRTX:  LDM 0
        XCH 2
        LD 4
        JMS QPHEX
        LD 5
        JMS QPHEX
        LD 6
        JMS QPHEX
        LDM 1
        XCH 2
        LD 7
QPHEX:  XCH 3
        LD 3
        JCN 0CH,QPH1
        LD 2
        JCN 4,QPHX
QPH1:   LDM 1
        XCH 2
        FIM 14,0F0H
        SRC 14
        CLC
        LDM 9
        SUB 3
        JCN 0AH,QPHA
        LDM 3
        WRR
        LD 3
        WRR
        BBL 0
QPHA:   LDM 6
        WRR
        CLC
        LDM 7
        ADD 3
        WRR
QPHX:   BBL 0''')
runtime('QPUTC', '''
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0''')
runtime('QGETC', '''
; A = A CHARACTER FROM THE CONSOLE.
QGETC:  FIM 14,0F0H
        SRC 14
        RDR
        XCH 6
        RDR
        XCH 7
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        BBL 0''')


def bit_table():
    rows = []
    for bit in range(4):
        mask = 1 << bit
        values = [(v | mask) << 4 | (v & ~mask & 15) for v in range(16)]
        for half in (values[:8], values[8:]):
            rows.append('        DB ' + ','.join(f'0{v:02X}H' for v in half))
    return '\n'.join(rows)


runtime('QLBIT QSBIT QBADR', '''
; _BOOL ARRAYS: A IS A BIT ADDRESS, 4 TIMES THE NIBBLE PLUS THE BIT. ROW B
; OF THE TABLE, AT THE START OF THE PAGE, GIVES FOR EACH NIBBLE V THE BYTE
; (V OR 2**B) * 16 + (V AND NOT 2**B).
QBITT:
''' + bit_table() + '''
; SELECT THE NIBBLE, SHIFTING A RIGHT TWICE: THE FIRST SHIFT LEAVES BIT 0 IN
; THE CARRY, AND THE SECOND GIVES THE BANK, REGISTER AND CHARACTER, AND BIT 1.
; THEN R0 = THE BIT, R1 = THE NIBBLE, R12 = IT WITH THE BIT SET, R13 CLEAR.
QBADR:  CLC
        LD 4
        RAR
        XCH 4
        LD 5
        RAR
        XCH 5
        LD 6
        RAR
        XCH 6
        LD 7
        RAR
        XCH 7
        TCC
        XCH 0
        LD 4
        RAR
        LD 5
        RAR
        DCL
        LD 6
        RAR
        XCH 2
        LD 7
        RAR
        XCH 3
        TCC
        RAL
        ADD 0
        XCH 0
        SRC 2
        RDM
        XCH 1
        FIN 12
        BBL 0
; THE BIT AT A, IN THE ACCUMULATOR.
QLBIT:  JMS QBADR
        LD 12
        CLC
        SUB 1
        JCN 4,QLB1
        BBL 0
QLB1:   BBL 1
; SET THE BIT AT A TO WHETHER B IS NONZERO; A = 0 OR 1.
QSBIT:  JMS QBADR
        LD 8
        JCN 0CH,QSB1
        LD 9
        JCN 0CH,QSB1
        LD 10
        JCN 0CH,QSB1
        LD 11
        JCN 0CH,QSB1
        LD 13
        WRM
        FIM 4,0
        FIM 6,0
        BBL 0
QSB1:   LD 12
        WRM
        FIM 4,0
        FIM 6,1
        BBL 0''', align=True)
runtime('QSAVE QRSTR QLSP QSSP', '''
; THE SAVE STACK, FOR RECURSION: ITS POINTER IS IN STATUS REGISTER 0 OF
; BANK 0 (BANK, REGISTER, CHARACTER IN STATUS CHARACTERS 1 TO 3), AND EACH
; SAVED STATUS REGISTER TAKES 4 CHARACTERS OF MAIN MEMORY.
; QSAVE PUSHES 16 - R13 STATUS REGISTERS FROM R0R1 UP; QRSTR POPS THEM
; BACK, GIVEN R2R3 = -4 TIMES THEIR NUMBER. NEITHER CHANGES A.
QSAVE:  JMS QLSP
QSVL:   LD 1
        DCL
        SRC 0
        RD0
        XCH 8
        RD1
        XCH 9
        RD2
        XCH 10
        RD3
        XCH 11
        LD 12
        DCL
        SRC 14
        LD 8
        WRM
        INC 15
        SRC 14
        LD 9
        WRM
        INC 15
        SRC 14
        LD 10
        WRM
        INC 15
        SRC 14
        LD 11
        WRM
        ISZ 15,QSV1
        ISZ 14,QSV1
        INC 12
QSV1:   ISZ 0,QSV2
        INC 1
QSV2:   ISZ 13,QSVL
        JUN QSSP
QRSTR:  JMS QLSP
        CLC
        LD 15
        ADD 3
        XCH 15
        LD 14
        ADD 2
        XCH 14
        LDM 15
        ADD 12
        XCH 12
        JMS QSSP
QRSL:   LD 12
        DCL
        SRC 14
        RDM
        XCH 8
        INC 15
        SRC 14
        RDM
        XCH 9
        INC 15
        SRC 14
        RDM
        XCH 10
        INC 15
        SRC 14
        RDM
        XCH 11
        ISZ 15,QRS1
        ISZ 14,QRS1
        INC 12
QRS1:   LD 1
        DCL
        SRC 0
        LD 8
        WR0
        LD 9
        WR1
        LD 10
        WR2
        LD 11
        WR3
        ISZ 0,QRS2
        INC 1
QRS2:   ISZ 13,QRSL
        BBL 0
QLSP:   FIM 8,00H
        LDM 0
        DCL
        SRC 8
        RD1
        XCH 12
        RD2
        XCH 14
        RD3
        XCH 15
        BBL 0
QSSP:   FIM 8,00H
        LDM 0
        DCL
        SRC 8
        LD 12
        WR1
        LD 14
        WR2
        LD 15
        WR3
        BBL 0''')
runtime('QCLR', '''
; CLEAR 16 - R13 BANKS OF RAM, MAIN AND STATUS CHARACTERS, FROM BANK 0.
QCLR:   LDM 0
        XCH 12
QCLB:   LD 12
        DCL
        FIM 0,00H
QCLC:   SRC 0
        LDM 0
        WRM
        ISZ 1,QCLC
        WR0
        WR1
        WR2
        WR3
        ISZ 0,QCLC
        INC 12
        ISZ 13,QCLB
        BBL 0''')
runtime('QEXIT', '''
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT''')

STRING_LOOP = '''; PRINT THE STRING AT R0R1 ON THIS PAGE.
QS{n}:   FIM 14,0F0H
        SRC 14
QSL{n}:  FIN 2
        LD 2
        JCN 0CH,QSC{n}
        LD 3
        JCN 4,QSX{n}
QSC{n}:  LD 2
        WRR
        LD 3
        WRR
        ISZ 1,QSL{n}
        INC 0
        JUN QSL{n}
QSX{n}:  BBL 0'''
DISPATCH = '''; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
{table}
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0'''
DISPATCH_FIXED = 4 + 8
TWO_BYTES = {'FIM', 'JCN', 'JUN', 'JMS', 'ISZ'}
# Instructions --size may move into a shared stub: none jumps, returns or
# depends on its page.
STRAIGHT_LINE = {'JMS', 'FIM', 'LD', 'LDM', 'XCH', 'CLC', 'CMC', 'STC', 'ADD', 'SUB', 'IAC', 'DAC', 'RAL', 'RAR',
                 'TCC', 'CMA', 'DAA', 'KBP', 'TCS', 'INC', 'SRC', 'WRM', 'WMP', 'WRR', 'WR0', 'WR1', 'WR2', 'WR3',
                 'RDM', 'RDR', 'RD0', 'RD1', 'RD2', 'RD3', 'SBM', 'ADM', 'DCL', 'NOP'}


def block_size(text):
    size = 0
    for line in text.splitlines():
        code = asm4.code_field(line).strip()
        if ':' in code:
            code = code.split(':', 1)[1].strip()
        if not code:
            continue
        mnemonic, _, operands = code.partition(' ')
        if mnemonic == 'DB':
            size += len(asm4.split_operands(operands.strip()))
        else:
            size += 2 if mnemonic in TWO_BYTES else 1
    return size


STRING_LOOP_SIZE = block_size(STRING_LOOP.format(n=1))


def helper_levels():
    """Return-stack levels a JMS to each runtime entry uses, its own included.

    Follows each entry's code through fallthrough, branches and tail jumps,
    counting the deepest chain of calls, so --size can tell how deep an
    outlined stub may call.
    """
    code, at = [], {}
    for block in {id(b): b for b in RUNTIME.values()}.values():
        for line in block['text'].splitlines():
            field = asm4.code_field(line).strip()
            if ':' in field:
                label, field = field.split(':', 1)
                at[label.strip()] = len(code)
                field = field.strip()
            if field:
                mnemonic, _, operands = field.partition(' ')
                code.append((mnemonic, [o.strip() for o in operands.split(',')]))
        code.append(('END', []))  # blocks don't fall into each other
    levels = {}

    def level(entry, active=()):
        if entry not in levels:
            if entry in active or entry not in at:
                return 1
            calls, seen, work = set(), set(), [at[entry]]
            while work:
                i = work.pop()
                if i in seen:
                    continue
                seen.add(i)
                mnemonic, operands = code[i]
                if mnemonic == 'JMS':
                    calls.add(operands[0])
                if mnemonic in ('JUN', 'JCN', 'ISZ') and operands[-1] in at:
                    work.append(at[operands[-1]])
                if mnemonic not in ('JUN', 'BBL', 'JIN', 'END'):
                    work.append(i + 1)
            levels[entry] = 1 + max([0] + [level(c, active + (entry,)) for c in calls])
        return levels[entry]
    return {entry: level(entry) for entry in RUNTIME}


HELPER_LEVELS = helper_levels()
STACK_LEVELS = 3  # the 4004's return stack; compiled code runs at level 0


# ---------------------------------------------------------------- code generation

class Slot:
    """A status register: index 16 * bank + register."""

    def __init__(self, name):
        self.name, self.index = name, None

    def address(self):
        return (self.index & 15) << 4 | self.index >> 4


def number(value):
    return str(value) if value < 10 else f'0{value:X}H'


SIZES = {'int': 4, 'unsigned': 4, 'char': 2, 'nibble': 1}
LOAD = {'int': 'QLDI', 'unsigned': 'QLDI', 'char': 'QLDIC', 'nibble': 'QLDIN'}
STORE = {'int': 'QSTI', 'unsigned': 'QSTI', 'char': 'QSTIC', 'bool': 'QSBIT', 'nibble': 'QSTIN'}
SIGNED_COMPARE = {'<': 'QSLT', '<=': 'QSLE', '>': 'QSGT', '>=': 'QSGE', '==': 'QEQ', '!=': 'QNE'}
UNSIGNED_COMPARE = {'<': 'QULT', '<=': 'QULE', '>': 'QUGT', '>=': 'QUGE', '==': 'QEQ', '!=': 'QNE'}
ARITHMETIC = {'+': 'QADD', '-': 'QSUB', '*': 'QMUL', '&': 'QAND', '|': 'QOR', '^': 'QXOR', '<<': 'QSHL'}
BUILTINS = {'putchar', 'getchar', 'printf', 'puts', '__rom_out', '__rom_in', '__ram_out', '__test', '__kbp',
            '__ei', '__di', '__halt'}
HARDWARE = {'__rom_out': 2, '__rom_in': 1, '__ram_out': 3, '__test': 0, '__kbp': 1,
            '__ei': 0, '__di': 0, '__halt': 0}  # built-ins: argument counts
INSTRUCTIONS_4040 = {'__ei': 'EIN', '__di': 'DIN', '__halt': 'HLT'}
# Helpers that leave A unchanged, so it still holds the variable last loaded or stored.
KEEPS_A = {'QLDB', 'QLDBI', 'QLDBC', 'QSTA', 'QTST', 'QTEST', 'QNOTZ', 'QODD', 'QEQ', 'QNE', 'QPUTC', 'QSAVE', 'QRSTR',
           'QEQ8', 'QGE8', 'QLE8'}
ACCUMULATOR_ONLY = {'LD', 'LDM', 'CLC', 'CMC', 'STC', 'ADD', 'SUB', 'RAL', 'RAR', 'TCC', 'CMA', 'IAC', 'DAC',
                    'EIN', 'DIN', 'HLT'}
MIRROR = {'<': '>', '>': '<', '<=': '>=', '>=': '<=', '==': '==', '!=': '!='}
LEAVES_SLOT_IN_A = {'QLDA', 'QSTA', 'QSTAC', 'QINCV', 'QINCC', 'QDECV', 'QDECC'}
MEMORY_NIBBLES = 2048
STATUS_REGISTERS = 128


class Compiler:
    def __init__(self, source, name='program', cpu='4004', size=False):
        self.source_lines = source.splitlines()
        self.name, self.cpu = name, cpu
        self.size = size
        tokens = Preprocessor().run(source)
        self.globals, self.functions = Parser(tokens).program()
        if 'main' not in self.functions:
            raise CompileError('there is no main function')
        self.labels = 0
        self.used = set()
        self.strings = {}  # data -> (label, block number)
        self.string_blocks = []  # [free bytes, [(label, data)]]
        self.shared_accesses = []
        self.stub_levels = {}  # shared code's return-stack levels, as HELPER_LEVELS
        self.return_sites = []
        self.loops = []
        self.code = []
        self.inline_exit = None

    def compile(self):
        self.analyze()
        self.allocate_memory()
        body = []
        if self.handler:
            self.return_sites.append('QINTR')
            self.used.add('QSTAC')
        for f in self.reachable:
            if f.name in self.inlined:
                continue
            self.code = []
            self.live = live_after_calls(f)
            self.function, self.depth, self.last_line, self.a_holds = f, 0, None, None
            self.incoming, self.falls = {}, True
            f.jump_labels = {name: self.label() for name in f.user_labels}
            self.place(f.label)
            self.comment(f'{f.name}')
            self.statement(f.body)
            self.epilogue()
            body += self.code
        self.allocate_slots()
        self.code, self.a_holds, self.incoming, self.falls = [], None, {}, True
        self.startup()
        self.code += body
        self.code = self.shrink_code(self.code, keep=set(self.return_sites))
        if self.size:
            self.code = self.share_accesses(self.code)
            self.code = self.outline(self.code)
        return self.output()

    # analysis and allocation

    def analyze(self):
        for f in self.functions.values():
            f.calls = set()
            f.referenced = {n.var for n in expressions(f.body) if n.kind == 'var'}
            for e in expressions(f.body):
                if e.kind == 'call':
                    if e.name in BUILTINS:
                        continue
                    if e.name not in self.functions:
                        raise CompileError(f'line {e.line}: function {e.name} is not defined')
                    callee = self.functions[e.name]
                    if callee.name == 'main':
                        raise CompileError(f'line {e.line}: main cannot be called')
                    if len(e.args) != len(callee.params):
                        raise CompileError(f'line {e.line}: {e.name} takes {len(callee.params)} arguments')
                    e.returns = 'unsigned' if callee.ctype == 'unsigned' else 'int'
                    f.calls.add(callee.name)
        self.reach = {}
        for name in self.functions:
            seen, work = set(), [name]
            while work:
                for callee in self.functions[work.pop()].calls:
                    if callee not in seen:
                        seen.add(callee)
                        work.append(callee)
            self.reach[name] = seen
        order = ['main'] + sorted(self.reach['main'], key=lambda n: self.functions[n].line)
        self.handler = self.interrupt_handler()
        if self.handler:
            served = [self.handler.name] + sorted(self.reach[self.handler.name], key=lambda n: self.functions[n].line)
            order += served
        self.reachable = [self.functions[n] for n in order]
        self.recursive = any(f.name in self.reach[f.name] for f in self.reachable)
        call_counts = {}
        for owner in self.reachable:
            for e in expressions(owner.body):
                if e.kind == 'call':
                    call_counts[e.name] = call_counts.get(e.name, 0) + 1
        # A single-use leaf can share its caller's instruction stream without
        # a software-call return slot or a second copy of its body.
        self.inlined = {f.name for f in self.reachable if f.name != 'main' and not f.interrupt
                        and not f.user_labels and call_counts.get(f.name) == 1
                        and not any(e.kind == 'call' for e in expressions(f.body))}
        self.infer_narrow()
        names = set(asm4.MNEMONICS) | asm4.DIRECTIVES | asm4.OPERATORS
        keys = set()
        for i, f in enumerate(self.reachable, 1):
            label = re.sub(r'[^A-Z0-9]', '', f.name.upper())[:5]
            if (not label or not label[0].isalpha() or label[0] in 'LQS' or label in names or label in keys
                    or re.fullmatch(r'F\d+', label)):
                label = f'F{i:04d}'
            keys.add(label)
            f.label = label

    def interrupt_handler(self):
        """The __interrupt function, checked, or None."""
        handlers = [f for f in self.functions.values() if f.interrupt]
        if not handlers:
            return None
        f = handlers[0]
        where = f'line {f.line}: '
        if len(handlers) > 1:
            raise CompileError(where + 'a program has one __interrupt function')
        if self.cpu != '4040':
            raise CompileError(where + 'interrupts need the 4040 (--4040)')
        if f.name == 'main' or f.ctype != 'void' or f.params:
            raise CompileError(where + 'the __interrupt function must be void, take no parameters and not be main')
        callers = [g.name for g in self.functions.values() if f.name in g.calls]
        if callers:
            raise CompileError(where + f'{f.name} is the __interrupt function and cannot be called ({callers[0]})')
        shared = sorted(self.reach[f.name] & (self.reach['main'] | {'main'}))
        if shared:
            raise CompileError(where + f'{shared[0]} is called by both main and the __interrupt function; an '
                               'interrupt would overwrite its variables')
        if any(g in self.reach[g] for g in self.reach[f.name] | {f.name}):
            raise CompileError(where + 'the __interrupt function cannot reach a recursive function')
        return f

    def infer_narrow(self):
        """Find the variables and functions whose values always fit in 8 bits, and in
        4: assume all do, then drop any written with a wider value, by a compound
        assignment, ++ or --, until nothing changes."""
        self.narrow_vars, self.narrow_functions = {}, {}
        for bits in (8, 4):
            vars_ = {v for v in self.globals.values() if v.length is None
                     and (v.init is None or fold(v.init) < 1 << bits)}
            for f in self.reachable:
                vars_ |= {v for v in f.params + f.locals if v.length is None}
            self.narrow_vars[bits] = vars_
            self.narrow_functions[bits] = {f.name for f in self.reachable if f.ctype != 'void'}
            changed = True
            while changed:
                before = (len(vars_), len(self.narrow_functions[bits]))
                for f in self.reachable:
                    for s in statements(f.body):
                        if s.kind == 'decl':
                            for var, init in s.items:
                                if init is not None and not self.narrow(init, bits):
                                    vars_.discard(var)
                        elif s.kind == 'return' and (s.e is None or not self.narrow(s.e, bits)):
                            self.narrow_functions[bits].discard(f.name)
                    for e in expressions(f.body):
                        if e.kind in ('assign', 'incdec') and e.target.kind == 'var':
                            if e.kind == 'incdec' or e.op != '=' or not self.narrow(e.value, bits):
                                vars_.discard(e.target.var)
                        elif e.kind == 'call' and e.name not in BUILTINS:
                            for arg, param in zip(e.args, self.functions[e.name].params):
                                if not self.narrow(arg, bits):
                                    vars_.discard(param)
                changed = before != (len(vars_), len(self.narrow_functions[bits]))

    @staticmethod
    def fits(ctype, bits):
        return ctype in ('nibble', 'bool') or ctype == 'char' and bits >= 8

    def narrow(self, e, bits=8):
        """Whether e's value always fits in the given number of bits, unsigned."""
        k = fold(e)
        if k is not None:
            return k < 1 << bits
        kind = e.kind
        if kind == 'var':
            return (self.fits(e.var.ctype, bits) or getattr(e.var, 'boolean', False)
                    or e.var in self.narrow_vars.get(bits, ()))
        if kind == 'index':
            return self.fits(e.var.ctype, bits)
        if kind == 'cast':
            return self.fits(e.ctype, bits) or self.narrow(e.x, bits)
        if kind == 'unary':
            return e.op == '!'
        if kind == 'binary':
            if e.op in COMPARISONS or e.op in ('&&', '||'):
                return True
            if e.op == '&':
                return self.narrow(e.l, bits) or self.narrow(e.r, bits)
            if e.op in ('|', '^'):
                return self.narrow(e.l, bits) and self.narrow(e.r, bits)
            if e.op in ('>>', '/'):
                return self.narrow(e.l, bits) and (e.op == '>>' or self.narrow(e.r, bits))
            if e.op == ',':
                return self.narrow(e.r, bits)
            return False
        if kind == 'cond':
            return self.narrow(e.a, bits) and self.narrow(e.b, bits)
        if kind in ('assign', 'incdec'):
            return self.narrow(e.target, bits) if e.target.kind == 'var' or kind == 'assign' else False
        if kind == 'call':
            if e.name == 'getchar':
                return bits >= 8
            if e.name in ('__rom_in', '__test', '__kbp'):
                return True
            f = self.functions.get(e.name)
            return f is not None and (self.fits(f.ctype, bits) or f.name in self.narrow_functions.get(bits, ()))
        return False

    def allocate_memory(self):
        arrays = [v for v in self.globals.values() if v.length is not None]
        for f in self.reachable:
            for v in f.locals:
                if v.length is not None:
                    if f.name in self.reach[f.name]:
                        raise CompileError(f'line {v.line}: recursive function {f.name} cannot have local array '
                                           f'{v.name}')
                    arrays.append(v)
        top = 0
        for v in arrays:
            if v.ctype == 'bool':
                v.base, top = top, top + (v.length + 3) // 4
            else:
                size = SIZES[v.ctype]
                top = (top + size - 1) // size * size
                v.base, top = top, top + size * v.length
        if top > MEMORY_NIBBLES:
            raise CompileError(f'the arrays need {top} RAM characters; the 4002s have {MEMORY_NIBBLES}')
        self.stack_base = (top + 3) // 4 * 4
        self.memory_top = top
        if self.recursive and self.stack_base >= MEMORY_NIBBLES:
            raise CompileError('no RAM is left for the stack that recursion needs')
        self.global_slots = pack([v for v in self.globals.values() if v.length is None], 'global')
        for f in self.reachable:
            f.ret_slot = Slot(f'{f.name} return')
            f.slot_vars = pack([v for v in f.params + f.locals if v.length is None], f.name)

    def frame(self, f):
        """The function's status registers, in order: return, parameters, locals."""
        return [f.ret_slot] + [slot for slot, _ in f.slot_vars]

    def allocate_slots(self):
        slots = [slot for slot, _ in self.global_slots]
        if self.handler:  # the interrupted program's R8-R15, and its accumulator, carry and RAM bank
            self.interrupt_slots = [Slot('interrupt save') for _ in range(3)]
            slots += self.interrupt_slots
        for f in self.reachable:
            slots += self.frame(f) + f.temps
        if len(slots) + 1 > STATUS_REGISTERS:
            raise CompileError(f'the program needs {len(slots) + 1} status registers for its variables; '
                               f'the 4002s have {STATUS_REGISTERS}')
        for index, slot in enumerate(slots, 1):  # register 0 of bank 0 holds the save-stack pointer
            slot.index = index
        self.slots_used = len(slots) + 1

    def startup(self):
        if self.handler:  # an interrupt starts at 003H
            self.op('JUN', 'QSTRT')
            # Fixed-address padding and the hardware vector are roots even
            # without C control-flow predecessors. Keep both during cleanup.
            self.place('QIPAD')
            self.op('NOP')
            self.place('QIVEC')
            self.op('JUN', 'QINT')
            self.place('QSTRT')
        banks = max((self.slots_used - 1) // 16, (max(self.memory_top, 1) - 1) // 256) + 1
        self.comment('clear the RAM')
        self.op('LDM', (16 - banks) & 15)
        self.op('XCH', 13)
        self.call('QCLR')
        if self.recursive:
            self.comment('the save stack')
            self.load_a_const(self.stack_base)
            self.op('FIM', 0, 0)
            self.call('QSTA')
        for v in self.globals.values():
            if v.init is not None and fold(v.init):
                self.comment(f'{v.name} = {s16(fold(v.init))}')
                self.load_a_const(fold(v.init))
                self.store_var(v)
        self.op('JUN', self.functions['main'].label)

    # emission

    def label(self):
        self.labels += 1
        if self.labels > 9999:
            raise CompileError('the program is too large: more than 9999 labels')
        return f'L{self.labels:04d}'

    def op(self, mnemonic, *operands):
        self.code.append(('op', mnemonic, operands))
        if mnemonic == 'JUN':
            self.incoming.setdefault(operands[0], []).append(self.a_holds)
        self.falls = mnemonic != 'JUN'
        if not (mnemonic == 'JMS' and operands[0] in KEEPS_A or mnemonic in ACCUMULATOR_ONLY
                or mnemonic in ('FIM', 'XCH') and operands[0] not in (4, 5, 6, 7)):
            self.a_holds = None

    def call(self, helper):
        self.used.add(helper)
        self.op('JMS', helper)

    def place(self, label, merge=False):
        """Place a label. With merge, every jump to it has been emitted, so A's
        contents are known if every way in agrees."""
        self.code.append(('label', label))
        states = self.incoming.pop(label, []) + ([self.a_holds] if self.falls else [])
        self.a_holds = states[0] if merge and states and all(s is states[0] for s in states) else None
        self.falls = True

    def jcn(self, condition, label):
        self.code.append(('jcn', condition, label))
        self.incoming.setdefault(label, []).append(self.a_holds)
        self.falls = True

    def jump(self, label):
        self.op('JUN', label)

    def comment(self, text):
        self.code.append(('comment', text))

    def source_comment(self, line):
        if line != self.last_line and 0 < line <= len(self.source_lines):
            self.last_line = line
            self.comment(self.source_lines[line - 1].strip())

    # values

    def load_a_const(self, value):
        self.op('FIM', 4, value >> 8 & 255)
        self.op('FIM', 6, value & 255)

    def load_b_const(self, value):
        self.op('FIM', 8, value >> 8 & 255)
        self.op('FIM', 10, value & 255)

    def load_slot(self, slot, helper='QLDA'):
        if helper == 'QLDA' and self.a_holds is slot:
            return
        self.op('FIM', 0, slot)
        self.call(helper)
        if helper in LEAVES_SLOT_IN_A:
            self.a_holds = slot

    def store_var(self, v):
        if getattr(v, 'boolean', False):
            self.call('QTST')
            self.call('QBOOL')
        if v.ctype == 'nibble':
            self.op('FIM', 0, v.slot)
            self.call(f'QSTN{v.nib}')
            self.a_holds = v
            return
        self.load_slot(v.slot, 'QSTAC' if v.ctype == 'char' else 'QSTA')

    def load_var(self, v):
        if v.volatile:  # an interrupt may change it: always load it
            self.a_holds = None
        if v.ctype != 'nibble':
            return self.load_slot(v.slot)
        if self.a_holds is v:
            return
        self.op('FIM', 0, v.slot)
        self.call(f'QLDN{v.nib}')
        self.a_holds = v

    def load_b_var(self, v):
        if v.ctype != 'nibble':
            return self.load_slot(v.slot, 'QLDB')
        self.op('FIM', 0, v.slot)
        self.call(f'QLBN{v.nib}')

    def push_temp(self):
        f = self.function
        if self.depth == len(f.temps):
            f.temps.append(Slot(f'{f.name} temporary {self.depth}'))
        self.depth += 1
        return f.temps[self.depth - 1]

    def pop_temp(self):
        self.depth -= 1

    def simple(self, e):
        """Whether e can be loaded into B without changing A."""
        return (fold(e) is not None or e.kind == 'var'
                or e.kind == 'index' and e.var.ctype != 'bool' and fold(e.index) is not None)

    def load_b(self, e):
        k = fold(e)
        if k is not None:
            self.load_b_const(k)
        elif e.kind == 'index':
            address = self.constant_address(e)
            self.op('FIM', 0, address & 255)
            self.op('LDM', address >> 8)
            self.call({'char': 'QLDBC', 'nibble': 'QLBIN'}.get(e.var.ctype, 'QLDBI'))
        else:
            self.load_b_var(e.var)

    def load_a(self, e):
        if e.kind == 'var':
            self.load_var(e.var)
        else:
            self.gen(e)

    def operands(self, left, right):
        """A = left, B = right."""
        if self.simple(right):
            self.gen(left)
            self.load_b(right)
        elif self.simple(left):
            self.gen(right)
            self.call('QXAB')
            self.load_a(left)
        else:
            self.gen(left)
            t = self.push_temp()
            self.load_slot(t, 'QSTA')
            self.gen(right)
            self.call('QXAB')
            self.load_slot(t)
            self.pop_temp()

    def gen(self, e, need=True):
        """Leave the value of e in A."""
        k = fold(e)
        if k is not None:
            if need:
                self.load_a_const(k)
            return
        if not need and not has_effects(e):
            return
        kind = e.kind
        if kind == 'var':
            self.load_var(e.var)
        elif kind == 'index':
            self.address(e)
            if e.var.ctype == 'bool':
                self.call('QLBIT')
                self.call('QBOOL')
            else:
                self.call(LOAD[e.var.ctype])
        elif kind == 'assign':
            self.assign(e)
        elif kind == 'incdec':
            self.incdec(e, need)
        elif kind == 'call':
            self.gen_call(e)
        elif kind == 'unary':
            self.gen(e.x)
            if e.op == '-':
                self.call('QNEG')
            elif e.op == '~':
                self.call('QCPL')
            elif e.op == '!':
                self.call('QNOTZ')
                self.call('QBOOL')
        elif kind == 'binary':
            if e.op == ',':
                self.gen(e.l, False)
                self.gen(e.r, need)
            elif e.op in COMPARISONS or e.op in ('&&', '||'):
                if e.op in COMPARISONS:
                    self.compare(e)
                else:
                    false, end = self.label(), self.label()
                    self.branch(e, false, False)
                    self.op('LDM', 1)
                    self.jump(end)
                    self.place(false, True)
                    self.op('LDM', 0)
                    self.place(end, True)
                self.call('QBOOL')
            else:
                self.arithmetic(e)
        elif kind == 'cond':
            other, end = self.label(), self.label()
            self.branch(e.c, other, False)
            self.gen(e.a)
            self.jump(end)
            self.place(other, True)
            self.gen(e.b)
            self.place(end, True)
        elif kind == 'cast':
            self.gen(e.x)
            if e.ctype == 'char':
                self.truncate()
            elif e.ctype == 'nibble':
                self.mask(15)
            elif e.ctype == 'bool':
                self.call('QTST')
                self.call('QBOOL')
        elif kind == 'str':
            raise CompileError(f'line {e.line}: strings can only be printed; pointers are not supported')
        else:
            raise CompileError(f'line {e.line}: cannot compile this expression')

    def truncate(self):
        self.op('LDM', 0)
        self.op('XCH', 4)
        self.op('LDM', 0)
        self.op('XCH', 5)

    def arithmetic(self, e):
        op, unsigned = e.op, etype(e) == 'unsigned'
        right, left = fold(e.r), fold(e.l)
        if op in ('+', '-') and right in (1, 0xFFFF):
            self.gen(e.l)
            self.call('QINC' if (op == '+') == (right == 1) else 'QDEC')
            return
        if op == '&' and right is not None:
            self.gen(e.l)
            return self.mask(right)
        if op == '&' and left is not None:
            self.gen(e.r)
            return self.mask(left)
        if op in ('<<', '>>') and right is not None:
            self.gen(e.l)
            return self.shift(op, right, etype(e.l) == 'unsigned')
        if op == '*' and right is not None and right and right & (right - 1) == 0:
            self.gen(e.l)
            return self.shift('<<', right.bit_length() - 1, False)
        if op == '*' and left is not None and left and left & (left - 1) == 0:
            self.gen(e.r)
            return self.shift('<<', left.bit_length() - 1, False)
        if op == '*' and (right is not None or left is not None):
            factor, other = (right, e.l) if right is not None else (left, e.r)
            if 0 < bin(factor).count('1') <= 4:
                return self.multiply(other, factor)
        if op in ('/', '%') and unsigned and right and right & (right - 1) == 0:
            self.gen(e.l)
            if op == '/':
                return self.shift('>>', right.bit_length() - 1, True)
            return self.mask(right - 1)
        if self.narrow(e.l) and self.narrow(e.r):
            unsigned = True  # nothing negative: the unsigned routines skip the signs
        self.operands(e.l, e.r)
        if op == '/':
            helper = 'QUDIV' if unsigned else 'QSDIV'
        elif op == '%':
            helper = 'QUMOD' if unsigned else 'QSMOD'
        elif op == '>>':
            helper = 'QUSHR' if etype(e.l) == 'unsigned' or self.narrow(e.l) else 'QSHR'
        else:
            helper = ARITHMETIC[op]
        self.call(helper)

    def multiply(self, e, factor):
        """A = e * factor by shifts and adds, highest bit first (Horner)."""
        bits = [k for k in range(16) if factor >> k & 1]
        self.gen(e)
        t = None
        if len(bits) > 1 and e.kind != 'var':
            t = self.push_temp()
            self.load_slot(t, 'QSTA')
        for high, low in zip(reversed(bits), list(reversed(bits))[1:]):
            self.shift('<<', high - low, False)
            if t is None:
                self.load_b_var(e.var)
            else:
                self.load_slot(t, 'QLDB')
            self.call('QADD')
        self.shift('<<', bits[0], False)
        if t is not None:
            self.pop_temp()

    def mask(self, value):
        if value == 1:
            return self.call('QAND1')
        nibbles = [value >> shift & 15 for shift in (12, 8, 4, 0)]
        if all(n in (0, 15) for n in nibbles):
            for register, n in zip((4, 5, 6, 7), nibbles):
                if n == 0:
                    self.op('LDM', 0)
                    self.op('XCH', register)
            return
        self.load_b_const(value)
        self.call('QAND')

    def shift(self, op, count, unsigned):
        if count >= 16:
            if op == '<<' or unsigned:
                return self.load_a_const(0)
            count = 15
        for _ in range(count // 4):
            if op == '<<':
                for target in (4, 5, 6):
                    self.op('LD', target + 1)
                    self.op('XCH', target)
                self.op('LDM', 0)
                self.op('XCH', 7)
            else:
                for target in (7, 6, 5):
                    self.op('LD', target - 1)
                    self.op('XCH', target)
                if unsigned:
                    self.op('LDM', 0)
                else:  # 0 or 15, from the sign
                    self.op('LD', 5)
                    self.op('RAL')
                    self.op('TCC')
                    self.op('CMA')
                    self.op('IAC')
                self.op('XCH', 4)
        helper = 'QSHL1' if op == '<<' else 'QUSR1' if unsigned else 'QSHR1'
        for _ in range(count % 4):
            self.call(helper)

    def compare(self, e):
        """Leave 1 in the accumulator if the comparison e holds, else 0."""
        left, right = fold(e.l), fold(e.r)
        if e.op in ('==', '!=') and (right == 0 or left == 0):
            self.gen(e.l if right == 0 else e.r)
            self.call('QNOTZ' if e.op == '==' else 'QTST')
            return
        unsigned = 'unsigned' in (etype(e.l), etype(e.r)) or self.narrow(e.l) and self.narrow(e.r)
        self.operands(e.l, e.r)
        self.call((UNSIGNED_COMPARE if unsigned else SIGNED_COMPARE)[e.op])

    def flag(self, e):
        """Leave a nonzero accumulator if e is true."""
        if e.kind == 'binary' and e.op in COMPARISONS:
            self.compare(e)
        elif e.kind == 'binary' and e.op == '&' and (fold(e.r) == 1 or fold(e.l) == 1):
            self.gen(e.l if fold(e.r) == 1 else e.r)
            self.call('QODD')
        elif e.kind == 'index' and e.var.ctype == 'bool':
            self.address(e)
            self.call('QLBIT')
        elif e.kind == 'call' and e.name == '__test':
            self.call('QTEST')
        elif e.kind == 'unary' and e.op == '!':
            self.gen(e.x)
            self.call('QNOTZ')
        else:
            self.gen(e)
            self.call('QTST')

    def branch(self, e, label, when):
        """Jump to label if e's truth is when."""
        k = fold(e)
        if k is not None:
            if bool(k) == when:
                self.jump(label)
            return
        if e.kind == 'unary' and e.op == '!':
            return self.branch(e.x, label, not when)
        if e.kind == 'binary' and e.op in ('&&', '||'):
            if (e.op == '&&') != when:
                self.branch(e.l, label, when)
                self.branch(e.r, label, when)
            else:
                skip = self.label()
                self.branch(e.l, skip, not when)
                self.branch(e.r, label, when)
                self.place(skip, True)
            return
        if e.kind == 'binary' and e.op == ',':
            self.gen(e.l, False)
            return self.branch(e.r, label, when)
        if e.kind == 'call' and e.name == '__test' and not e.args:  # JCN 1 jumps when TEST is low
            return self.jcn(9 if when else 1, label)
        if e.kind == 'binary' and e.op in COMPARISONS and self.narrow(e.l) and self.narrow(e.r):
            return self.narrow_branch(e.op, e.l, e.r, label, when)
        if not self.size and e.kind == 'binary' and e.op == '&' and 1 in (fold(e.l), fold(e.r)):
            operand = e.l if fold(e.r) == 1 else e.r
            if self.read_nibble(operand):
                self.op('RAR')
                self.jcn(2 if when else 0xA, label)
                return
        plain = not (e.kind == 'binary' and (e.op in COMPARISONS or e.op == '&' and 1 in (fold(e.l), fold(e.r)))
                     or e.kind == 'index' and e.var.ctype == 'bool')
        if plain and self.narrow(e):
            return self.narrow_zero(e, label, not when)
        self.flag(e)
        self.jcn(0xC if when else 4, label)

    def nibble_source(self, e):
        """A direct nibble operand, without arithmetic or function calls."""
        k = fold(e)
        if k is not None:
            return ('constant', k) if k < 16 else None
        if e.kind == 'var' and self.narrow(e, 4):
            v = e.var
            if v.volatile and v.ctype != 'nibble':
                return None
            cached = v if v.ctype == 'nibble' else v.slot
            if not v.volatile and self.a_holds is cached:
                return ('cached',)
            return ('status', v.slot, v.nib if v.ctype == 'nibble' else 3)
        if e.kind == 'index' and e.var.ctype == 'nibble':
            if fold(e.index) is not None:
                return ('memory', self.constant_address(e))
            if e.var.base & 15 == 0 and self.narrow(e.index, 4) and self.nibble_source(e.index) is not None:
                return ('indexed', e.var.base, e.index)
        return None

    def read_nibble(self, e):
        source = self.nibble_source(e)
        if source is None:
            return False
        held = self.a_holds
        if source[0] == 'constant':
            self.op('LDM', source[1])
        elif source[0] == 'cached':
            self.op('LD', 7)
        elif source[0] == 'status':
            self.op('FIM', 0, source[1])
            self.op('LD', 1)
            self.op('DCL')
            self.op('SRC', 0)
            self.op('RD'+str(source[2]))
        elif source[0] == 'indexed':
            self.read_nibble(source[2])
            self.op('XCH', 1)
            self.op('LDM', (source[1] & 255) >> 4)
            self.op('XCH', 0)
            self.op('LDM', (source[1] >> 8) & 7)
            self.op('DCL')
            self.op('SRC', 0)
            self.op('RDM')
        else:
            self.op('FIM', 0, source[1] & 255)
            self.op('LDM', (source[1] >> 8) & 7)
            self.op('DCL')
            self.op('SRC', 0)
            self.op('RDM')
        self.a_holds = held  # Only ACC, addressing and bank selection changed.
        return True

    def narrow_branch(self, op, left, right, label, when):
        """Jump if (left op right) is when, comparing in place the low bytes, or the
        low nibbles when both sides fit in 4 bits."""
        if fold(left) is not None and fold(right) is None:
            left, right, op = right, left, MIRROR[op]
        k = fold(right)
        if (not self.size and self.narrow(left, 4) and self.narrow(right, 4)
                and self.nibble_source(left) is not None and self.nibble_source(right) is not None):
            if k == 0 and op in ('==', '!=', '>', '<='):
                self.read_nibble(left)
                self.jcn(4 if (op in ('==', '<=')) == when else 0xC, label)
                return
            x, y = (left, right) if op in ('==', '!=', '>=', '<') else (right, left)
            self.read_nibble(y)
            self.op('XCH', 12)
            self.read_nibble(x)
            self.op('CLC')
            self.op('SUB', 12)
            if op in ('==', '!='):
                self.jcn(4 if (op == '==') == when else 0xC, label)
            else:
                self.jcn(2 if (op in ('>=', '<=')) == when else 0xA, label)
            return
        if k == 0:  # against zero: test the nibbles
            if op in ('>=', '<'):
                if (op == '>=') == when:
                    self.gen(left, False)
                    self.jump(label)
                else:
                    self.gen(left, False)
                return
            return self.narrow_zero(left, label, (op in ('==', '<=')) == when)
        if k is not None:
            self.gen(left)
            self.op('FIM', 10, k)
        else:
            self.operands(left, right)
        if self.narrow(left, 4) and self.narrow(right, 4):  # one nibble
            if op in ('==', '!='):
                self.op('CLC')
                self.op('LD', 7)
                self.op('SUB', 11)
                self.jcn(4 if (op == '==') == when else 0xC, label)
                return
            x, y = (7, 11) if op in ('>=', '<') else (11, 7)
            self.op('CLC')
            self.op('LD', x)
            self.op('SUB', y)
            self.jcn(2 if (op in ('>=', '<=')) == when else 0xA, label)
            return
        if self.size:  # a helper call is smaller than comparing the two nibbles in place
            if op in ('==', '!='):
                self.call('QEQ8')
                return self.jcn(0xC if (op == '==') == when else 4, label)
            self.call('QGE8' if op in ('>=', '<') else 'QLE8')
            return self.jcn(2 if (op in ('>=', '<=')) == when else 0xA, label)
        if op in ('==', '!='):
            if (op == '==') == when:  # jump if equal
                skip = self.label()
                self.op('CLC')
                self.op('LD', 7)
                self.op('SUB', 11)
                self.jcn(0xC, skip)
                self.op('CLC')
                self.op('LD', 6)
                self.op('SUB', 10)
                self.jcn(4, label)
                self.place(skip, True)
            else:
                for a, b in ((7, 11), (6, 10)):
                    self.op('CLC')
                    self.op('LD', a)
                    self.op('SUB', b)
                    self.jcn(0xC, label)
            return
        # The carry is 1 when X >= Y: A >= B for >= and <, B >= A for <= and >.
        x, y = ((7, 6), (11, 10)) if op in ('>=', '<') else ((11, 10), (7, 6))
        self.op('CLC')
        self.op('LD', x[0])
        self.op('SUB', y[0])
        self.op('CMC')
        self.op('LD', x[1])
        self.op('SUB', y[1])
        self.jcn(2 if (op in ('>=', '<=')) == when else 0xA, label)

    def narrow_zero(self, e, label, if_zero):
        """Jump if narrow e is zero (if_zero) or nonzero."""
        if not self.size and self.narrow(e, 4) and self.read_nibble(e):
            self.jcn(4 if if_zero else 0xC, label)
            return
        self.gen(e)
        if self.narrow(e, 4):
            self.op('LD', 7)
            self.jcn(4 if if_zero else 0xC, label)
            return
        if if_zero:
            skip = self.label()
            self.op('LD', 7)
            self.jcn(0xC, skip)
            self.op('LD', 6)
            self.jcn(4, label)
            self.place(skip, True)
        else:
            self.op('LD', 7)
            self.jcn(0xC, label)
            self.op('LD', 6)
            self.jcn(0xC, label)

    # array elements

    def address(self, e):
        """A = the address of array element e: a nibble, or a bit for _Bool."""
        v, k = e.var, fold(e.index)
        if k is not None:
            return self.load_a_const(self.constant_address(e))
        self.gen(e.index)
        base = v.base * 4 if v.ctype == 'bool' else v.base
        if v.ctype != 'bool':
            for _ in range(SIZES[v.ctype].bit_length() - 1):
                self.call('QSHL1')
        if base:
            self.load_b_const(base)
            self.call('QADD')

    def constant_address(self, e):
        v, k = e.var, s16(fold(e.index))
        if not 0 <= k < v.length:
            raise CompileError(f'line {e.line}: index {k} is outside {v.name}[{v.length}]')
        return v.base * 4 + k if v.ctype == 'bool' else v.base + SIZES[v.ctype] * k

    def store_element(self, target, value):
        if self.simple(value):
            self.address(target)
            self.load_b(value)
        elif fold(target.index) is not None:
            self.gen(value)
            self.call('QXAB')
            self.address(target)
        else:
            self.gen(value)
            t = self.push_temp()
            self.load_slot(t, 'QSTA')
            self.address(target)
            self.load_slot(t, 'QLDB')
            self.pop_temp()
        self.call(STORE[target.var.ctype])

    def assign(self, e):
        target, value = e.target, e.value
        if e.op != '=':
            if target.kind == 'index' and has_effects(target.index):
                raise CompileError(f'line {e.line}: the index of a compound assignment cannot have side effects')
            value = Node('binary', e.line, op=e.op[:-1], l=target, r=value)
        if target.kind == 'var':
            self.gen(value)
            self.store_var(target.var)
        else:
            self.store_element(target, value)

    def incdec(self, e, need):
        target, line = e.target, e.line
        if target.kind == 'var' and target.var.ctype == 'nibble':
            v = target.var
            self.op('FIM', 0, v.slot)
            self.op('LD', 1)
            self.op('DCL')
            self.op('SRC', 0)
            self.op('RD'+str(v.nib))
            if need and not e.prefix:
                self.op('XCH', 7)
                self.op('LD', 7)
            self.op('IAC' if e.op == '++' else 'DAC')
            self.op('WR'+str(v.nib))
            self.a_holds = None
            if need:
                if e.prefix:
                    self.op('XCH', 7)
                self.op('FIM', 4, 0)
                self.op('LDM', 0)
                self.op('XCH', 6)
                if e.prefix:
                    self.a_holds = v
            return
        if need and not e.prefix:  # the old value, through a temporary
            self.gen(target)
            t = self.push_temp()
            self.load_slot(t, 'QSTA')
            self.incdec(Node('incdec', line, op=e.op, prefix=True, target=target), False)
            self.load_slot(t)
            self.pop_temp()
            return
        if target.kind == 'var' and not getattr(target.var, 'boolean', False) and target.var.ctype != 'nibble':
            char = target.var.ctype == 'char'
            helper = {'++': 'QINCC' if char else 'QINCV', '--': 'QDECC' if char else 'QDECV'}[e.op]
            self.load_slot(target.var.slot, helper)
            return
        if target.kind == 'index' and has_effects(target.index):
            raise CompileError(f'line {line}: the index of ++ or -- cannot have side effects')
        one = Node('num', line, value=1, ctype='int')
        self.assign(Node('assign', line, op='+=' if e.op == '++' else '-=', target=target, value=one))

    # calls

    def gen_call(self, e):
        if e.name in BUILTINS:
            return self.builtin(e)
        f, caller = self.functions[e.name], self.function
        recursive = caller.name in self.reach[f.name]
        runs = []
        if recursive:  # save the caller's variables that are read after the call, in runs of up to 16
            live = self.live[id(e)]
            frame = [(caller.ret_slot, True)] + [(slot, any(v in live for v in vs))
                                                 for slot, vs in caller.slot_vars]
            frame += [(t, True) for t in caller.temps[:self.depth]]
            for slot, saved in frame:
                if saved and runs and runs[-1][-1] is previous and len(runs[-1]) < 16:
                    runs[-1].append(slot)
                elif saved:
                    runs.append([slot])
                previous = slot
            for run in runs:
                self.op('FIM', 0, run[0])
                self.op('LDM', (16 - len(run)) & 15)
                self.op('XCH', 13)
                self.call('QSAVE')
        # An argument for a parameter that f never refers to is evaluated only for its side effects.
        if self.direct_arguments(e, f, caller):
            for arg, param in zip(e.args, f.params):
                if param not in f.referenced:
                    self.gen(arg, False)
                elif not (arg.kind == 'var' and arg.var is param):  # passed unchanged
                    self.gen(arg)
                    self.store_var(param)
        else:
            temps = []
            for arg, param in zip(e.args, f.params):
                if param not in f.referenced:
                    self.gen(arg, False)
                    continue
                self.gen(arg)
                temps.append((self.push_temp(), param))
                self.load_slot(temps[-1][0], 'QSTA')
            for t, param in temps:
                self.load_slot(t)
                self.store_var(param)
            for _ in temps:
                self.pop_temp()
        if f.name in self.inlined:
            end = self.label()
            saved = self.function, self.depth, self.loops, self.inline_exit
            self.function, self.depth, self.loops, self.inline_exit = f, 0, [], (f, end)
            try:
                self.statement(f.body)
                self.place(end, True)
            finally:
                self.function, self.depth, self.loops, self.inline_exit = saved
            self.a_holds = None
            return
        site = self.label()
        self.return_sites.append(site)
        self.op('FIM', 6, 4 + 2 * (len(self.return_sites) - 1))
        self.op('FIM', 0, f.ret_slot)
        self.call('QSTAC')
        self.jump(f.label)
        self.place(site)
        for run in reversed(runs):
            self.op('FIM', 0, run[0])
            self.op('FIM', 2, -4 * len(run) & 255)
            self.op('LDM', (16 - len(run)) & 15)
            self.op('XCH', 13)
            self.call('QRSTR')

    def direct_arguments(self, e, f, caller):
        """Whether each argument can be stored straight into its parameter."""
        if any(n.kind == 'call' and n.name not in BUILTINS for a in e.args for n in walk(a)):
            return False
        if f is not caller:
            return True  # the arguments cannot refer to f's parameters
        written = set()
        for arg, param in zip(e.args, f.params):
            if any(n.kind == 'var' and n.var in written for n in walk(arg)):
                return False
            if param in f.referenced and not (arg.kind == 'var' and arg.var is param):
                written.add(param)
        return True

    def builtin(self, e):
        name, args = e.name, e.args
        if name == 'putchar':
            if len(args) != 1:
                raise CompileError(f'line {e.line}: putchar takes one argument')
            self.gen(args[0])
            self.call('QPUTC')
        elif name == 'getchar':
            if args:
                raise CompileError(f'line {e.line}: getchar takes no arguments')
            self.call('QGETC')
        elif name == 'puts':
            if len(args) != 1 or args[0].kind != 'str':
                raise CompileError(f'line {e.line}: puts takes a string constant')
            self.print_text(args[0].data + b'\n', e.line)
        elif name in HARDWARE:
            if len(args) != HARDWARE[name]:
                raise CompileError(f'line {e.line}: {name} takes {HARDWARE[name]} argument'
                                   + ('s' if HARDWARE[name] != 1 else ''))
            self.hardware(e)
        else:
            self.printf(e)

    def hardware(self, e):
        """The built-ins for the I/O ports, the TEST pin and KBP."""
        name, args = e.name, e.args
        if name in INSTRUCTIONS_4040:
            if self.cpu != '4040':
                raise CompileError(f'line {e.line}: {name} needs the 4040 (--4040)')
            return self.op(INSTRUCTIONS_4040[name])
        if name == '__test':  # 1 when the TEST pin is high
            self.call('QTEST')
            self.call('QBOOL')
            return
        if name == '__kbp':
            self.gen(args[0])
            self.op('LD', 7)
            self.op('KBP')
            return self.nibble_result()
        if name in ('__rom_out', '__rom_in'):  # ROM chip 0 to 15's port: SRC's high nibble
            value = args[1] if name == '__rom_out' else None
            chip = fold(args[0])
            if chip is not None and chip > 15:
                raise CompileError(f'line {e.line}: ROM chips are 0 to 15')
            t = None
            if value is not None and chip is None:
                self.gen(value)
                t = self.push_temp()
                self.load_slot(t, 'QSTA')
            if chip is None:
                self.gen(args[0])
                self.op('LD', 7)
                self.op('XCH', 14)
                self.op('LDM', 0)
                self.op('XCH', 15)
            if value is not None:
                if t is None:
                    self.gen(value)
                else:
                    self.load_slot(t)
                    self.pop_temp()
            if chip is not None:
                self.op('FIM', 14, chip << 4)
            self.op('SRC', 14)
            if value is not None:
                self.op('LD', 7)
                self.op('WRR')
                return
            self.op('RDR')
            return self.nibble_result()
        # __ram_out(bank, chip, value): the output port of 4002 chip 0 to 3 in bank 0 to 7
        bank, chip, value = fold(args[0]), fold(args[1]), args[2]
        if bank is not None and bank > 7 or chip is not None and chip > 3:
            raise CompileError(f'line {e.line}: RAM banks are 0 to 7 and chips 0 to 3')
        if bank is not None and chip is not None:
            self.gen(value)
            self.op('LDM', bank)
            self.op('DCL')
            self.op('FIM', 14, chip << 6)
        else:
            self.gen(value)
            tv = self.push_temp()
            self.load_slot(tv, 'QSTA')
            self.gen(args[0])
            tb = self.push_temp()
            self.load_slot(tb, 'QSTA')
            self.gen(args[1])  # SRC's high nibble is chip * 4
            self.op('CLC')
            self.op('LD', 7)
            self.op('RAL')
            self.op('RAL')
            self.op('XCH', 14)
            self.op('LDM', 0)
            self.op('XCH', 15)
            self.load_slot(tb)
            self.op('LD', 7)
            self.op('XCH', 13)
            self.load_slot(tv)  # QLDA selects its own bank, so DCL comes after
            self.pop_temp()
            self.pop_temp()
            self.op('LD', 13)
            self.op('DCL')
        self.op('SRC', 14)
        self.op('LD', 7)
        self.op('WMP')

    def nibble_result(self):
        """A = the accumulator, a nibble."""
        self.op('XCH', 7)
        for register in (6, 5, 4):
            self.op('LDM', 0)
            self.op('XCH', register)

    def printf(self, e):
        if not e.args or e.args[0].kind != 'str':
            raise CompileError(f'line {e.line}: the format of printf must be a string constant')
        fmt, args, text, i = e.args[0].data, list(e.args[1:]), b'', 0
        while i < len(fmt):
            c = fmt[i:i + 1]
            i += 1
            if c != b'%':
                text += c
                continue
            conversion = fmt[i:i + 1]
            i += 1
            if conversion == b'%':
                text += b'%'
                continue
            if conversion not in (b'd', b'i', b'u', b'x', b'c', b's'):
                raise CompileError(f'line {e.line}: printf supports %d %u %x %c %s and %%, without widths')
            if not args:
                raise CompileError(f'line {e.line}: printf has too few arguments')
            arg = args.pop(0)
            if conversion == b's':
                if arg.kind != 'str':
                    raise CompileError(f'line {e.line}: %s needs a string constant')
                text += arg.data
                continue
            self.print_text(text, e.line)
            text = b''
            self.gen(arg)
            self.call({b'd': 'QPRTD', b'i': 'QPRTD', b'u': 'QPRTU', b'x': 'QPRTX', b'c': 'QPUTC'}[conversion])
        if args:
            raise CompileError(f'line {e.line}: printf has too many arguments')
        self.print_text(text, e.line)

    def print_text(self, data, line):
        if not data:
            return
        if b'\0' in data:
            raise CompileError(f'line {line}: strings cannot contain a zero byte')
        if len(data) == 1:
            self.load_a_const(data[0])
            self.call('QPUTC')
            return
        if data not in self.strings:
            size = len(data) + 1
            if size > 256 - STRING_LOOP_SIZE:
                raise CompileError(f'line {line}: the string is longer than {255 - STRING_LOOP_SIZE} characters')
            for number, block in enumerate(self.string_blocks):
                if block[0] >= size:
                    break
            else:
                self.string_blocks.append([256 - STRING_LOOP_SIZE, []])
                number = len(self.string_blocks) - 1
            block = self.string_blocks[number]
            block[0] -= size
            label = f'S{len(self.strings) + 1:04d}'
            block[1].append((label, data))
            self.strings[data] = (label, number)
        label, number = self.strings[data]
        self.op('FIM', 0, f'{label} AND 0FFH')
        self.op('JMS', f'QS{number + 1}')

    def interrupt_entry(self):
        save, restore = [], []
        for slot, registers in zip(self.interrupt_slots, ((8, 9, 10, 11), (12, 13, 14, 15), (5, 6, 7))):
            select = [f'        FIM 0,{number(slot.address())}', '        LD 1', '        DCL', '        SRC 0']
            save += select
            restore += select
            for k, register in enumerate(registers):
                save += [f'        LD {register}', f'        WR{k}']
                restore += [f'        RD{k}', f'        XCH {register}']
        return INTERRUPT_ENTRY.format(save='\n'.join(save), restore='\n'.join(restore), number=number(4),
                                      ret=number(self.handler.ret_slot.address()), handler=self.handler.label)

    # statements

    def epilogue(self):
        if self.inline_exit is not None and self.inline_exit[0] is self.function:
            self.jump(self.inline_exit[1])
            return
        f = self.function
        if f.name == 'main':
            self.used.add('QEXIT')
            if self.handler:
                self.op('DIN')  # no more interrupts, so the jump to itself ends the program
            self.op('JUN', 'QEXIT')
        else:
            self.op('FIM', 0, f.ret_slot)
            self.op('JUN', 'QRETF')

    def statement(self, s):
        kind = s.kind
        if kind not in ('block', 'empty'):
            self.source_comment(s.line)
        if kind == 'block':
            for child in s.body:
                self.statement(child)
        elif kind == 'decl':
            for var, init in s.items:
                if init is not None:
                    self.gen(init)
                    self.store_var(var)
        elif kind == 'expr':
            self.gen(s.e, False)
        elif kind == 'if':
            end = self.label()
            if s.other is None:
                self.branch(s.c, end, False)
                self.statement(s.then)
            else:
                other = self.label()
                self.branch(s.c, other, False)
                self.statement(s.then)
                self.jump(end)
                self.place(other, True)
                self.statement(s.other)
            self.place(end, True)
        elif kind in ('while', 'for'):
            if kind == 'for' and s.init is not None:
                self.statement(s.init)
            top, test, step, end = self.label(), self.label(), self.label(), self.label()
            forever = s.c is None or fold(s.c) not in (None, 0)
            if not forever:
                self.jump(test)
            self.place(top)
            self.loops.append((end, step))
            self.statement(s.body)
            self.loops.pop()
            self.place(step, True)
            if kind == 'for' and s.step is not None:
                self.gen(s.step, False)
            self.place(test, True)
            if forever:
                self.jump(top)
            else:
                self.branch(s.c, top, True)
            self.place(end, True)
        elif kind == 'do':
            top, test, end = self.label(), self.label(), self.label()
            self.place(top)
            self.loops.append((end, test))
            self.statement(s.body)
            self.loops.pop()
            self.place(test, True)
            self.branch(s.c, top, True)
            self.place(end, True)
        elif kind == 'switch':
            end = self.label()
            for case in s.cases + ([s.default] if s.default is not None else []):
                case.label = self.label()
            nibble = self.narrow(s.c, 4) and all(0 <= case.value < 16 for case in s.cases)
            self.gen(s.c)  # Once only; comparisons preserve R4-R7.
            # Sixteen entries cover every nibble, including holes/default.
            # Keep small switches and the compact profile as comparisons.
            table = nibble and not self.size and len(s.cases) >= 5
            if table:
                default = s.default.label if s.default is not None else end
                targets = dict((case.value, case.label) for case in s.cases)
                entries = tuple(targets.get(n, default) for n in range(16))
                self.code.append(('table', self.label(), entries))
                for target in set(entries):
                    self.incoming.setdefault(target, []).append(None)
                self.a_holds = None
                self.falls = False
            for case in ([] if table else s.cases):
                if nibble:
                    self.op('LDM', case.value)
                    self.op('XCH', 11)
                    self.op('CLC')
                    self.op('LD', 7)
                    self.op('SUB', 11)
                    self.jcn(4, case.label)
                else:
                    self.load_b_const(case.value)
                    self.call('QEQ')
                    self.jcn(0xC, case.label)
            if not table:
                self.jump(s.default.label if s.default is not None else end)
            self.loops.append((end, None))
            self.statement(s.body)
            self.loops.pop()
            self.place(end, True)
        elif kind == 'case':
            self.place(s.label)  # Dispatch and fallthrough meet here.
            self.statement(s.body)
        elif kind == 'label':
            self.place(self.function.jump_labels[s.name])  # May have backward incoming jumps.
            self.statement(s.body)
        elif kind == 'goto':
            self.jump(self.function.jump_labels[s.name])
        elif kind in ('break', 'continue'):
            contexts = self.loops if kind == 'break' else [c for c in self.loops if c[1] is not None]
            if not contexts:
                raise CompileError(f'line {s.line}: {kind} is not in a loop' +
                                   (' or switch' if kind == 'break' else ''))
            self.jump(contexts[-1][0 if kind == 'break' else 1])
        elif kind == 'return':
            if s.e is not None:
                if self.function.ctype == 'void':
                    raise CompileError(f'line {s.line}: {self.function.name} is void')
                self.gen(s.e)
                if self.function.ctype == 'char':
                    self.truncate()
                elif self.function.ctype == 'nibble':
                    self.mask(15)
            self.epilogue()

    # layout and output

    def share_accesses(self, items):
        """Outline repeated FIM 0 / JMS helper pairs with a tail jump.

        The stub's JUN does not push another hardware return address. Each
        selected pair saves two bytes per use at a cost of two cycles.
        """
        def key(i):
            first = items[i]
            if i+1 >= len(items) or first[:2] != ('op', 'FIM') or first[2][0] != 0:
                return None
            second = items[i+1]
            if second[:2] != ('op', 'JMS') or second[2][0] not in RUNTIME:
                return None
            operand = first[2][1]
            value = operand.address() if isinstance(operand, Slot) else operand
            return (value, second[2][0]) if isinstance(value, int) else None
        counts = {}
        for i in range(len(items)):
            pair = key(i)
            if pair is not None: counts[pair] = counts.get(pair, 0)+1
        shared = {}
        for pair, count in counts.items():
            if count >= 3:
                label = f'W{len(shared)+1:04d}'
                shared[pair] = label
                value, helper = pair
                self.shared_accesses.append(f'{label}: FIM 0,{number(value)}\n        JUN {helper}')
                self.stub_levels[label] = HELPER_LEVELS[helper]
        output = [];i = 0
        while i < len(items):
            pair = key(i)
            if pair in shared:
                output.append(('op', 'JMS', (shared[pair],)))
                i += 2
            else:
                output.append(items[i]);i += 1
        return output

    def outline(self, items):
        """Outline repeated straight-line code that ends in a helper call.

        Each stub ends by jumping to the helper, which returns for it. Greedily
        takes the sequence that saves the most bytes, while the deepest call in
        the stub stays within the return stack. Each use saves its length less
        two bytes, at the cost of a JMS and a BBL.
        """
        texts = {}

        def text(item):
            if item not in texts:
                operands = ','.join(o if isinstance(o, str) else number(o.address() if isinstance(o, Slot) else o)
                                    for o in item[2])
                texts[item] = f'{item[1]} {operands}'.rstrip()
            return texts[item]

        def levels(item):
            return (HELPER_LEVELS.get(item[2][0]) or self.stub_levels.get(item[2][0])) if item[1] == 'JMS' else None

        while True:
            ops = [i for i, item in enumerate(items) if item[0] != 'comment']
            runs, best = {}, None
            for k, start in enumerate(ops):
                deepest, key, size = 0, (), 0
                for end in ops[k:k + 12]:
                    item = items[end]
                    if item[0] != 'op' or item[1] not in STRAIGHT_LINE:
                        break
                    called = levels(item)
                    if item[1] == 'JMS' and called is None:
                        break
                    key += (text(item),)
                    size += 2 if item[1] in TWO_BYTES else 1
                    if called is not None and end != start and max(deepest, called) <= STACK_LEVELS:
                        runs.setdefault(key, (size, []))[1].append((start, end, max(deepest, called)))
                    if called is not None:
                        deepest = max(deepest, 1 + called)
                        if deepest > STACK_LEVELS:
                            break
            for key, (size, places) in runs.items():
                if len(places) * (size - 2) - size < (best[0] if best else 1):
                    continue  # it can't win, even with every use
                chosen, after = [], -1
                for start, end, depth in places:
                    if start > after:
                        chosen.append((start, end))
                        after = end
                saving = len(chosen) * (size - 2) - size
                if saving > 0 and (best is None or (saving, size) > best[:2]):
                    best = (saving, size, key, chosen, places[0][2])
            if best is None:
                return items
            _, _, key, chosen, depth = best
            label = f'QV{len(self.stub_levels) + 1:03d}'
            self.stub_levels[label] = depth
            body = [f'{label}:  {key[0]}'] + [f'        {line}' for line in key[1:]]
            body[-1] = body[-1].replace('JMS ', 'JUN ', 1)
            self.shared_accesses.append('\n'.join(body))
            starts = {start: end for start, end in chosen}
            output, i = [], 0
            while i < len(items):
                if i in starts:
                    output.append(('op', 'JMS', (label,)))
                    i = starts[i] + 1
                else:
                    output.append(items[i])
                    i += 1
            items = output

    @staticmethod
    def jump_targets(items):
        """Each label whose code is just a JUN, and the label that jump chain ends at."""
        jumps = {}
        for i, item in enumerate(items):
            if item[0] == 'label':
                j = i + 1
                while j < len(items) and items[j][0] in ('label', 'comment'):
                    j += 1
                if j < len(items) and items[j][:2] == ('op', 'JUN'):
                    jumps[item[1]] = items[j][2][0]
        final = {}
        for label in jumps:
            target, seen = label, set()
            while target in jumps and target not in seen:  # a jump to itself ends a chain too
                seen.add(target)
                target = jumps[target]
            if target != label:
                final[label] = target
        return final

    @classmethod
    def shrink_code(cls, items, keep=()):
        """Remove unreachable instructions and transfers to immediate fallthrough,
        and send each JUN straight to the end of any chain of jumps.

        Labels remain entry points: software-call continuations (keep) are
        reached indirectly through the runtime return table, not a visible C
        jump. Other compiler labels nothing refers to any more are dropped, so
        a jump that only they reached becomes unreachable.
        """
        while True:
            final = cls.jump_targets(items)
            items = [('op', 'JUN', (final.get(item[2][0], item[2][0]),)) if item[:2] == ('op', 'JUN') else item
                     for item in items]
            referenced = (set(keep)
                          | {target for item in items if item[0] == 'table' for target in item[2]}
                          | {item[2] for item in items if item[0] == 'jcn'}
                          | {o for item in items if item[0] == 'op'
                             for o in item[2] if isinstance(o, str)})
            items = [item for item in items
                     if not (item[0] == 'label' and re.fullmatch(r'L\d{4}', item[1]) and item[1] not in referenced)]
            result = []
            reachable = True
            for item in items:
                if item[0] == 'label':
                    reachable = True
                if item[0] != 'comment' and not reachable:
                    continue
                result.append(item)
                if item[0] == 'op' and item[1] == 'JUN':
                    reachable = False
            output = []
            for i, item in enumerate(result):
                target = (item[2][0] if item[:2] == ('op', 'JUN') else
                          item[2] if item[0] == 'jcn' else None)
                if target is not None:
                    j = i + 1
                    while j < len(result) and result[j][0] in ('label', 'comment'):
                        if result[j] == ('label', target):
                            break
                        j += 1
                    if j < len(result) and result[j] == ('label', target):
                        continue
                output.append(item)
            if output == items:
                return output
            items = output

    def layout(self, items):
        """Place compiled code from 0, choosing a short or long form for each JCN.

        A JCN to a label that only jumps on goes to the jump's target instead,
        when that keeps it short; self.jcn_targets records each JCN's target.
        """
        final = self.jump_targets(items)
        long = set()
        while True:
            address, labels, places, pads = 0, {}, {}, {}
            for i, item in enumerate(items):
                if item[0] == 'label':
                    labels[item[1]] = address
                elif item[0] == 'op':
                    address += 2 if item[1] in TWO_BYTES else 1
                elif item[0] == 'table':
                    # Sixteen dispatcher bytes plus sixteen two-byte JUN entries.
                    pads[i] = (((address + 2 + 255) & ~255) - address
                               if (address & 255) + 48 > 256 else 0)
                    address += pads[i] + 48
                elif item[0] == 'jcn':
                    if i in long:  # JCN NOT,$+4 / JUN: both bytes after the JCN must share its page
                        pads[i] = 0x100 - ((address + 2) & 0xFF) if (address + 2) & 0xFF >= 0xFE else 0
                        address += pads[i]
                        places[i] = address
                        address += 4
                    else:
                        places[i] = address
                        address += 2
            grew = False
            self.jcn_targets = {}
            for i, address_of in places.items():
                label = items[i][2]
                page = (address_of + 2) >> 8
                choices = [final[label], label] if label in final else [label]
                near = [c for c in choices if labels[c] >> 8 == page]
                self.jcn_targets[i] = near[0] if near else choices[0]
                if i not in long and not near:
                    long.add(i)
                    grew = True
            if not grew:
                return address, long, pads

    def output(self):
        end, long, pads = self.layout(self.code)
        target = ' FOR THE 4040' if self.cpu == '4040' else ''
        lines = [f'; {self.name.upper()}: COMPILED FROM C BY CC4.PY{target}', '        ORG 0']
        for i, item in enumerate(self.code):
            if item[0] == 'label':
                lines.append(f'{item[1]}:')
            elif item[0] == 'comment':
                lines.append(sanitize('; ' + item[1]))
            elif item[0] == 'table':
                label = item[1]
                if pads[i]:
                    lines.append(f'        JUN {label}')
                    lines += ['        NOP'] * (pads[i] - 2)
                lines += [f'{label}:', '        LD 7', '        CLC', '        RAL',
                          '        XCH 1', '        TCC', '        XCH 0',
                          f'        LDM (T{label[1:]} AND 0FH)', '        ADD 1',
                          '        XCH 1', '        TCC', '        ADD 0', '        XCH 0',
                          f'        LDM ((T{label[1:]} AND 0FFH)/16)',
                          '        ADD 0', '        XCH 0', '        JIN 0', f'T{label[1:]}:']
                lines += [f'        JUN {target}' for target in item[2]]
            elif item[0] == 'op':
                operands = ','.join(o if isinstance(o, str) else number(o.address() if isinstance(o, Slot) else o)
                                    for o in item[2])
                lines.append(f'        {item[1]} {operands}'.rstrip())
            else:
                condition, target = item[1], self.jcn_targets[i]
                if i in long:
                    lines += ['        NOP'] * pads[i]
                    lines.append(f'        JCN {number(condition ^ 8)},$+4')
                    lines.append(f'        JUN {target}')
                else:
                    lines.append(f'        JCN {number(condition)},{target}')
        self.code_size = end
        lines += self.runtime_blocks(end)
        lines.append('        END')
        return '\n'.join(fixed(line) for line in lines) + '\n'

    def runtime_blocks(self, start):
        needed, work = set(), list(self.used)
        while work:
            entry = work.pop()
            if entry not in needed:
                needed.add(entry)
                work += REQUIRES.get(entry, [])
                work += [e for e in RUNTIME[entry]['entries']] if entry in RUNTIME else []
                text = RUNTIME[entry]['text'] if entry in RUNTIME else ''
                work += [m for m in re.findall(r'\b(?:JMS|JUN) (Q\w+)', text) if m in RUNTIME]
        blocks, seen = [], set()
        for entry in sorted(needed):
            block = RUNTIME.get(entry)
            if block and id(block) not in seen:
                seen.add(id(block))
                blocks.append((block['text'], block['align']))
        if self.handler:
            blocks.append((self.interrupt_entry(), False))
        if self.return_sites:
            if len(self.return_sites) > (256 - DISPATCH_FIXED) // 2:
                raise CompileError(f'too many calls ({len(self.return_sites)}); the return table holds '
                                   f'{(256 - DISPATCH_FIXED) // 2}')
            table = '\n'.join(f'        JUN {site}' for site in self.return_sites)
            blocks.append((DISPATCH.format(table=table), True))
        for n, (_, strings) in enumerate(self.string_blocks, 1):
            text = STRING_LOOP.format(n=n)
            for label, data in strings:
                text += f'\n{label}:'
                for i in range(0, len(data) + 1, 12):
                    chunk = (data + b'\0')[i:i + 12]
                    text += '\n        DB ' + ','.join(number(b) for b in chunk)
            blocks.append((text, False))
        blocks += [(text, False) for text in self.shared_accesses]
        placed, lines = [], []
        blocks.sort(key=lambda b: (not b[1], -block_size(b[0])))
        for text, align in blocks:
            size = block_size(text)
            address = start
            while True:
                if align:
                    address = (address + 255) & ~255
                elif address >> 8 != (address + size - 1) >> 8:
                    address = (address + 255) & ~255
                clash = [b for b in placed if b[0] < address + size and address < b[1]]
                if not clash:
                    break
                address = max(b[1] for b in clash)
            placed.append((address, address + size, text))
        self.rom_end = max([start] + [b[1] for b in placed])
        if self.rom_end > 0x1000:
            raise CompileError(f'the program needs {self.rom_end} bytes of ROM; the 4004 has 4096')
        for address, _, text in sorted(placed):
            lines.append(f'        ORG {number(address)}')
            lines += text.splitlines()
        return lines


def sanitize(text):
    text = text.upper().replace('\t', ' ')
    text = text.translate(str.maketrans('[]{}', '()()'))
    return ''.join(c if ' ' <= c <= 'Z' else '?' for c in text)[:72].rstrip()


def fixed(line):
    if len(asm4.code_field(line).rstrip()) > 72:
        raise CompileError(f'internal error: a line is too long: {line}')
    return line


INTERRUPT_ENTRY = '''; THE 4040'S INTERRUPT: REGISTER BANK 1 KEEPS THE PROGRAM'S R0-R7; SAVE ITS
; ACCUMULATOR, CARRY, RAM BANK AND R8-R15, CALL THE HANDLER, AND RESTORE THEM.
; BBS RESTORES THE SRC ADDRESS AND REGISTER BANK.
QINT:   SB1
        XCH 7
        TCC
        XCH 6
        LCR
        XCH 5
{save}
        FIM 6,{number}
        FIM 0,{ret}
        JMS QSTAC
        JUN {handler}
QINTR:
{restore}
        LD 5
        DCL
        LD 6
        RAR
        LD 7
        BBS'''


def compile_source(source, name='program', cpu='4004', size=False):
    """Return (assembly text, compiler) for C source."""
    compiler = Compiler(source, name, cpu, size=size)
    return compiler.compile(), compiler


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('source', type=Path)
    parser.add_argument('-o', '--output', type=Path, help='HEX path (default: source.hex); .asm and .map go beside it')
    parser.add_argument('-S', dest='assembly_only', action='store_true', help='write only the MAC4 source')
    parser.add_argument('--4040', dest='cpu', action='store_const', const='4040', default='4004',
                        help='compile for the 4040: interrupts, __ei, __di and __halt')
    parser.add_argument('--size', action='store_true', help='compare bytes through helpers and outline repeated code, reducing ROM at a small cycle cost')
    parser.add_argument('--stats', action='store_true', help='report ROM and RAM use')
    args = parser.parse_args()
    try:
        text, compiler = compile_source(args.source.read_text(encoding='utf-8'), args.source.stem, args.cpu, size=args.size)
        destination = args.output or args.source.with_suffix('.hex')
        destination.with_suffix('.asm').write_text(text, encoding='ascii', newline='\n')
        if not args.assembly_only:
            memory, symbols, _ = asm4.Assembler(args.cpu).assemble(text)
            destination.write_text(asm4.hex_file(memory), encoding='ascii', newline='\n')
            destination.with_suffix('.map').write_text(asm4.map_file(symbols), encoding='ascii', newline='\n')
        if args.stats:
            print(f'{args.source}: {compiler.code_size} bytes of code, {compiler.rom_end} of 4096 bytes of ROM; '
                  f'{compiler.slots_used} of 128 status registers; {compiler.memory_top} of 2048 RAM characters'
                  + (f'; save stack from {compiler.stack_base}' if compiler.recursive else ''))
    except (OSError, UnicodeError, CompileError) as error:
        print(f'cc4: {args.source}: {error}', file=sys.stderr)
        return 1
    except asm4.AssemblyError as error:
        print(f'cc4: {args.source}: internal error, the output does not assemble: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
