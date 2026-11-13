#!/usr/bin/env python3
"""Check cc4.py: compile C programs, run them in ntv4004, and compare the output.

Seeded random programs exercise every operator and assignment on int,
unsigned, char, __nibble and array operands against a Python model of 16-bit C;
fixed programs cover control flow, functions, recursion and the library;
and the benchmarks must print what their 8008 and 8080 versions print.
"""
from decimal import Decimal, localcontext
import os
from pathlib import Path
import random
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import asm4  # noqa: E402
import cc4  # noqa: E402

SIZE = '--size' in sys.argv
if SIZE:
    sys.argv.remove('--size')

NTV = ROOT / ('ntv4004.exe' if os.name == 'nt' else 'ntv4004')


def run_c(source, limit=50_000_000, keys=None, options=(), cpu='4004'):
    """Compile and run C source; return its output as text."""
    text, _ = cc4.compile_source(source, cpu=cpu, size=SIZE)
    memory, _, _ = asm4.Assembler(cpu).assemble(text)
    with tempfile.TemporaryDirectory(prefix='ntv4004 cc ') as directory:
        Path(directory, 'p.hex').write_text(asm4.hex_file(memory), encoding='ascii')
        command = [str(NTV), f'-n:{limit}', *(['-4'] if cpu == '4040' else []), *options]
        if keys is not None:
            Path(directory, 'keys.txt').write_bytes(keys)
            command.append('-l:keys.txt')
        result = subprocess.run(command + ['p.hex'], cwd=directory, capture_output=True, timeout=300)
    if result.returncode:
        raise AssertionError(f'ntv4004 exited with {result.returncode}: {result.stderr.decode()}')
    return result.stdout.decode().replace('\r\n', '\n')


# ---------------------------------------------------------------- a model of 16-bit C

TYPES = {'a': 'int', 'b': 'int', 'c': 'int', 'u': 'unsigned', 'v': 'unsigned', 'h': 'char', 'g': 'char',
         'n': 'nibble'}
ARRAYS = {'ia': ('int', 4), 'ca': ('char', 4), 'ba': ('bool', 16), 'na': ('nibble', 4)}
WIDTH = {'char': 0xFF, 'nibble': 0xF, 'int': 0xFFFF, 'unsigned': 0xFFFF}
DECLARED = {'nibble': '__nibble', 'bool': '_Bool'}


def s16(value):
    return cc4.s16(value)


def promoted(ctype):
    return 'unsigned' if ctype == 'unsigned' else 'int'


def evaluate(tree, env):
    """(16-bit value, 'int' or 'unsigned')."""
    kind = tree[0]
    if kind == 'const':
        return tree[1], tree[2]
    if kind == 'var':
        return env[tree[1]], promoted(TYPES[tree[1]])
    if kind == 'elem':
        index = evaluate(tree[2], env)[0]
        return env[tree[1]][index], promoted(ARRAYS[tree[1]][0])
    if kind == 'unary':
        value, ctype = evaluate(tree[2], env)
        if tree[1] == '!':
            return int(value == 0), 'int'
        return (-value if tree[1] == '-' else ~value) & 0xFFFF, ctype
    if kind == 'cond':
        test = evaluate(tree[1], env)[0]
        a, b = evaluate(tree[2], env), evaluate(tree[3], env)
        ctype = 'unsigned' if 'unsigned' in (a[1], b[1]) else 'int'
        return (a if test else b)[0], ctype
    if kind == 'cast':
        value = evaluate(tree[2], env)[0]
        return (value & WIDTH[tree[1]], 'int') if tree[1] in ('char', 'nibble') else (value, promoted(tree[1]))
    op = tree[1]
    (left, ltype), (right, rtype) = evaluate(tree[2], env), evaluate(tree[3], env)
    return binary(op, left, ltype, right, rtype)


def binary(op, left, ltype, right, rtype):
    unsigned = 'unsigned' in (ltype, rtype)
    if op == '<<':
        return left << right & 0xFFFF, ltype
    if op == '>>':
        return (left >> right if ltype == 'unsigned' else s16(left) >> right & 0xFFFF), ltype
    if op in ('/', '%'):
        return cc4.divide(left, right, unsigned, 0)[op == '%'], 'unsigned' if unsigned else 'int'
    a, b = (left, right) if unsigned else (s16(left), s16(right))
    if op in ('<', '>', '<=', '>=', '==', '!=', '&&', '||'):
        result = {'<': a < b, '>': a > b, '<=': a <= b, '>=': a >= b, '==': a == b, '!=': a != b,
                  '&&': bool(a) and bool(b), '||': bool(a) or bool(b)}[op]
        return int(result), 'int'
    value = {'+': a + b, '-': a - b, '*': a * b, '&': a & b, '|': a | b, '^': a ^ b}[op]
    return value & 0xFFFF, 'unsigned' if unsigned else 'int'


