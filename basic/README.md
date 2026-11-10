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

On Windows, use `ntv4004.exe`. The interpreter also works under `-4`, but does
not require any 4040 instructions. For interactive use, run the ROM without `-l`
and enter a complete program, followed by `RUN` on its own line:

```basic
10 LET A=1
20 PRINT A*A
30 LET A=A+1
40 IF A<=5 THEN 20
50 END
RUN
```

The banner is `BASIC4`. Programs execute once; `END`, falling off the last line,
or an error stops the interpreter. There is no line editor, `LIST`, or second
`RUN` session. Numbered lines must be supplied in strictly increasing order.
`RUN` must have a terminating newline. EOF ends emulation; it does not implicitly
run a program. File input should be ASCII, with either LF or CRLF line endings.

For `INPUT`, type unsigned decimal digits after the `? ` prompt. Blank input
lines and leading spaces are skipped. In a file, put the numerical input after
`RUN`: `input.bas` includes `21` as its sample input. Console input is not echoed
by the interpreter. A `-l` file remains the input source throughout execution;
the interpreter cannot switch to the keyboard when that file ends.

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
| 5 | A zero, duplicate or out-of-order line number, or more than 32 lines. |
| 6 | Statement storage is full. |
| 7 | Array subscript outside 0 through 199. |

An intentional BASIC loop can run forever. The emulator's `-n:cycles` option
limits execution, for example `-n:1000000`; reaching that limit exits with status 2.

## Building and testing

```sh
python3 cc4.py --size --stats basic/basic.c
python3 basic/build.py --all       # also builds the larger-program profile
python3 tests/basic.py
python3 tests/basic_large.py
./test.sh                         # Windows: test.bat
```

The checked-in `.asm`, `.hex` and `.map` are reproducible outputs of `cc4.py`
with **`--size` required**. The expanded interpreter is too large in the normal
speed-oriented profile, needing 4,305 bytes. With `--size` it occupies 3,219
stored bytes and ends at ROM byte 3,224 of 4,096, including placement gaps,
leaving 872 bytes free; the larger-program profile ends at byte 3,208. Its arrays use 1,928 of 2,048 main RAM nibbles
(964 bytes); scalars use 56 of 128 status registers. There is no parser recursion
or dynamically allocated array. Both the original 4004 ROM and RAM limits hold.

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

The supplied three-guess game takes **1,505,317 instruction cycles**, about
**16.27 seconds** at 740 kHz, excluding I/O waits. Interactive time depends on
your guesses and typing. Tests also verify the game in Intel's INTERP/4.

## e benchmark

`examples/e.bas` is the same factorial-series decimal spigot used by the C and
assembly e benchmarks: 200 remainder entries produce 192 digits without floating
point. Division and subtraction replace the remainder operator. The first output
value is 27; subsequent output values are single digits, joined using `PRINT X;`.
The BASIC program uses 20 lines and 220 stored bytes, including line terminators.

It prints the `BASIC4` banner, 192 digits, a newline, then `done` and another newline.
One complete load/run takes **933,594,623 instruction cycles**, about **10,092.91
seconds (2 hours 48 minutes)** on a 740 kHz 4004, excluding I/O waits. Host
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
unsegmented sieve. A complete ten-pass load/run takes **10,841,654,825 instruction
cycles**, about **117,207.08 seconds (32 hours 33 minutes)** at 740 kHz, excluding
I/O waits. Host emulation took about 49 seconds on the development machine.
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

TTT uses a second ROM profile, `large.hex` (banner `BASIC4L`), built from the
same C interpreter. It trades the large array and `INPUT` for program storage:

| Resource | Standard `basic.hex` | Larger-program `large.hex` |
| --- | --- | --- |
| Source storage | 384 bytes, 32 lines | 832 packed bytes, up to 255 lines |
| Line numbers | 1–65535 | 1–255 |
| Integer array | `@(0)`–`@(199)` | `@(0)`–`@(63)` |
| `INPUT` | Supported | Unsupported |
| ROM end, including gaps | 4015 bytes | 3932 bytes |
| Main RAM | 1928 nibbles | 2024 nibbles |
| Status registers | 56 | 61 |

The larger profile loads ordinary ASCII BASIC on the 4004. Its native loader
replaces statement keywords and `THEN` with single-byte tokens and removes
whitespace outside strings. Each stored line also needs a one-byte line number
and a zero terminator. Jumps scan these records rather than using a separate
line-index table. Strings retain case and spaces. A colon outside a string and
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

A complete native load/run takes **8,687,256,898 instruction cycles**, about
**93,916.29 seconds (26 hours 5 minutes)** at 740 kHz, excluding I/O waits.
Host emulation took about 38 seconds on the development machine. The regression
test runs the full search and checks the exact output; it also checks packed
storage boundaries, CRLF input, branches, scalar `T` versus `THEN`, array bounds,
and reproducible ROM builds. The standard interpreter remains unchanged in size.
