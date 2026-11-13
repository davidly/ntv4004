# BASIC4

A small BASIC interpreter running entirely on the emulated **Intel 4004**.
The C source is built by this repository's `cc4.py`. Its generated ROM reads
ASCII BASIC source through the console, stores the statements in 4002 RAM,
and parses and executes them on the 4004. Python is needed for rebuilding and
tests, not for running BASIC programs. The emulator has no BASIC-specific hooks.

## Running

From the repository root:

```sh
./ntv4004 -l:basic/examples/hello.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/count.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/fib.bas basic/basic.hex
./ntv4004 -l:basic/examples/squares.bas basic/basic.hex
./ntv4004 -l:basic/examples/input.bas basic/basic.hex
./ntv4004 -l:basic/examples/mastermind.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/e.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/sieve.bas basic/basic.hex
```

On Windows, use `ntv4004.exe`. For an interactive session, run:

```sh
./ntv4004 basic/basic.hex
```

BASIC prints `BASIC4`, `READY (UPPERCASE)`, and a `> ` prompt. Type uppercase
keywords and press Enter. Input is echoed, and Backspace (or Delete/backspace
on Unix terminals) corrects the current line before you submit it. For example:

```text
> PRINT 2+2
4
> 10 LET A=A+1
> 20 PRINT A
> 30 END
> LIST
10 LET A=A+1
20 PRINT A
30 END
> RUN
1
READY (UPPERCASE)
> RUN
1
READY (UPPERCASE)
> BYE
```

| Command | Behavior |
| --- | --- |
| `RUN` | Clear variables and the array, then run the stored program; retain its source. |
| `LIST` | Print the numbered program. |
| `NEW` | Clear the program, variables, and array. |
| `BYE` | Exit BASIC. Ctrl-C or Ctrl-Q also ends emulation. |

Statements can also execute directly at the prompt. `LET`, `PRINT`, `INPUT`,
and `REM` work without a line number. Immediate `GOTO` and a taken `IF ... THEN`
start executing the stored program at their target, preserving variables.
`END` ends the current execution and returns to the prompt. Program completion
and errors also return to the prompt; errors preserve the stored source.

Numbered lines must still be entered in strictly increasing order. Backspace
edits the line being typed; stored-line replacement, deletion, and insertion
are not implemented. Use `NEW` to enter a revised program. Direct statements
and command lines are limited to 47 characters; numbered source retains its
existing 384-byte total storage limit and can have longer individual lines.
Strings preserve case; BASIC keywords and variable names must be uppercase.

For `INPUT`, type unsigned decimal digits after the `? ` prompt. Typed numbers
are echoed and can be corrected before Enter. Blank input lines and leading
spaces are skipped. A malformed input line is consumed before returning to the
prompt, so its remaining characters are not mistaken for commands.

With `-l:file` or redirected standard input, the interpreter keeps batch
behavior: it loads a complete numbered program followed by `RUN`, executes
once, and stops at `END`, the end of the program, or an error. Input is not
echoed and no interactive prompts are printed. Numerical input belongs after
`RUN` in the file; `input.bas` includes `21`. EOF ends emulation without an
implicit `RUN`; each command needs its terminating newline. A `-l` file does
not switch to the keyboard when it ends. Files should be ASCII, with LF or
CRLF line endings. `-c` forces the interactive line console for redirected/file
input, primarily for scripted sessions and tests; finish such sessions with
`BYE`.

The larger-program `large.hex` profile accepts echoed numbered-line entry
on a terminal, then runs once after `RUN`. Its packed loader retains its
original load-once model; the full prompt commands above apply to `basic.hex`.
Both ROMs run on the original 4004; `-4` is optional and no 4040 instructions
are required.

## Language

Keywords and the single-letter variables `A` through `Z` are uppercase.
Variables initially hold zero. Spaces and tabs separate tokens; strings preserve
case and spaces. Optional keyword spacing can be omitted: `IFI<200 THEN50` means
`IF I<200 THEN 50`. The sieve uses this compact spelling to fit program storage. Exactly one statement is allowed per numbered line.

| Statement | Example | Meaning |
| --- | --- | --- |
| `LET variable=expression` | `LET A=A+1` | Assign a variable; `LET` is required. |
| `PRINT expression` | `PRINT A*2+1` | Print an unsigned decimal integer and newline. |
| `PRINT "text"` | `PRINT "Hello!"` | Print a string and newline; no escapes or embedded quotes. |
| `INPUT variable` | `INPUT N` | Read an unsigned decimal integer. |
| `GOTO line` | `GOTO 20` | Jump to a literal line number. |
| `IF expression relation expression THEN line` | `IF A<=10 THEN 20` | Jump when the comparison is true. |
| `REM text` | `REM A COMMENT` | Ignore the remainder of the line. |
| `END` | `END` | Stop execution. |