def text(tree):
    kind = tree[0]
    if kind == 'const':
        value = tree[1]
        if tree[2] == 'unsigned':
            return f'{value}u'
        return f'{s16(value)}' if s16(value) >= 0 else f'({s16(value)})'
    if kind == 'var':
        return tree[1]
    if kind == 'elem':
        return f'{tree[1]}[{text(tree[2])}]'
    if kind == 'unary':
        return f'{tree[1]}({text(tree[2])})'
    if kind == 'cond':
        return f'({text(tree[1])} ? {text(tree[2])} : {text(tree[3])})'
    if kind == 'cast':
        return f'(({DECLARED.get(tree[1], tree[1])})({text(tree[2])}))'
    return f'({text(tree[2])} {tree[1]} {text(tree[3])})'


OPERATORS = ['+', '-', '*', '/', '%', '&', '|', '^', '<<', '>>', '<', '>', '<=', '>=', '==', '!=', '&&', '||']


class Generator:
    def __init__(self, seed):
        self.rng = random.Random(seed)

    def constant(self):
        r = self.rng
        value = r.choice([0, 1, 2, 3, 4, 7, 9, 10, 15, 16, 100, 255, 256, 1000, 4095, 32767, 32768, 65535,
                          r.randrange(65536), r.randrange(32)])
        ctype = 'unsigned' if value > 32767 or r.random() < 0.2 else 'int'
        if ctype == 'int' and r.random() < 0.3 and value:
            value = -value & 0xFFFF
        return ('const', value, ctype)

    def leaf(self, env):
        r = self.rng.random()
        if r < 0.35:
            return self.constant()
        if r < 0.85:
            return ('var', self.rng.choice(list(TYPES)))
        name = self.rng.choice(list(ARRAYS))
        return ('elem', name, self.index(name, env, 0))

    def index(self, name, env, depth):
        length = ARRAYS[name][1]
        if self.rng.random() < 0.4:
            return ('const', self.rng.randrange(length), 'int')
        return ('binary', '&', self.expression(env, depth + 1), ('const', length - 1, 'int'))

    def expression(self, env, depth=0):
        r = self.rng.random()
        if depth >= 3 or r < 0.25:
            return self.leaf(env)
        if r < 0.35:
            return ('unary', self.rng.choice('-~!'), self.expression(env, depth + 1))
        if r < 0.40:
            return ('cond', self.expression(env, depth + 1), self.expression(env, depth + 1),
                    self.expression(env, depth + 1))
        if r < 0.45:
            return ('cast', self.rng.choice(['char', 'nibble', 'unsigned', 'int']), self.expression(env, depth + 1))
        op = self.rng.choice(OPERATORS)
        left, right = self.expression(env, depth + 1), self.expression(env, depth + 1)
        return self.fix(op, left, right, env)

    def fix(self, op, left, right, env=None):
        if op in ('<<', '>>'):
            right = ('binary', '&', right, ('const', 15, 'int'))
        if op in ('/', '%'):  # never divide by zero, whatever the operands hold when it runs
            right = ('cond', right, right, ('const', 1, 'int'))
        return ('binary', op, left, right)

    def statements(self, count, depth, loops):
        return [self.statement(depth, loops) for _ in range(count)]

    def statement(self, depth, loops):
        rng = self.rng
        r = rng.random()
        if depth < 2 and r < 0.12:
            return ('if', self.expression(None), self.statements(rng.randint(1, 3), depth + 1, loops),
                    self.statements(rng.randint(0, 2), depth + 1, loops))
        if depth < 2 and r < 0.2:
            var = f'i{depth}'
            return (rng.choice(['for', 'while', 'do']), var, rng.randint(0, 4),
                    self.statements(rng.randint(1, 3), depth + 1, loops + [var]))
        if loops and r < 0.27:
            return (rng.choice(['break', 'continue']), self.expression(None))
        r = rng.random()
        if r < 0.35:
            return ('print', self.expression(None))
        if r < 0.6:
            name, tree = rng.choice(list(TYPES)), self.expression(None)
            op = rng.choice(['=', '=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>='])
            if op != '=':
                tree = self.fix(op[:-1], ('var', name), tree)[3]
            return ('assign', name, op, tree)
        if r < 0.7:
            return ('incdec', rng.choice(list(TYPES)), rng.choice(['++', '--']), rng.random() < 0.5)
        if r < 0.9:
            name = rng.choice(list(ARRAYS))
            return ('store', name, self.index(name, None, 1), self.expression(None))
        return ('print', ('var', rng.choice(list(TYPES))))


class Break(Exception):
    pass


class Continue(Exception):
    pass


def static_type(tree):
    env = {name: 0 for name in TYPES}
    env.update({name: [0] * length for name, (_, length) in ARRAYS.items()})
    return evaluate(tree, env)[1]


