# ntv4004

A portable Intel 4004 and 4040 emulator, a MAC4-compatible assembler, a
compiler for a subset of C, a small BASIC interpreter, and runnable examples, with Intel's own 1970s assemblers and simulator as
optional local references. The emulator implements both instruction sets,
4K (4004) or 8K (4040) of ROM, 4002 RAM, a console on a ROM I/O port,
instruction tracing and instruction-cycle accounting.

This builds and runs on Windows, macOS and Linux. The complete test suite,
including the optional Intel assembler and simulator comparisons, has been
validated on macOS, Ubuntu Linux and Windows.

Project code is **BSD-3-Clause**; see [LICENSE](LICENSE). Intel's historical
tools in [intel/](intel/README.md) are optional local inputs and are not part
of this repository.

## Contents

| Path | Contents |
| --- | --- |
| `i4004.cxx`, `i4004.hxx` | 4004 and 4040 CPU: instruction decoding, carry, 4002 RAM and status characters, ROM banks, the stack, and cycle accounting. |
| `ntv4004.cxx`, `trace.hxx` | Command-line host: Intel HEX loader, console ports, speed limiting, and debug and instruction tracing. |
| `asm4.py` | Assembler for Intel's MAC4 and MAC40 language, checked against them byte for byte. |
| `cc4.py` | Compiler for a subset of C, producing MAC4 source and assembling it with asm4.py. |
| `examples/` | hello, echo, fib, and the sieve, e and ttt benchmarks, with their HEX and symbol maps. |
| `examples/c/` | hello, a pedestrian crossing, a 4040 clock run by interrupts, eight queens, the Towers of Hanoi, a maze generator/solver, animated Life, and the sieve, e and ttt benchmarks in C, with the compiler's output. |
| `basic/` | Native 4004 BASIC interpreter, its C source and generated ROM image, and BASIC examples. |
| `intel/` | Runs Intel's MAC4, MAC40 and INTERP/4 from Tymshare tape 169278 on a PDP-10 runner; not bundled. |
| `tests/` | CPU tests from the MCS-40 manual, and comparisons with MAC4 and INTERP/4. |

## Build and run

Building needs a C++11 compiler; the assembler and tests need Python 3.8 or
newer. On Windows, use a Visual Studio developer command prompt.

```sh
./m.sh                          # Windows: m.bat
./ntv4004 -p examples/hello.hex
./ntv4004 examples/fib.hex
./ntv4004 -4 prog.hex           # the 4040
```

```
Hello from the Intel 4004!
319 instruction cycles, 0.000012 seconds elapsed
approximate real 4004 runtime: 0.003449 seconds at 740 kHz (excluding I/O waits)
```

Options:

| Option | Meaning |
| --- | --- |
| `-4` | emulate the 4040 (default 4004) |
| `-a:address` | entry address (default 0); above 0FFFH starts in the 4040's second ROM bank |
| `-l:file` | read console input from a file; EOF ends the program |
| `-n:cycles` | stop after this many instruction cycles; exit status 2 if the program has not ended |
| `-s:Hz` | limit speed to a clock rate, such as `-s:740000` |
| `-p` | report instruction cycles, elapsed time and the 740 kHz runtime |
| `-r` | report the final registers, stack and RAM on stderr |
| `-o` | show writes to the other ROM ports and the RAM output ports as lamps, bit 3 first: `ROM port 0: .*.*` |
| `-I:cycles` | 4040: request an interrupt every this many instruction cycles, like a timer chip |
| `-t`, `-i` | trace to `ntv4004.log`; `-i` adds every instruction, labeled from an adjacent `.map` (or `-m:file`), which names an address that has several labels by the first |

A program ends successfully with `HLT` (4040) or a `JUN` to its own address,
the usual way to stop a 4004, unless an `-I` interrupt can still be taken:
then `HLT` waits for it, and a program may idle in a loop while its
interrupts work. Ctrl-C or Ctrl-Q also exits.

### The console

The 4004 has no console instructions, so ntv4004 uses its I/O ports: `SRC`
selects a ROM chip's port by the high nibble of a register pair, and `WRR` and
`RDR` write and read it four bits at a time.

* ROM port 15 (`FIM 14,0F0H` then `SRC 14`) is the console. Write a character
  with two `WRR`s, high nibble first; read one with two `RDR`s, high nibble
  first. The first read waits for a key.