There is one built-in array of **200 unsigned 16-bit integers**, initially zero.
Use `@(0)` through `@(199)`; the subscript must be a decimal constant or a scalar
variable, not an expression. For example:

```basic
10 LET I=199
20 LET @(I)=65535
30 PRINT @(199)
40 END
RUN
```

`LET`, `PRINT`, `INPUT` and expressions accept array elements. To use a computed
index, first store it in a scalar, such as `LET J=I-1`, then use `@(J)`. An invalid
subscript stops execution before accessing outside the array.

A trailing semicolon on either kind of `PRINT` suppresses its newline:
`PRINT "Value: ";` followed by `PRINT A` produces one line. Each statement still
prints only one item; the semicolon is not a multiple-item separator.

Expressions support decimal constants, variables, array elements, `+`, `-`, `*`, and `/`.
Multiplication and division bind before addition and subtraction; operators of
one precedence associate left to right. Division discards the fractional part.
All arithmetic is unsigned, modulo 65536: `65535+1` gives 0 and `0-1` gives
65535. Constants, line numbers and input numbers cannot exceed 65535.

Relations are `=`, `<`, `<=`, `>`, and `>=`, using unsigned comparisons. A missing
`THEN` target is an error only when its branch is taken. This version has no
parentheses, unary signs, `<>`, floating point, `DIM`, named arrays, `FOR`, `GOSUB`, or multiple
items on one `PRINT` line. To negate a number, use `0-A`; to express more complex
formulas, assign intermediate results to variables.

## Limits and errors

For the standard `basic.hex` profile:

* 32 numbered lines, with line numbers from 1 to 65535.
* 384 bytes for statements, including one zero terminator per line. Line numbers
  and whitespace before the statement are not stored. Spaces inside statements
  and comment/string contents count toward this limit.
* 26 variables and one 200-element array, all unsigned 16-bit integers.

Errors print `?ERROR n` and stop. They do not exit the host with an error status;
check the diagnostic when automating BASIC programs. A failing `PRINT` may have
already written part of its output.

| Code | Meaning |
| --- | --- |
| 1 | Syntax error or malformed numerical input. |
| 2 | A decimal constant, input number or line number exceeds 65535. |
| 3 | Division by zero. |
| 4 | A taken jump targets a line that does not exist. |
| 5 | A zero, duplicate or out-of-order line number, or more than the profile's line limit. |
| 6 | Statement storage is full. |
| 7 | Array subscript outside 0 through 199. |

An intentional BASIC loop can run forever. The emulator's `-n:cycles` option
limits execution, for example `-n:1000000`; reaching that limit exits with status 2.

## Byte-array profile

`byte.hex` (banner `BASIC4B`) retains the standard commands, `INPUT`, and
interactive `RUN`, `LIST`, `NEW`, and `BYE`. Its 26 scalar variables and
arithmetic remain unsigned 16-bit. Its 200-element `@()` array stores
unsigned bytes: writing an element keeps the low eight bits, modulo 256.
An array read promotes that byte to a 16-bit value. For example, storing
255 then evaluating `@(0)+1` gives 256; storing that result back gives 0.
Constants and input numbers still have a 65535 maximum before assignment.
Array subscripts must be in 0–199 and are checked before narrowing.

This profile holds **48 lines and 512 bytes of statement text**, with line
numbers 1–65535. It occupies **4064 bytes of ROM**, **2008 main RAM nibbles**,
and **73 status registers**. The byte array occupies 400 nibbles rather than
800; this leaves room for the larger source buffer and line tables.

```sh
python3 basic/build.py --byte-array
./ntv4004 basic/byte.hex
./ntv4004 -p -l:basic/examples/e.bas basic/byte.hex
python3 tests/basic_byte.py
```

The e and sieve examples use only byte-sized array elements and work in
both standard and byte profiles. Programs requiring larger array values
should use a word-array profile. Execution still parses BASIC on the 4004;
byte storage adds no type declarations or per-element type metadata.

| Benchmark | Standard profile instruction cycles | Byte-array profile instruction cycles |
| --- | ---: | ---: |
| e, 192 digits | 441,734,957 | 442,232,835 |
| sieve, ten passes | 10,174,572,014 | 10,179,668,505 |

These profiles have essentially the same benchmark speed; the byte profile
provides more program capacity while retaining all standard commands.

## Building and testing