def execute(statements, env, out):
    """Run the statements in the model, appending their output to out."""
    def store(name, value):
        env[name] = value & WIDTH[TYPES[name]]

    for s in statements:
        kind = s[0]
        if kind == 'print':
            value, ctype = evaluate(s[1], env)
            out.append(f'{value if ctype == "unsigned" else s16(value)}\n')
        elif kind == 'assign':
            _, name, op, tree = s
            store(name, evaluate(tree if op == '=' else ('binary', op[:-1], ('var', name), tree), env)[0])
        elif kind == 'incdec':
            store(s[1], env[s[1]] + (1 if s[2] == '++' else -1))
        elif kind == 'store':
            _, name, index, tree = s
            position, value = evaluate(index, env)[0], evaluate(tree, env)[0]
            ctype = ARRAYS[name][0]
            env[name][position] = int(value != 0) if ctype == 'bool' else value & WIDTH[ctype]
        elif kind == 'if':
            execute(s[2] if evaluate(s[1], env)[0] else s[3], env, out)
        elif kind in ('break', 'continue'):
            if evaluate(s[1], env)[0]:
                raise Break if kind == 'break' else Continue
        else:
            _, var, count, body = s
            env[var] = 0
            while kind == 'do' or env[var] < count:
                if kind != 'for':
                    env[var] += 1
                try:
                    execute(body, env, out)
                except Break:
                    break
                except Continue:
                    pass
                if kind == 'for':
                    env[var] += 1
                elif kind == 'do' and not env[var] < count:
                    break


def source_lines(statements, depth=1):
    pad, lines = '    ' * depth, []
    for s in statements:
        kind = s[0]
        if kind == 'print':
            lines.append(f'{pad}printf("%{"u" if static_type(s[1]) == "unsigned" else "d"}\\n", {text(s[1])});')
        elif kind == 'assign':
            lines.append(f'{pad}{s[1]} {s[2]} {text(s[3])};')
        elif kind == 'incdec':
            lines.append(f'{pad}{s[2]}{s[1]};' if s[3] else f'{pad}{s[1]}{s[2]};')
        elif kind == 'store':
            lines.append(f'{pad}{s[1]}[{text(s[2])}] = {text(s[3])};')
        elif kind == 'if':
            lines.append(f'{pad}if ({text(s[1])}) {{')
            lines += source_lines(s[2], depth + 1)
            if s[3]:
                lines.append(f'{pad}}} else {{')
                lines += source_lines(s[3], depth + 1)
            lines.append(f'{pad}}}')
        elif kind in ('break', 'continue'):
            lines.append(f'{pad}if ({text(s[1])}) {kind};')
        else:
            _, var, count, body = s
            if kind == 'for':
                lines.append(f'{pad}for ({var} = 0; {var} < {count}; {var}++) {{')
            elif kind == 'while':
                lines.append(f'{pad}{var} = 0;')
                lines.append(f'{pad}while ({var} < {count}) {{')
            else:
                lines.append(f'{pad}{var} = 0;')
                lines.append(f'{pad}do {{')
            if kind != 'for':
                lines.append(f'{pad}    {var}++;')
            lines += source_lines(body, depth + 1)
            lines.append(f'{pad}}} while ({var} < {count});' if kind == 'do' else f'{pad}}}')
    return lines


def random_program(seed):
    """C source and its expected output."""
    g = Generator(seed)
    rng = g.rng
    env = {name: rng.randrange(WIDTH[TYPES[name]] + 1) for name in TYPES}
    env.update({name: [0] * length for name, (_, length) in ARRAYS.items()})
    declarations = [f'{DECLARED.get(t, t)} {n} = {s16(env[n]) if t == "int" else env[n]};' for n, t in TYPES.items()]
    declarations += [f'{DECLARED.get(t, t)} {n}[{length}];' for n, (t, length) in ARRAYS.items()]
    declarations += ['int i0, i1;']
    statements = g.statements(12, 0, [])
    for name, (_, length) in ARRAYS.items():
        statements += [('print', ('elem', name, ('const', i, 'int'))) for i in range(length)]
    out = []
    execute(statements, env, out)
    source = ('\n'.join(declarations) + '\n\nint main()\n{\n' + '\n'.join(source_lines(statements))
              + '\n    return 0;\n}\n')
    return source, ''.join(out)


# ---------------------------------------------------------------- tests

def e_digits(count):
    with localcontext() as context:
        context.prec = count + 10
        return str(Decimal(1).exp()).replace('.', '')[:count]


def queens(n=8):
    """queens.c's output: the first solution's board, then the count."""
    found = []

    def place(row, columns):
        if row == n:
            found.append(columns)
            return
        for col in range(n):
            if all(col != c and abs(col - c) != row - r for r, c in enumerate(columns)):
                place(row + 1, columns + [col])
    place(0, [])
    board = ''.join(''.join('Q' if c == col else '.' for c in range(n)) + '\n' for col in found[0])
    return board + f'{len(found)} solutions\n'


def hanoi():
    """hanoi.c's output."""
    lines = []

    def move(discs, source, target, spare):
        if discs:
            move(discs - 1, source, spare, target)
            lines.append(f'disc {discs} from {source} to {target}\n')
            move(discs - 1, spare, target, source)
    move(3, 'A', 'C', 'B')
    return ''.join(lines) + '3 discs: 7 moves\n10 discs: 1023 moves\n'