* ROM port 14 reads 1 when a key is ready and 0 otherwise, without waiting.
* LF input becomes CR, and CR output becomes LF. Characters are 7-bit.

Other ROM ports read 0. Writes to them and to the 4002 output ports (`WMP`)
appear in the `-t` log, and with `-o` on stdout. The `TEST` pin is 0.

## Small BASIC interpreter

`basic/basic.hex` runs on the original 4004 and interprets BASIC source read
through the emulated console. There is no host-side BASIC parser or compiler.
It supports 26 unsigned 16-bit variables, one 200-element integer array, `LET`, `PRINT`, `INPUT`,
`IF ... THEN`, `GOTO`, `REM` and `END`. Type numbered lines in increasing order,
then `RUN`; the stored program executes once and stops.

```sh
./ntv4004 -l:basic/examples/hello.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/fib.bas basic/basic.hex
./ntv4004 -l:basic/examples/input.bas basic/basic.hex
./ntv4004 -l:basic/examples/mastermind.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/e.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/sieve.bas basic/basic.hex
./ntv4004 -p -l:basic/examples/ttt.bas basic/large.hex
python3 basic/build.py --all                # rebuild both interpreter ROMs
```

The examples include counting, Fibonacci, squares, numerical input, Mastermind and a
192-digit decimal-spigot e benchmark, plus a ten-pass segmented sieve counting
1899 odd primes. The sieve uses the same 200-element array and fits in 32 lines
and 381 stored bytes. `@(I)` accesses the array and a trailing
semicolon on `PRINT` suppresses the newline. The interpreter requires `--size`
to fit in 4 KB of ROM. Programs
are limited to 32 lines and 384 bytes of statement text including terminators.
Keywords and variable names are uppercase; arithmetic wraps at 16 bits and has
ordinary multiplication/division precedence. Strings are supported by `PRINT`.
TTT uses the alternative `large.hex` profile: a 64-element array, 832 bytes of
packed program storage, line numbers 1–255, and no `INPUT`. Its iterative
alpha-beta search checks all three distinct openings and reports 6493 moves.
Both interpreter profiles fit the original 4004 ROM and RAM limits.
See [basic/README.md](basic/README.md) for the complete syntax, limits and errors.