```sh
python3 cc4.py --size --stats basic/basic.c
python3 basic/build.py --all       # standard, larger-program and byte-array profiles
python3 tests/basic.py
python3 tests/basic_byte.py
python3 tests/basic_large.py
./test.sh                         # Windows: test.bat
```

The checked-in `.asm`, `.hex` and `.map` are reproducible outputs of
`python3 basic/build.py --all`, using **`--size`** compilation. The interactive
standard interpreter occupies 4,045 stored bytes and ends at ROM byte 4,048 of
4,096, including placement gaps. Its arrays and 48-byte command scratch buffer
use 2,024 of 2,048 main RAM nibbles (1,012 bytes); scalars use 72 of 128 status
registers. The command buffer temporarily swaps with the first 48 bytes of
source while a direct statement is parsed, then restores them. This permits
direct commands and `NEW` even when all 384 program bytes are occupied. The
packed larger-program profile ends at ROM byte 4,072. There is no parser
recursion or dynamically allocated array; both original 4004 limits hold.

## Mastermind

`examples/mastermind.bas` is a four-digit guessing game using digits 1 through
6, with repetitions allowed. It fits the standard interpreter in **30 lines
and 342 stored bytes**. After each valid guess it prints `E` followed by the
number of digits in the correct position, then `M` followed by the number of
correct digits in other positions. A digit is counted only as often as it
occurs in the secret; exact matches are excluded from the misplaced count.
`E4` wins and ends the program.

The secret is deliberately fixed at **1123** so the example and tests are
reproducible. The `.bas` file includes three demonstration guesses after `RUN`:
1234 scores `E1 M2`, 1111 scores `E2 M0`, and 1123 scores `E4 M0`, then `WIN`.
Run the demonstration with:

```sh
./ntv4004 -l:basic/examples/mastermind.bas basic/basic.hex
```

To play with keyboard input, run `./ntv4004 basic/basic.hex`, paste the numbered
lines and `RUN` from the file, and then type your guesses instead of the three
sample inputs. Alternatively, edit the guesses after `RUN` in a copy of the
file. A `-l` file cannot switch to keyboard input when it runs out.

A guess must contain exactly four digits, each from 1 to 6. An invalid guess
within the interpreter's unsigned decimal input range simply repeats the
prompt without a score. Malformed input or a number above 65535 stops with the
usual BASIC input error. The program has no guess limit. It resets the secret's
remaining digit counts in `@(1)` through `@(3)` before each attempt, tallies the
total matches by consuming those counts, and subtracts exact matches to obtain
misplaced matches. The secret integer in line 6 and the frequencies in lines
2–4 must agree if you change the secret.

The supplied three-guess game takes **1,440,008 instruction cycles**, about
**15.57 seconds** at 740 kHz, excluding I/O waits. Interactive time depends on
your guesses and typing. Tests also verify the game in Intel's INTERP/4.

## e benchmark

`examples/e.bas` is the same factorial-series integer spigot used by the C and
assembly e benchmarks: 200 remainder entries produce 192 digits without floating
point. Division and subtraction replace the remainder operator. Each sweep produces two digits with base-100 arithmetic; the first
block is 271. Output pads subsequent blocks with a leading zero when needed
and truncates the last block to exactly 192 digits. Intermediates stay below
20,000, within the interpreter's unsigned 16-bit arithmetic.
The BASIC program uses 27 lines and 305 stored bytes, including line terminators.

It prints the `BASIC4` banner, 192 digits, a newline, then `done` and another newline.
One complete load/run takes **441,734,957 instruction cycles**, about **4,775.51
seconds (1 hour 19 minutes)** on a 740 kHz 4004, excluding I/O waits. Host
emulation is much faster. For a finite emulator budget, allow at least
`-n:1200000000` cycles. Source is parsed and executed on the emulated CPU; there
is no host-side BASIC translation or hard-coded e output.

## Segmented sieve benchmark

`examples/sieve.bas` counts the **1899 odd primes from 3 through 16383** across
**ten passes**, matching the original benchmark's range and repetition count.
It uses 200 array elements as flags for one segment at a time. The final segment
has only 191 valid flags; its nine spare entries are excluded from the count.
It fits the unchanged interpreter: exactly **32 lines and 381 stored bytes**.

| Variable | Use |
| --- | --- |
| `T` | Completed passes. |
| `C` | Prime count, reset each pass. |
| `B` | First global odd-number index in the current segment. |
| `I` | Flag initialization/counting index. |
| `P` | Odd divisor. |
| `K` | Global index of a multiple being marked. |
| `J` | The corresponding slot in the 200-element array. |