PROGRAMS = {
    'loops': ('''
int main()
{
    int i, j, total;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (i == 3) continue;
        if (i == 8) break;
        j = 0;
        while (j < i) j++;
        do { total += j; } while (0);
    }
    printf("%d\\n", total);
    for (i = 0; ; i++) if (i * i > 50) break;
    printf("%d\\n", i);
    i = 5;
    while (i--) printf("%d", i);
    putchar('\\n');
    return 0;
}
''', '25\n8\n43210\n'),
    'functions': ('''
int add(int x, int y) { return x + y; }
char low(int x) { return x; }
unsigned twice(unsigned x) { return x * 2; }
void show(int x) { printf("[%d]", x); }
int g;
int bump() { g++; return g; }
int ignore(int unused, int used) { return used; }
int main()
{
    show(add(3, add(4, 5)));
    show(low(300));
    printf("%u", twice(40000));
    g = 10;
    show(bump() + bump() * 10);
    show(add(bump(), bump()));
    show(ignore(bump(), 7));
    show(g);
    putchar('\\n');
    return 0;
}
''', '[12][44]14464[131][27][7][15]\n'),
    'recursion': ('''
int fib(int n) { if (n < 2) return n; return fib(n - 1) + fib(n - 2); }
int fact(int n) { if (n <= 1) return 1; return n * fact(n - 1); }
int odd(int n);
int even(int n) { if (n == 0) return 1; return odd(n - 1); }
int odd(int n) { if (n == 0) return 0; return even(n - 1); }
int ack(int m, int n)
{
    if (m == 0) return n + 1;
    if (n == 0) return ack(m - 1, 1);
    return ack(m - 1, ack(m, n - 1));
}
int swap(int a, int b, int depth)
{
    if (depth == 0) return a * 10 + b;
    return swap(b, a, depth - 1);
}
int main()
{
    int i;
    for (i = 0; i < 12; i++) printf("%d ", fib(i));
    printf("\\n%d %d %d %d\\n", fact(7), even(9), odd(9), ack(2, 3));
    printf("%d %d\\n", swap(1, 2, 3), swap(1, 2, 4));
    return 0;
}
''', '0 1 1 2 3 5 8 13 21 34 55 89 \n5040 0 1 9\n21 12\n'),
    'library': ('''
int main()
{
    int c;
    printf("%d %u %x %c %s %% %d %d\\n", -12345, 65535u, 0xBEEF, 'Z', "str", 0, -32768);
    puts("puts adds a newline");
    while ((c = getchar()) != '.') putchar(c >= 'a' && c <= 'z' ? c - 32 : c);
    putchar('\\n');
    return 0;
}
''', '-12345 65535 beef Z str % 0 -32768\nputs adds a newline\nHELLO, WORLD\n'),
    'preprocessor': ('''
#define N 3
#define SQUARE(x) ((x) * (x))
#if N > 2 && defined(N)
#define BIG 1
#else
#define BIG 0
#endif
#ifdef UNDEFINED
#error not this
#elif N == 3
int three = N;
#endif
// a line comment
int main()
{
    printf("%d %d %d\\n", SQUARE(N + 1), BIG, three);
    return 0;
}
''', '16 1 3\n'),
    'narrow': ('''
char c = 200;
int n;
int w;
int k = 5;
int m;
char small(int x) { return x; }
int pick(int x, int y) { return x > y ? x : y; }
int wide(int x) { return x; }
int main()
{
    n = c;
    w = c;
    if (n > 150) putchar('a');
    if (n == 200) putchar('b');
    if (n != 199) putchar('c');
    if (n <= 200) putchar('d');
    if (n < 200) putchar('X');
    if (pick(c, 7) >= 200) putchar('e');
    if (pick(3, 9) == 9) putchar('f');
    w = 300;
    if (w > 250) putchar('g');
    if (w == 44) putchar('X');
    k++;
    if (k == 6) putchar('h');
    if (small(300) == 44) putchar('i');
    if (wide(c + 100) > 255) putchar('j');
    n = 0;
    if (n) putchar('X');
    if (!n) putchar('k');
    if (n >= 0) putchar('l');
    if (n < 0) putchar('X');
    if (c / 3 == 66 && c % 3 == 2) putchar('m');
    if ((c >> 2) == 50) putchar('n');
    m = -1;
    if (m < 0 && m != 255) putchar('o');
    printf(" %d %d\\n", n < c, c > 199);
    return 0;
}
''', 'abcdefghijklmno 1 1\n'),
    'nibble': ('''
__nibble a, b, c, d, e;
__nibble digits[10];
int depth(__nibble n, __nibble acc)
{
    __nibble x, y;
    x = n;
    y = acc;
    if (n == 0) return acc;
    depth(n - 1, acc + 1);
    return x * 10 + y;
}
__nibble half(int x) { return x / 2; }
int main()
{
    int i;
    a = 17;
    b = a + 14;
    c = 15;
    c++;
    d = 9;
    d -= 10;
    e = (__nibble)300;
    printf("%d %d %d %d %d\\n", a, b, c, d, e);
    for (i = 0; i < 10; i++) digits[i] = i * 3;
    for (i = 0; i < 10; i++) printf("%d ", digits[i]);
    printf("\\n%d %d %d %d\\n", digits[4] > digits[3], digits[5] == 15, a < b, b > 300);
    printf("%d %d %d\\n", depth(5, 2), depth(0, 7), half(40));
    return 0;
}
''', '1 15 0 15 12\n0 3 6 9 12 15 2 5 8 11 \n1 1 1 0\n52 7 4\n'),
    'arrays': ('''
int squares[20];
char letters[26];
_Bool marks[100];
int main()
{
    int i, sum;
    for (i = 0; i < 20; i++) squares[i] = i * i;
    for (i = 0; i < 26; i++) letters[i] = 'a' + i;
    for (i = 0; i < 100; i += 3) marks[i] = 1;
    sum = 0;
    for (i = 0; i < 100; i++) if (marks[i]) sum += squares[i % 20];
    printf("%d %c%c %d\\n", sum, letters[25], letters[0] - 32, marks[99] + marks[98]);
    squares[3] += 100;
    squares[4]++;
    --letters[1];
    printf("%d %d %c\\n", squares[3], squares[4], letters[1]);
    return 0;
}
''', '4241 zA 1\n109 17 a\n'),
}