`mastermind.bas` demonstrates an interactive guessing game with duplicate-aware
scoring: `E` counts exact positions and `M` counts misplaced digits. Its sample
input plays three guesses against the fixed secret 1123. See the
[Mastermind instructions](basic/README.md#mastermind) to play interactively.

Measured BASIC benchmark runtimes include loading and executing the source on
the emulated 4004. Estimated hardware times use a 740 kHz clock and exclude I/O
waits; these are instruction cycles, each taking eight clock periods.

| BASIC benchmark | Workload | Interpreter ROM | Instruction cycles | 740 kHz 4004 |
| --- | --- | --- | ---: | ---: |
| [sieve](basic/examples/sieve.bas) | Ten segmented passes; 1899 odd primes from 3 through 16383 | `basic.hex` | 10,841,654,825 | 117,207.08 s (32 h 33 min) |
| [e](basic/examples/e.bas) | 192 digits using the factorial-series spigot | `basic.hex` | 933,594,623 | 10,092.91 s (2 h 48 min) |
| [ttt](basic/examples/ttt.bas) | One iteration over three distinct openings; 6493 moves | `large.hex` | 8,687,256,898 | 93,916.29 s (26 h 5 min) |

The BASIC sieve uses segmentation to fit its 200-element array, so its timing
should be reported separately from the unsegmented assembly and C versions.

## The CPU

ntv4004 follows Intel's
[MCS-40 User's Manual](https://bitsavers.org/components/intel/MCS40/MCS-40_Users_Manual_Nov74.pdf)
(November 1974):

* One instruction cycle is 8 clock periods, 10.8 µs at 740 kHz. One-word
  instructions take one cycle; `JCN`, `FIM`, `JUN`, `JMS`, `ISZ` and `FIN` take
  two.
* `JCN` and `ISZ` jump within the page of the next instruction, so one in the
  last two bytes of a page jumps into the next page; `FIN` and `JIN` at a
  page's last byte likewise use the next page.
* `SUB`, `SBM` and `DAC` set the carry when there is no borrow. `DAA` adds 6
  when the carry is set or the accumulator exceeds 9, and only ever sets the
  carry. `KBP` returns 15 for anything but one bit.
* `DCL` selects one of 8 RAM banks, each 16 registers (4 chips of 4) of 16
  main and 4 status characters. `SRC`'s address is chip, register and
  character.
* The 4004 has three return levels plus the program counter; a fourth `JMS`
  overwrites the deepest return address. It decodes `01H`–`0FH` as `NOP`.
* The 4040 adds seven return levels, a second bank of R0–R7 (`SB0`, `SB1`),
  a second 4K ROM bank (`DB0`, `DB1`, taking effect on the third cycle after,
  so a following `JUN` or `JMS` crosses banks), `HLT`, `OR4`, `OR5`, `AN6`,
  `AN7`, `LCR`, `EIN`, `DIN`, `BBS` and `RPM`. No 4289 program memory is
  attached, so `RPM` reads 0.
* A 4040 interrupt, with `-I`, is taken after `EIN`: one more instruction
  runs, then a forced `JMS 003H` saves the `SRC` address and the register
  bank, and `BBS` restores them. No other interrupt is taken until `BBS`,
  nor in the three cycles after `DB0` or `DB1`. An interrupt ends a `HLT`,
  which executes NOPs until then. The accumulator, carry, RAM bank and
  R8–R15 are the program's to save.

## Assembler

```sh
python3 asm4.py examples/hello.asm            # writes hello.hex and hello.map
python3 asm4.py --4040 prog.asm               # accept the 4040 instructions
python3 asm4.py --listing examples/fib.asm
```

`asm4.py` assembles the language of Intel's MAC4 and MAC40 (see
[intel/README.md](intel/README.md#assemble) for its rules) except macros. It
rejects what MAC4 would silently get wrong: symbols that share their first 5
characters, odd register-pair operands, and `JCN` or `ISZ` targets off the next
instruction's page. `tests/asm.py` checks it against MAC4 and MAC40 on every
instruction and operand.

## C compiler

```sh
python3 cc4.py examples/c/ttt.c         # writes ttt.asm, ttt.hex and ttt.map
./ntv4004 -p examples/c/ttt.hex
python3 cc4.py --stats prog.c           # also report ROM and RAM use
python3 cc4.py --size --stats prog.c    # smaller ROM, modest extra cycles
python3 cc4.py -S prog.c                # write only the MAC4 source
```

No high-level language was made for the 4004 in its day. `cc4.py` compiles
C without pointers, structures or floating point:

* `int` and `unsigned` are 16 bits and `char` is 8 bits, unsigned. Arrays are
  one-dimensional; `_Bool` arrays are packed four flags to a RAM character.
* `__nibble` is a 4-bit unsigned type, the 4004's own size: a nibble array
  takes one RAM character per element, and nibble variables are packed four
  to a status register. `__CC4__` is predefined, so a program can use
  `__nibble` only under this compiler.
* Functions take parameters and return values, and may be recursive.
* Every C statement except `switch` and `goto`, and every operator except
  the pointer, member and `sizeof` operators.
* `putchar`, `getchar`, `puts`, and `printf` with a constant format and
  `%d`, `%u`, `%x`, `%c`, `%s` (a string constant) and `%%`.
* Built-ins for the hardware, compiled inline: see [Hardware](#hardware).
* The preprocessor handles `#define` with or without parameters, `#undef`,
  the `#if` family, and ignores `#include`.

The output is ordinary MAC4 source with the C lines as comments; Intel's
MAC4 assembles it to the same bytes as asm4.py. The 4004 shapes the code:

* Scalars live in the 4002 status characters, one 4-character register
  each, or one character each for `__nibble`s, so a variable's address is
  one byte: register and bank. Arrays live in main memory. That gives 127
  registers for scalars (one holds the stack pointer) and 2,048 characters
  for arrays.
* Arithmetic is done in R4–R7 and R8–R11 by a runtime library of small
  routines, included only when used. The compiled code keeps track of which
  variable R4–R7 holds, to skip reloading it.
* Values known to fit in 0 to 255 are compared in 8 bits, inline, without
  calling the library, and values that fit in 0 to 15 in 4 bits. Besides
  `char`s, constants and comparisons, these include the `int` and `unsigned`
  variables, parameters and functions that are only ever given such values,
  which the compiler finds by elimination.
* The hardware stack has only three levels, so it is left to the runtime
  library. A C call stores a return number with the callee and jumps; a
  return jumps through a table of the call sites. A call that can reach the
  caller again first saves the caller's variables that are read after it,
  on a stack in RAM, and restores them afterwards. An argument for a
  parameter the function never uses is evaluated only for its side effects.
* `JCN` reaches only its own page, so the compiler places the code itself,
  using `JCN` with the opposite condition around a `JUN` for distant
  targets, and keeps each library routine and its tables on one page.
* Programs must fit in the 4004's 4K of ROM. The 4040's second bank is not
  used.

The C benchmarks are the cpm_compilers sources. sieve's flags are a `_Bool`
array, since 8,191 `char`s would need eight times the 4002s' memory. ttt's
`main` takes no arguments, and its `ttype` is `__nibble` under this compiler
and `char` elsewhere:

| Program | ROM footprint | Instruction cycles | 740 kHz 4004 | Hand-written assembly |
| --- | ---: | ---: | ---: | ---: |
| [hello](examples/c/hello.c) | 90 bytes | 1,773 | 0.02 s | |
| [e](examples/c/e.c) | 812 bytes | 29,482,644 | 319 s | 12.0 times as long |
| [sieve](examples/c/sieve.c) | 616 bytes | 55,126,048 | 596 s | 13.1 times |
| [ttt](examples/c/ttt.c) | 1,688 bytes | 11,955,484 | 129 s | 14.3 times |
| [queens](examples/c/queens.c) | 1,146 bytes | 5,538,131 | 60 s | |
| [hanoi](examples/c/hanoi.c) | 979 bytes | 1,167,358 | 13 s | |
| [maze](examples/c/maze.c) | 1,944 bytes | 460,917 | 4.98 s | |
| [life](examples/c/life.c) | 2,306 bytes | 138,044,699 | 1,492 s | |

queens counts the 92 solutions to the eight queens problem by recursive
backtracking, with packed `_Bool` arrays for the columns and diagonals, and
shows the first. hanoi prints the moves for three discs of the Towers of
Hanoi and counts them for ten, recursing eleven deep. Like ttt, both use
`__nibble` under this compiler and `char` elsewhere, and print what gcc's
builds of the same sources print.

The assembly e benchmark uses division specialized for its small quotients
and a nibble lookup for multiplication by ten. C uses general arithmetic
helpers and takes 12.0 times as many cycles. For ttt, each recursive call saves
and restores five status registers (eight with `char`
instead of `__nibble`), which the hand-written version avoids by keeping
each depth's frame in its own RAM register.

### Maze generator and solver

```sh
python3 cc4.py --stats examples/c/maze.c
./ntv4004 -p examples/c/maze.hex
```

[maze.c](examples/c/maze.c) generates a 5×5 perfect maze, prints it, then marks
the unique route from the upper-left entrance to the lower-right exit with
`.` in each solution cell. Both generation and solving use iterative
depth-first search with an explicit 25-cell stack, rather than recursion.
Each cell's four passage bits occupy a single `__nibble`; visited and solution
flags use packed `_Bool` arrays. Main RAM use is 90 nibbles (45 bytes), plus
20 status registers for scalars and runtime state.

An eight-bit linear congruential generator chooses the first direction to try.
`SEED` is fixed at 37 for reproducible output; change it to another value from
0 through 255 and rebuild for a different maze. This is a small demonstration
PRNG, not a uniform sampler of mazes. The source also compiles with a host C
compiler, using `unsigned char` in place of `__nibble`.

Tests check several seeds in both compiler profiles: all 25 cells must be
reachable, the maze must contain exactly 24 internal passages, and the marked
solution must match an independently reconstructed route. The default ROM
also runs in Intel's INTERP/4 with matching ntv4004 output and cycle counts.

### Animated Conway's Game of Life

```sh
./ntv4004 -s:80000000 examples/c/life.hex
python3 cc4.py --stats examples/c/life.c    # rebuild after editing settings
```

[life.c](examples/c/life.c) runs a **32×16** Life board in a VT100-compatible
terminal at least **66 columns by 22 rows**. Live cells appear as `[]`. The
initial board combines a glider, a blinker, a block, and an R-pentomino. Cells
outside the board stay dead; edges do not wrap. The B3/S23 rules are evaluated
into a second packed `_Bool` grid before the current generation is changed.
The two grids use **306 RAM nibbles (153 bytes)**; scalars and runtime state
use **27 status registers**. No BASIC interpreter or host-side Life logic is
involved.

The program clears the screen once, hides the cursor, then updates only changed
cells using `ESC[row;columnH`. Consecutive changed cells share one cursor move.
It redraws the generation/population status in place, so the board neither
scrolls nor flashes through a blank screen. Normal completion and `q` restore
the cursor and leave the final board visible. Run directly in a terminal rather
than redirecting output to see the animation.

| Key | Action |
| --- | --- |
| Space | Pause or resume. |
| `n` | Advance one generation and pause. |
| `r` | Restore the initial pattern and generation zero, preserving pause state. |
| `q` | Quit. |

The default run ends after **120 generations**. Edit `GENERATIONS` to change the
limit; edit `PATTERN` to select 0 (mixed), 1 (glider), 2 (blinker), 3 (block),
4 (R-pentomino), or 5 (an oscillator against the top edge), then rebuild. Keyboard
controls are available in the 4004 build; a host C build runs the finite demo
automatically and produces the same terminal output when no keys are pressed.

`-s:80000000` deliberately uses an accelerated **80 MHz emulated clock** to pace
the animation at about nine generations per second. The complete default run
was measured at **13.80 seconds** with this setting, versus about **0.60 seconds**
unthrottled on the development machine. Lower `-s` for slower animation. At a
real 740 kHz 4004 clock the same 138,044,699 instruction cycles would take about
**24 minutes 52 seconds**, excluding I/O waits. The table above reports this
hardware estimate, not the paced animation time.

Tests replay the terminal controls into a virtual screen and compare every
frame of the full default run against independent Life rules. Separate cases
cover still lifes, period-two oscillators, glider translation, dead edges,
changed-cell-only updates, pause/step/reset/quit, and cursor restoration. Both
compiler profiles are checked, and a four-generation run is also compared with
Intel's INTERP/4 without adding a long simulation to the test suite.

### Smaller ROMs

All builds remove unreachable instructions after unconditional jumps and jumps
whose target is the next instruction. They also thread jumps: a jump to a label
whose code only jumps on goes straight to the final target, and so does a
conditional jump when that keeps it on its page. Labels remain entry points,
including indirect software-call continuations and the 4040's fixed interrupt
vector; other compiler labels nothing refers to are dropped.
The regenerated examples above use this default mode.

`--size` makes three further changes, trading some runtime for ROM:

* Comparisons of two bytes call `QEQ8`, `QGE8` or `QLE8` instead of comparing
  both nibbles in place: four bytes instead of eight or ten.
* Repeated `FIM 0,address` / `JMS helper` pairs, used at least three times,
  share a small stub that tail-jumps to the helper.
* Any other repeated run of straight-line code ending in a helper call is
  outlined the same way, taking first the run that saves the most bytes. A
  stub may call other helpers before its tail jump, but only while its
  deepest call still fits the 4004's three-level return stack above the
  compiled code; `tests/basic.py` checks each stub's depth independently.

None of these changes RAM allocation. Each shared use adds a JMS and a BBL:

| Program | Default ROM | `--size` ROM | ROM reduction | Extra cycles |
| --- | ---: | ---: | ---: | ---: |
| C TTT | 1,688 | 1,557 | 7.8% | 4.5% |
| C queens | 1,146 | 1,052 | 8.2% | 3.9% |
| C hanoi | 979 | 902 | 7.9% | 4.4% |
| C e | 812 | 796 | 2.0% | 1.5% |
| C sieve | 616 | 592 | 3.9% | 2.6% |

ROM footprint is the highest occupied byte plus one, including runtime, data
and placement gaps. Moving code can change short/long conditional-branch
selection, so cycle differences also include those layout effects. The default
cleanup changed the measured finite examples by less than 0.1% in cycles.
Both C profiles are checked against the existing randomized model, recursion,
console/hardware I/O and 4040 interrupts. The expanded BASIC interpreter uses
`--size` and has its own tests, including all 192 digits of e. For other C
programs, `--size` is optional; ordinary builds retain faster direct helper calls.

### Hardware

A 4004 program usually controls something, so these built-ins reach the
hardware directly. Each compiles to a few instructions; another compiler
can supply them as `#define`s, and `__CC4__` tells a program which it has.

| Built-in | Instructions | Does |
| --- | --- | --- |
| `__rom_out(chip, v)` | `SRC`, `WRR` | writes `v`'s low nibble to 4001 ROM chip 0–15's port |
| `__rom_in(chip)` | `SRC`, `RDR` | reads ROM chip 0–15's port |
| `__ram_out(bank, chip, v)` | `DCL`, `SRC`, `WMP` | writes `v`'s low nibble to 4002 chip 0–3's output port in bank 0–7 |
| `__test()` | `JCN 1` | 1 if the `TEST` pin is high |
| `__kbp(v)` | `KBP` | the keyboard-process code of `v`'s low nibble: 0–4, or 15 |

Chips and banks may be variables. ntv4004's console is ROM ports 14 and 15,
and `-o` shows the other ports' lamps.
[traffic.c](examples/c/traffic.c) is a pedestrian crossing: ROM port 0
drives the road's lamps and port 1 the crossing's, a key press is the
button, and delay loops time the phases for a 740 kHz 4004:

```sh
python3 cc4.py examples/c/traffic.c
./ntv4004 -o -s:740000 examples/c/traffic.hex     # press a key to cross
```

```
ROM port 0: ...*
ROM port 1: ..*.
road green; press a key to cross
ROM port 0: ..*.
ROM port 1: ..*.
road amber
```

### Interrupts

`--4040` compiles for the 4040, which adds an interrupt and `HLT`. One
function marked `__interrupt` handles the interrupt:

| Addition | Does |
| --- | --- |
| `__interrupt void f(void)` | runs `f` for each interrupt |
| `__ei()`, `__di()` | `EIN` and `DIN`: allow interrupts or not; they start disabled |
| `__halt()` | `HLT`: wait for the next interrupt |
| `volatile` | load a variable each time it is read, as an interrupt may change it |

The compiler puts a jump at 003H to entry code that selects register bank
1, so the program's R0–R7 are left alone; saves its accumulator, carry, RAM
bank and R8–R15 in three status registers; calls the handler like any C
function; restores them; and returns with `BBS`. That costs 131
instruction cycles. The handler cannot be called, and the functions it calls
must not be recursive or called by `main`, since an interrupt would
overwrite their variables. A variable wider than a nibble can change between
one nibble and the next of a read, so read shared ones with interrupts off.
`main` ends with `DIN`, so its final jump ends the program.

[clock.c](examples/c/clock.c) counts tenths of a second in its handler,
from `-I:9259`, a tenth of a second at 740 kHz, while `main` sleeps in `HLT`
and prints each second:

```sh
python3 cc4.py --4040 examples/c/clock.c
./ntv4004 -4 -I:9259 -s:740000 -o examples/c/clock.hex
```

## Examples

| Example | What it does | Instruction cycles | 740 kHz 4004 |
| --- | --- | ---: | ---: |
| [hello](examples/hello.asm) | prints a message from a ROM table with `FIN` | 319 | 3.4 ms |
| [echo](examples/echo.asm) | copies input to output in uppercase until a period | depends on input | |
| [fib](examples/fib.asm) | prints 70 Fibonacci numbers with 16-digit BCD arithmetic in RAM (`ADM`, `DAA`) | 31,710 | 0.34 s |
| [sieve](examples/sieve.asm) | the BYTE sieve, 10 passes over 8,191 flags: `1899 primes.` | 4,220,640 | 45.6 s |
| [e](examples/e.asm) | 192 digits of e from the factorial-series spigot, then `done.` | 2,458,025 | 26.6 s |
| [ttt](examples/ttt.asm) | alpha-beta tic-tac-toe after first moves 0, 1 and 4: `moves: 6493` | 838,584 | 9.07 s |

```sh
echo "Hello, world." | ./ntv4004 examples/echo.hex
```

sieve, e and ttt are ports of the benchmarks in
[ntv8008](https://github.com/davidly/ntv8008) and
[cpm_compilers](https://github.com/davidly/cpm_compilers), and print exactly
what those do. The 500 kHz 8008 takes 50.9, 19.0 and 15.4 seconds for them; at 740 kHz the
4004 takes 45.6, 26.6 and 9.07.
The 4004 is slower where it needs more than 4 bits at a time and faster
where nibbles suffice:

* **sieve** stores the 8,192 flags as bits, four to a 4002 RAM character,
  using all eight banks. It keeps each index as its bank, character and bit,
  with the bit times 4 in a nibble so additions carry from field to field.
  The scan rotates each character's four flags out through the carry, and
  skips a character with none set after one test. A flag's bit fixes the
  prime's bit field and the carries into its character, so each bit has its
  own entry to compute the prime and its first multiple. With no AND
  instruction, a `FIN` table clears bits; its entries sit 40H apart so the
  marking loops fit between them, as `FIN` reads its own page. The marking
  loops keep the multiple's bit field in `FIN`'s index register and need no
  `CLC`, since every way into them has the carry clear. Specialized loops for
  primes below 64 and below 1024 update upper address fields and bank
  selection only when a carry requires it. The prime count is binary, its
  low nibble in a register, and is converted to decimal once. The original
  ten-pass marking order, beginning at `I+P`, is preserved. This reduces
  7,157,483 cycles to **4,220,640** (41.0% fewer), with ROM footprint
  increasing from 590 to 695 bytes.
* **e** keeps each 8-bit array element in two banks at the same character
  address, ordering its accesses so each step switches banks twice. For
  divisors of at least two, the spigot's quotient is at most nine, so the
  division is ten unrolled subtractions; each adds the divisor's one's
  complement with the carry in, so no `CLC` is needed, and each failure
  exit already knows its quotient. The complement is kept as the divisor
  counts down, rather than recomputed. Division by one only sets A(1) to
  zero, so it is done after the loop, as is the initial output of 27.
  Multiplication by ten looks up each nibble in a shared 16-byte ROM table
  and combines the results, inline in the loop. These changes reduce the
  benchmark from 10,285,867 to **2,458,025 cycles** (**4.18× faster**, 76.1%
  fewer cycles), with ROM footprint growing from 316 to 475 bytes. All 192
  digits and the `done.` output are unchanged; the image also matches
  Intel's MAC4 and runs identically in INTERP/4.
* **ttt** keeps one frame per search depth in the four status characters of
  a RAM register, since the 4004's stack has only three levels, and every
  score fits in a nibble. The board sits in RAM characters 7 to 15, so the
  move register is the board address and `ISZ` both steps to the next cell
  and ends the search after the last. Its binary node counter keeps the low
  two nibbles in spare registers and converts to decimal once, when
  printing. Direct win checks for each possible last move, reached through a
  jump table, replace the pair-table loop, and jump straight back into the
  search. Piece selection uses depth parity without branching, and placing a
  piece falls into the child node. Ascending move order, the three draws,
  and all **6493 nodes** are preserved. Runtime falls from 1,185,782 to
  **838,584 cycles** (29.3% fewer). ROM footprint grows from 682 to 1196
  bytes, within the original 4004's 4096-byte ROM.

Writing 4004 code: `SUB` and `SBM` subtract one more when the carry is 1,
yet leave the carry 1 when there was no borrow, so complement it (`CMC`)
between the nibbles of a longer subtraction.

## Tests

```sh
./test.sh        # Windows: test.bat
```

* `tests/cpu.py` checks the instruction definitions above, the page
  boundaries, both stacks, the 4040 instructions and ROM banks, RAM banks,
  the console and the examples. Direct tests of e's arithmetic helpers cover
  divisors 2–199 (division by one is not a division), quotient/remainder
  boundaries, all 256 multiply inputs, and carry propagation within the
  spigot's range. Sieve tests check every RAM flag after one, two and ten
  passes against independent prime counts. TTT tests cover the three root
  scores, board restoration, binary-counter carries, decimal formatting, and
  over 2000 last-move win cases with register preservation checks.
  It needs only ntv4004 and Python.
* `tests/cc.py` compiles and runs 60 seeded random C programs, with every
  operator, assignment, branch and loop, and checks their output against a
  Python model of 16-bit C. It also runs programs for functions, recursion,
  arrays, the library and the preprocessor, and the C examples, including maze
  connectivity and solution checks across several seeds. Life tests check
  displayed frames against an independent model, partial redraws, and controls.
* `tests/basic.py` checks the native interpreter, generated ROM, storage limits,
  integer arithmetic, array bounds, input, printing, the 192-digit e program,
  and the full ten-pass sieve plus segment-boundary variants. Mastermind tests
  compare repeated-digit scoring against independent frequency counts and
  exercise invalid guesses followed by a successful game.
* `tests/asm.py` and `tests/interp.py` compare asm4.py with Intel's MAC4 and
  ntv4004 with Intel's INTERP/4 and INTERP/40 on 300 random programs and the
  examples, requiring identical registers, RAM, port writes and cycle counts.
  They include the compiler's output and the small BASIC examples (hello,
  count, Fibonacci, squares, input and Mastermind), checking BASIC output and cycle counts
  against ntv4004.
  They skip without the images; see [intel/README.md](intel/README.md).