Global index `i` represents `2*i+3`. For each odd divisor `P`, marking starts at
`P*P/2-1` (integer division), adjusted to the first matching index in the segment,
and advances by `P`. Processing stops when the divisor's square lies beyond the
segment. All odd divisors are considered, including composite divisors whose
marking is redundant; this avoids storing a separate base-prime table.

This is a segmented variant, so report its timings separately from the original
unsegmented sieve. A complete ten-pass load/run takes **10,174,572,014 instruction
cycles**, about **109,995.37 seconds (30 hours 33 minutes)** at 740 kHz, excluding
I/O waits. Host emulation took about 11 seconds on the development machine.
If using `-n`, allow `-n:12000000000`. Output is:

```
BASIC4
1899 primes.
```

The test suite runs all ten passes and also checks smaller ranges around zero,
one flag, a complete segment, and partial final segments against independent
prime counts. The longer benchmark test allows a 300-second host timeout.

## Regression tests

Tests rebuild and compare all generated files and execute every example. They
cover unsigned wraparound, expression precedence, all five relations,
forward/backward jumps, input and CRLF files, exact line/text limits, malformed
programs, array bounds (including 0 and 199), trailing semicolons, and the
emulator's execution budget. All 192 e digits are checked against an independent
high-precision decimal calculation; sieve counts are checked independently too.

## TTT and the larger-program profile

```sh
./ntv4004 -p -n:10000000000 -l:basic/examples/ttt.bas basic/large.hex
```

TTT uses the larger-program ROM profile, `large.hex` (banner `BASIC4L`), built from the
same C interpreter. It trades the large array and `INPUT` for program storage:

| Resource | Standard `basic.hex` | Byte-array `byte.hex` | Larger-program `large.hex` |
| --- | --- | --- | --- |
| Source storage | 384 bytes, 32 lines | 512 bytes, 48 lines | 832 packed bytes, up to 255 lines |
| Line numbers | 1–65535 | 1–65535 | 1–255 |
| Array | 200 unsigned words | 200 unsigned bytes | 64 unsigned words |
| `INPUT` | Supported | Supported | Unsupported |
| Interactive commands | Supported | Supported | Unsupported |
| ROM end, including gaps | 4048 bytes | 4064 bytes | 4072 bytes |
| Main RAM | 2024 nibbles | 2008 nibbles | 2024 nibbles |
| Status registers | 72 | 73 | 87 |

The larger profile loads ordinary ASCII BASIC on the 4004. Its native loader
replaces statement keywords and `THEN` with single-byte tokens, encodes integer
literals in one, three or four nonzero bytes, and removes whitespace outside
strings. Integer tokens are decoded during execution; an overflowing literal
raises error 2 only if execution reaches it. Each stored line also needs a
one-byte line number and a zero terminator. An eight-entry cache in status
registers holds recent branch destinations; a cache miss scans the packed
records. Execution finds the next line from the statement parser's final
position. Strings retain case and spaces. A colon outside a string and
embedded NUL bytes are rejected. Otherwise the arithmetic and statements match
the standard profile, except `INPUT`. Error 5 also covers line numbers above 255;
error 7 covers array subscripts above 63. This profile does not run the e or sieve
examples, which need the standard profile's 200-element array.

`examples/ttt.bas` performs alpha-beta minimax for the three distinct initial
moves (corner, edge, center), visiting positions in ascending order. It checks
that each root is a draw and prints **6493 moves** for one complete iteration.
Recursion is represented by explicit four-word frames in the BASIC array:
board cells occupy 0–8, frames occupy 16–51, and the eight winning triples occupy
56–63. No recursive calls or host-side search are required. The source has 91
numbered lines and fits the packed source buffer.

A complete native load/run takes **3,191,215,378 instruction cycles**, about
**34,499.63 seconds (9 hours 35 minutes)** at 740 kHz, excluding I/O waits.
Host emulation took about 3 seconds on the development machine. The regression
test runs the full search and checks the exact output; it also checks packed
storage boundaries, integer-token boundaries, deferred overflow errors, branch-cache
eviction, CRLF input, branches, scalar `T` versus `THEN`, array bounds,
and reproducible ROM builds. The standard interpreter includes the interactive command loop; the packed
profile remains a load-once interpreter.

Interactive tests exercise repeated runs, direct statements, listing and reset,
full line/text capacity, source preservation after errors, malformed input,
CRLF, backspace/Delete, and a real POSIX pseudo-terminal. They also check that
terminal settings are restored on exit. Forced-console tests run on Windows.
All three profiles retain the original 4 KB ROM limit and the program and array
capacities listed above.