@unittest.skipUnless(NTV.is_file(), 'build ntv4004 first (m.sh or m.bat)')
class Compiler(unittest.TestCase):
    def test_random_programs(self):
        ran = 0
        for seed in range(60):
            source, expected = random_program(seed)
            with self.subTest(seed=seed):
                try:
                    output = run_c(source)
                except cc4.CompileError as error:  # a few random programs exceed the 4K of ROM
                    self.assertIn('bytes of ROM', str(error))
                    continue
                self.assertEqual(output, expected, source)
                ran += 1
        self.assertGreaterEqual(ran, 55)

    def test_programs(self):
        for name, (source, expected) in PROGRAMS.items():
            with self.subTest(name):
                keys = b'Hello, world.' if name == 'library' else None
                self.assertEqual(run_c(source, keys=keys), expected)

    def test_examples(self):
        def example(name):
            return (ROOT / 'examples' / 'c' / f'{name}.c').read_text()
        self.assertEqual(run_c(example('hello')), 'Hello from C on the Intel 4004!\n')
        self.assertEqual(run_c(example('sieve'), 200_000_000), '1899 primes.\n')
        self.assertEqual(run_c(example('ttt'), 200_000_000), 'move count:      6493\niteration count: 1\n')
        self.assertEqual(run_c(example('queens')), queens())
        self.assertEqual(run_c(example('hanoi')), hanoi())
        output = run_c(example('e'), 200_000_000)
        digits, done = output.split('\n', 1)
        self.assertEqual(digits, e_digits(len(digits)))
        self.assertEqual((len(digits), done), (192, 'done\n'))

    def test_maze(self):
        source = (ROOT/'examples/c/maze.c').read_text()
        if not SIZE:
            assembly, compiler = cc4.compile_source(source, 'maze')
            memory, symbols, _ = asm4.Assembler().assemble(assembly)
            for suffix, content in (('asm',assembly), ('hex',asm4.hex_file(memory)),
                                    ('map',asm4.map_file(symbols))):
                self.assertEqual(content, (ROOT/f'examples/c/maze.{suffix}').read_text())
            self.assertLessEqual(compiler.rom_end, 4096)
            self.assertLessEqual(compiler.memory_top, 2048)
        mazes = set()
        for seed in (0, 37, 255):
            with self.subTest(seed=seed):
                output = run_c(source.replace('#define SEED 37', f'#define SEED {seed}'))
                lines = output.splitlines()
                self.assertEqual((lines[0],lines[12]), ('MAZE','SOLUTION'))
                self.assertEqual(len(lines), 24)
                maze, solution = lines[1:12], lines[13:24]
                mazes.add(tuple(maze))
                for row in maze+solution:
                    self.assertEqual(len(row), 11)
                self.assertTrue(all(ch in '# ' for row in maze for ch in row))
                self.assertEqual([row.replace('.', ' ') for row in solution], maze)
                # Exactly two boundary openings, above cell 0 and below cell 24.
                self.assertEqual(maze[0], '# #########')
                self.assertEqual(maze[-1], '######### #')
                self.assertTrue(all(row[0] == row[-1] == '#' for row in maze))
                graph = {i:[] for i in range(25)}
                edges = 0
                for cell in range(25):
                    y, x = 2*(cell//5)+1, 2*(cell%5)+1
                    self.assertEqual(maze[y][x], ' ')
                    for dy,dx,other in ((0,1,cell+1),(1,0,cell+5)):
                        if dy and cell == 24: continue  # external exit, not a tree edge
                        if maze[y+dy][x+dx] == ' ':
                            self.assertLess(other, 25)
                            if dx: self.assertNotEqual(cell%5, 4)
                            graph[cell].append(other)
                            graph[other].append(cell)
                            edges += 1
                # A connected graph with 25 vertices and 24 edges is a tree:
                # every cell is reachable, with exactly one route to the exit.
                self.assertEqual(edges, 24)
                parents = {0:None}
                queue = [0]
                for cell in queue:
                    for other in graph[cell]:
                        if other not in parents:
                            parents[other] = cell
                            queue.append(other)
                self.assertEqual(len(parents), 25)
                route = set()
                cell = 24
                while cell is not None:
                    route.add(cell)
                    cell = parents[cell]
                marked = {i for i in range(25) if solution[2*(i//5)+1][2*(i%5)+1] == '.'}
                self.assertEqual(marked, route)
        self.assertGreater(len(mazes), 1)

    def test_life(self):
        from life_support import initial, step, terminal
        source = (ROOT/'examples/c/life.c').read_text()
        if not SIZE:
            assembly, compiler = cc4.compile_source(source, 'life')
            memory, symbols, _ = asm4.Assembler().assemble(assembly)
            for suffix, content in (('asm',assembly), ('hex',asm4.hex_file(memory)),
                                    ('map',asm4.map_file(symbols))):
                self.assertEqual(content, (ROOT/f'examples/c/life.{suffix}').read_text())
            self.assertLessEqual(compiler.rom_end,4096)
            self.assertLessEqual(compiler.memory_top,2048)
            self.assertLessEqual(compiler.slots_used,128)
        for pattern in range(6):
            with self.subTest(pattern=pattern):
                generations = 120 if pattern == 0 else 8
                program = source.replace('#define PATTERN 0',f'#define PATTERN {pattern}')
                program = program.replace('#define GENERATIONS 120',f'#define GENERATIONS {generations}')
                output = run_c(program, limit=200_000_000)
                frames, clears, visible, screen = terminal(output)
                self.assertEqual(clears,1)
                self.assertTrue(visible)
                self.assertEqual(''.join(screen[20]).rstrip(),'Done.')
                self.assertEqual(len(frames),generations+1)
                board = initial(pattern)
                previous = None
                for generation,population,state,shown,writes in frames:
                    self.assertEqual(generation,0 if previous is None else last_generation+1)
                    self.assertEqual(population,len(board))
                    self.assertEqual(state,'RUNNING')
                    self.assertEqual(shown,board)
                    if previous is not None:
                        self.assertEqual(writes,previous ^ board)
                    previous = board
                    last_generation = generation
                    board = step(board)
                if pattern == 3:
                    self.assertEqual(frames[-1][3],initial(3))  # still life
                if pattern == 2:
                    self.assertEqual(frames[2][3],initial(2))  # period-two oscillator
                if pattern == 1:
                    self.assertEqual(frames[4][3],{(r+1,c+1) for r,c in initial(1)})
        for keys, expected in (
                (b'q',[(0,'RUNNING')]),
                (b' nnr nq',[(0,'RUNNING'),(0,'PAUSED'),(1,'PAUSED'),(2,'PAUSED'),
                              (0,'PAUSED'),(0,'RUNNING'),(1,'RUNNING'),(2,'PAUSED')]),
                (b'NNRQ',[(0,'RUNNING'),(1,'PAUSED'),(2,'PAUSED'),(0,'PAUSED')])):
            with self.subTest(keys=keys):
                frames, clears, visible, screen = terminal(run_c(source,keys=keys))
                self.assertEqual([(f[0],f[2]) for f in frames],expected)
                self.assertEqual(clears,1)
                self.assertTrue(visible)
                for generation,population,state,shown,writes in frames:
                    board = initial(0)
                    for _ in range(generation): board = step(board)
                    self.assertEqual(shown,board)
                    self.assertEqual(population,len(board))

    def test_hardware(self):
        source = '''
int main()
{
    int chip, bank;
    __rom_out(3, 5);
    for (chip = 0; chip < 3; chip++) __rom_out(chip, chip + 8);
    __ram_out(2, 1, 12);
    for (bank = 0; bank < 2; bank++)
        for (chip = 2; chip < 4; chip++)
            __ram_out(bank, chip, bank * 4 + chip);
    printf("%d %d %d\\n", __rom_in(4), __rom_in(chip + 1), __rom_in(14));
    printf("%d %d %d %d %d\\n", __test(), __kbp(0), __kbp(4), __kbp(8), __kbp(3));
    if (__test()) puts("high"); else puts("low");
    return 0;
}
'''
        expected = ('ROM port 3: .*.*\nROM port 0: *...\nROM port 1: *..*\nROM port 2: *.*.\n'
                    'RAM bank 2 chip 1: **..\nRAM bank 0 chip 2: ..*.\nRAM bank 0 chip 3: ..**\n'
                    'RAM bank 1 chip 2: .**.\nRAM bank 1 chip 3: .***\n'
                    '0 0 0\n0 0 3 4 15\nlow\n')  # ntv4004's other input ports and TEST pin read 0
        self.assertEqual(run_c(source, options=('-o',)), expected)
        for call in ('__rom_out(16, 1)', '__ram_out(8, 0, 1)', '__ram_out(0, 4, 1)', '__rom_in()'):
            with self.subTest(call), self.assertRaises(cc4.CompileError):
                cc4.compile_source(f'int main() {{ {call}; return 0; }}')

    def test_traffic(self):
        def lamps(road, crossing):
            def bits(value):
                return f'{value:04b}'.replace('0', '.').replace('1', '*')
            return [f'ROM port 0: {bits(road)}', f'ROM port 1: {bits(crossing)}']
        lines = lamps(1, 2) + ['road green; press a key to cross']
        for _ in range(2):  # one crossing for each key press
            lines += lamps(2, 2) + ['road amber'] + lamps(4, 2) + lamps(4, 1) + ['walk']
            lines += (lamps(4, 0) + lamps(4, 1)) * 4 + lamps(4, 2) + lamps(1, 2) + ['road green']
        expected = '\n'.join(lines) + '\n'
        source = (ROOT / 'examples' / 'c' / 'traffic.c').read_text()
        self.assertEqual(run_c(source, keys=b'xy', options=('-o',)), expected)

    def test_interrupts(self):
        source = (ROOT / 'examples' / 'c' / 'clock.c').read_text()
        lamps = ['ROM port 0: ...*', 'ROM port 0: ....']
        expected = ''.join(f'{lamps[(n + 1) % 2]}\n0:{n:02d}\n' for n in range(1, 11)) + 'done\n'
        self.assertEqual(run_c(source, options=('-I:9259', '-o'), cpu='4040'), expected)
        # Interrupts every few thousand cycles, from a handler that uses the library and a function of
        # its own, must not disturb a program.
        handler = '''
int churn, hits[8];
char seen;
int mix(int x) { return (x * 7 + 3) % 1000; }
__interrupt void tick(void)
{
    churn = mix(churn) / 3 + churn;
    hits[churn & 7] += 1;
    seen = churn;
}
'''
        for seed in range(8):
            source, expected = random_program(seed)
            source = handler + source.replace('int main()\n{\n', 'int main()\n{\n    __ei();\n', 1)
            with self.subTest(seed=seed):
                try:
                    output = run_c(source, 300_000_000, options=('-I:4999',), cpu='4040')
                except cc4.CompileError as error:
                    self.assertIn('bytes of ROM', str(error))
                    continue
                self.assertEqual(output, expected)
        errors = {
            '__interrupt void h(void) {} int main() { return 0; }': ('4004', 'need the 4040'),
            'int main() { __ei(); return 0; }': ('4004', 'needs the 4040'),
            '__interrupt int h(void) { return 1; } int main() { return 0; }': ('4040', 'must be void'),
            '__interrupt void h(void) {} int main() { h(); return 0; }': ('4040', 'cannot be called'),
            'int f() { return 1; } __interrupt void h(void) { f(); } int main() { return f(); }':
                ('4040', 'called by both'),
            'int f(int n) { return n ? f(n - 1) : 0; } __interrupt void h(void) { f(2); } int main() { return 0; }':
                ('4040', 'recursive'),
            '__interrupt void h(void) {} __interrupt void g(void) {} int main() { return 0; }': ('4040', 'one __interrupt'),
        }
        for source, (cpu, message) in errors.items():
            with self.subTest(source), self.assertRaises(cc4.CompileError) as caught:
                cc4.compile_source(source, cpu=cpu, size=SIZE)
            self.assertIn(message, str(caught.exception))

    def test_switch(self):
        source = r"""
int calls;
int choose(int n) { calls++; return n; }
int classify(int n) {
    int value = 0;
    switch (choose(n)) {
        case -2: value = 10;
        case 0: value += 2; break;
        default: value = 30; break;
        case 1: case 2: value = 20; break;
        case 256: return 40;
        case -1: return 50;
    }
    return value;
}
int main() {
    int i, total = 0;
    printf("%d %d %d %d %d %d %d\n", classify(-2), classify(0),
        classify(1), classify(2), classify(3), classify(256), classify(-1));
    printf("calls %d\n", calls);
    for (i = 0; i < 5; i++) {
        switch (i) {
            case 0: continue;
            case 1:
                while (1) { total += 10; break; }
                break;
            case 2:
                switch (i + 1) { case 3: total += 20; break; }
                break;
            default: total++;
        }
        total += 100;
    }
    printf("total %d\n", total);
    i = 0;
    switch (i++) { case 0: putchar('a'); }
    switch (i++) { case 0: putchar('X'); }
    switch (i++) { }
    printf(" %d\n", i);
    switch ((unsigned)32768) { case 32767: putchar('X'); break;
        case 32768U: putchar('b'); break; default: putchar('X'); }
    switch ((unsigned)65535) { case -1: putchar('c'); break; }
    switch ((char)255) { case -1: putchar('X'); break;
        case 255: putchar('d'); }
    switch (1) puts("unreachable");
    putchar('\n');
    return 0;
}
"""
        self.assertEqual(run_c(source), '12 2 20 20 30 40 50\ncalls 7\ntotal 432\na 3\nbcd\n')
        # Case labels can occur inside a nested loop (Duff's device).
        source = r"""
int main() {
    int count = 6, rounds = 2;
    switch (count % 4) {
        case 0: do { putchar('x');
        case 3:      putchar('x');
        case 2:      putchar('x');
        case 1:      putchar('x');
                } while (--rounds > 0);
    }
    putchar('\n'); return 0;
}
"""
        self.assertEqual(run_c(source), 'xxxxxx\n')

    def test_goto(self):
        source = r"""
int f(int n) {
    int saved = n + 10, stage = 0, result = 0;
again:
    if (stage) return saved + result;
    if (!n) return saved;
    result = f(n - 1);
    stage = 1;
    goto again;
}
int g() { goto same; return 99; same: return 7; }
int main() {
    int i = 0, sum = 0;
    goto begin;
    sum = 999;
begin:
    sum += ++i;
    if (i < 4) goto begin;
    while (1) { switch (i) { case 4: goto done; } }
done:
    printf("%d %d %d\n", sum, i, f(3));
    goto same;
    puts("unreachable");
same:
    printf("%d\n", g());
    { goto inner; puts("unreachable"); inner: putchar('x'); }
    putchar('\n');
    return 0;
}
"""
        self.assertEqual(run_c(source), '10 4 46\n7\nx\n')

    def test_sizeof(self):
        source = r"""
char bytes[7];
int words[4];
_Bool bits[13];
__nibble nibbles[5];
unsigned count = sizeof(words) / sizeof(words[0]);
char small(void);
int hits;
char small(void) { hits++; return 1; }
int main() {
    char c = 3, local[sizeof(words)];
    _Bool b;
    __nibble n;
    int i = 0, a[sizeof(char[3])];
    printf("%u %u %u %u %u %u\n", sizeof(int), sizeof(unsigned short),
        sizeof(char), sizeof(_Bool), sizeof(__nibble), sizeof(const volatile char));
    printf("%u %u %u %u %u %u %u\n", sizeof bytes, sizeof(words), sizeof bits,
        sizeof nibbles, count, sizeof(local), sizeof a);
    printf("%u %u %u %u %u %u %u %u\n", sizeof c, sizeof(+c), sizeof(c++),
        sizeof b, sizeof n, sizeof((char)0), sizeof((0, c)), sizeof(c + c));
    printf("%u %u %u %u %u %u\n", sizeof "ab" "cd", sizeof("a\0b"),
        sizeof(small()), sizeof(words[i++]), sizeof(1 / 0), sizeof sizeof c);
    sizeof(i = small());
    printf("%d %d %d\n", i, c, hits);
    return 0;
}
"""
        expected = ('2 2 1 1 1 1\n7 8 13 5 4 8 6\n1 2 1 1 1 1 1 2\n'
                    '5 4 1 2 2 2\n0 3 0\n')
        self.assertEqual(run_c(source), expected)
        # Large type-only sizes must not allocate RAM, even as initializers.
        source = 'unsigned n=sizeof(int[32767]); int main(){printf("%u\\n",n);return 0;}'
        _, compiler = cc4.compile_source(source, size=SIZE)
        self.assertEqual(run_c(source), '65534\n')
        self.assertEqual(compiler.memory_top, 0)

    def test_control_flow_errors(self):
        cases = {
            'int main(){goto missing;}': 'label missing is not defined',
            'int main(){here:; here:;}': 'defined twice',
            'int f(){goto here;} int main(){here:;}': 'label here is not defined',
            'int main(){case 1:;}': 'not in a switch',
            'int main(){default:;}': 'not in a switch',
            'int main(){switch(0){case 1:; case 1:;}}': 'duplicate case',
            'int main(){switch(0){case -1:; case 65535U:;}}': 'duplicate case',
            'int main(){switch(0){default:; default:;}}': 'duplicate default',
            'int main(){int n; switch(n){case n:;}}': 'constant expression',
            'int main(){switch(0){continue;}}': 'not in a loop',
            'int main(){sizeof(void);}': 'void',
            'void f(){} int main(){sizeof(f());}': 'void',
            'void f(){} int main(){sizeof(1 ? f() : f());}': 'void',
            'void f(){} int main(){switch(f()) {}}': 'integer expression',
            'int main(){switch((void)0) {}}': 'integer expression',
            'int main(){sizeof((void)0);}': 'void',
            'int main(){int a[3]; sizeof(a+1);}': 'pointers',
            'int main(){int n; sizeof(int[n]);}': 'constant length',
            'int main(){sizeof(char[0]);}': 'positive constant',
        }
        for source, message in cases.items():
            with self.subTest(source), self.assertRaises(cc4.CompileError) as caught:
                cc4.compile_source(source, size=SIZE)
            self.assertIn(message, str(caught.exception))

    def test_errors(self):
        cases = {
            'int *p;': 'pointers',
            'long x;': 'long',
            'int a[3] = {1};': 'initializers',
            'int f() { return 0; }': 'no main',
            'int main() { undefined(); return 0; }': 'not defined',
            'int main() { int x; x = y; return 0; }': 'not declared',
            'int main() { break; }': 'not in a loop',
            'char big[1025]; int x[1]; int main() { return 0; }': 'RAM characters',
            'int r(int n) { int a[2]; return r(n); } int main() { return r(1); }': 'local array',
        }
        for source, message in cases.items():
            with self.subTest(source):
                with self.assertRaises(cc4.CompileError) as caught:
                    cc4.compile_source(source)
                self.assertIn(message, str(caught.exception))


if __name__ == '__main__':
    unittest.main()
