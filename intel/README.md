# Intel's MAC4 assemblers and INTERP/4 simulators

## Optional local-image component — setup first

Intel's original 4004 and 4040 development tools ran on Tymshare's PDP-10
time-sharing service: the MAC4 and MAC40 macro cross-assemblers and the
INTERP/4 and INTERP/40 instruction-set simulators. They are 1970s PDP-10
Fortran and run here on the PDP-10 runner from ntvcm's PL/M-80 work. The
executables are not included or automatically downloaded. Redistribution
permission for these historical Intel/Tymshare images has not been
established. Pins and provenance are in [upstream/NOTICE.txt](upstream/NOTICE.txt).

If you have the right to use them, recover the images from a lawfully obtained
copy of Tymshare tape 169278, archived at
[VTDA](https://vtda.org/bits/software/DEC/PDP-10/tymshare/169278.tape.bz2)
(about 379 MiB):

```sh
python3 intel/recover.py /path/to/169278.tape.bz2
```

Recovery verifies the tape's SHA-256, extracts `MAC4.SAV`, `MAC40.SAV`,
`MAC40E.SAV`, `INT4.SAV` and `INT40.SAV` from its `(UPL)` directory, verifies
each, and writes them to `intel/upstream/`. `m.sh` (Windows: `m.bat`) builds the
native PDP-10 runner, `intel/pdp10`; without it the Python runner is about 100
times slower.

| Image | Banner | Notes |
| --- | --- | --- |
| `MAC4.SAV` | `4004 MACRO ASSEMBLER, VER 2.5` | rejects the 4040 instructions |
| `MAC40.SAV` | `4040 MACRO ASSEMBLER, VER 2.5` | the same language plus the 4040 instructions |
| `MAC40E.SAV` | `4040 MACRO ASSEMBLER, VER 2.4` | a larger symbol table; built for the KI10, which the runner emulates |
| `INT4.SAV` | `INTERP/4  VERS 1.1` | 4004 simulator |
| `INT40.SAV` | `INTERP/40 VERS 1.1` | 4040 simulator |

The tape's `MAC4.EXA` is a 1974 session that assembles a small AND routine
with MAC4 2.2; MAC4 2.5 produces the same HEX. `MAC4.INF` and `MAC40.INF` are
the release notes for versions 2.3 to 2.5.

## Assemble

```sh
python3 intel/mac4.py examples/hello.asm -o hello.hex
python3 intel/mac4.py --4040 prog.asm      # MAC40
python3 intel/mac4.py --expanded prog.asm  # MAC40E
```

`mac4.py` writes Intel HEX and a `.map` of the symbols for ntv4004's
instruction trace. The project's own [asm4.py](../asm4.py) assembles the same
language without these images, and `tests/asm.py` checks that both produce
the same bytes. MAC4's source rules, which both check:

* Code uses MAC4's alphabet, space through `Z`; lowercase must be numeric.
  Code must fit in 72 columns. Comments start with `;`.
* Symbols keep 5 significant characters, so two names that share them are
  rejected. Mnemonics such as `SUB` cannot be labels.
* `FIM`, `SRC`, `FIN` and `JIN` name a register pair by its even register,
  `0` to `14`: `FIM 2,11` loads R2 and R3. MAC4 silently assembles an odd
  register as a different instruction (`FIM 7` is `SRC 6`).
* `JCN` and `ISZ` targets must be on the page of the next instruction; MAC4
  flags others with `V`. Conditions are numbers: 4 jumps if the accumulator is
  zero, 0CH if it is not, 2 if the carry is 1, 0AH if it is 0.
* `DB` takes bytes and strings, `DS` reserves bytes, and expressions use
  `$`, character constants and `* / MOD SHL SHR + - NOT AND OR XOR`.

## Run in INTERP/4

```sh
python3 intel/interp4.py -p examples/hello.asm       # assemble with MAC4, run in INTERP/4
python3 intel/interp4.py -p examples/fib.hex         # or run a HEX image
python3 intel/interp4.py --4040 prog.asm             # MAC40 and INTERP/40
python3 intel/interp4.py -l input.txt examples/echo.hex
```

`interp4.py` loads the program, sets a breakpoint at its single `JUN` to
itself, runs it, and converts INTERP's port log back into console output
using ntv4004's convention (ROM port 15, two nibbles per character). `-p`
reports INTERP's instruction-cycle count; `--transcript` prints the whole
session. Every result matches ntv4004 exactly, including the cycle counts:

| Example | Output | Instruction cycles |
| --- | --- | ---: |
| hello | `Hello from the Intel 4004!` | 319 |
| echo | its input, in uppercase, up to a period | 353 for `Hello, world.` |
| fib | the first 70 Fibonacci numbers | 31,710 |
| sieve | `1899 primes.` | 5,655,553 |
| e | 192 digits of e, then `done.` | 3,458,421 |
| ttt | `moves: 6493`, `iterations: 1` | 1,020,584 |
| c/hello, compiled by cc4.py | `Hello from C on the Intel 4004!` | 1,775 |
| c/ttt, compiled by cc4.py | `move count:      6493`, `iteration count: 1` | 11,951,902 |
| c/queens, compiled by cc4.py | the first solution, then `92 solutions` | 5,538,133 |
| c/hanoi, compiled by cc4.py | the moves for 3 discs, then the counts for 3 and 10 | 1,167,360 |

### INTERP's commands and object format

No INTERP/4 manual is on the tape, so these were found by experiment and by
reading the simulator's code. Each command ends with a period:
`LOAD`, `REFER`, `BREAK`, `TRACE`, `GO`, `RUN`, `CONV`, `PUNCH`, `RESET`, `SET`,
`TIME`, `CYCLE`, `DISPLAY`, `END`, `ALTER`, `MODIFY`, `BASE` and `INTERRUPT`,
with `TO`, `SYMBOLS`, `CPU`, `MEMORY`, `PORT` and `RAM`. Working examples:
`BASE HEX.`, `DISPLAY CPU.`, `DISPLAY MEMORY 0 TO 1FH.`, `DISPLAY RAM 0 TO 0FH.`,
`DISPLAY SYMBOLS.`, `TRACE 0 TO 0FFH.`, `BREAK DONE.`, `CYCLE 1000.`,
`SET R0 = 5.`, `SET PC = 10H.`, `GO.` and `TIME.`.

* `LOAD 0 3 TO 3.` loads MAC4's object from Fortran unit 3, `FOR21.DAT`.
  INTERP reads only the BNPF form with the symbol table first, which MAC4
  writes with `$T=1 $B=0`: the `TO` unit is read for the symbol table and the
  other for BNPF. Units 2 to 5 are `FOR20.DAT` to `FOR23.DAT`. A plain `LOAD 0
  3.` only redirects command input to that file. `mac4.py` writes this object
  from any memory image (`bnpf_object`), so HEX files load too. The loader
  rejects addresses above 0FFFH, so INTERP/40 cannot load code for its second
  ROM bank.
* `BREAK` takes one address. INTERP stops before executing it.
* Numbers follow `BASE`. In hexadecimal, a number must start with a digit
  (`0CFH`, not `CFH`), or INTERP reads it as a name.
* `TIME.` prints instruction cycles and microseconds at 10.8 µs per cycle.
* Each port write is printed as it happens, `PORT FH = 4H`: ROM ports are
  0 to 0FH, by the chip number in SRC's high nibble, and RAM output ports are
  1FH + 4 × bank + chip. An `RDR` prompts `PORT FH...` and reads the value as
  the next command line, so `interp4.py` supplies the console input there.
  The order of console and status reads depends on the program, so it reruns
  the session with corrected answers until they agree with INTERP's prompts.
* `DISPLAY RAM` shows the bank selected by the last `DCL`.

### Where INTERP differs from the MCS-40 manual

ntv4004 follows the MCS-40 User's Manual (November 1974); these differences
are why `tests/interp.py` avoids a few cases:

* INTERP/4 simulates the 4040's seven return levels, not the 4004's three:
  a fourth nested `JMS` returns correctly in INTERP/4, while a 4004 loses its
  deepest return address. INTERP/4 also executes the 4040 instructions.
* INTERP maps the `DCL` values 0, 1 and 2 to banks 0, 1 and 2, but 3 to 2 and
  4 to 7 to 3 to 6; the manual gives eight distinct banks.
* After `BBL`, INTERP leaves the vacated stack level holding the `BBL`'s own
  address; ntv4004 leaves the address after it, as the incremented program
  counter would. Only a program that returns more often than it calls can see
  the difference.
* `HLT` makes INTERP/40 execute `NOP` continuously, as the hardware does;
  ntv4004 ends the program there.

## Tests

`tests/asm.py` compares asm4.py with MAC4 and MAC40 on every instruction and
operand, the directives and the examples. `tests/interp.py` runs 150 seeded
random programs each in INTERP/4 and INTERP/40 and requires ntv4004 to finish
with the same accumulator, carry, index registers (both 4040 banks), SRC,
command lines, stack, RAM, port writes and instruction cycles, and it runs the
examples and a status-polling program in both simulators. The small BASIC
examples (hello, count, Fibonacci, squares, input and Mastermind) also run to completion in
INTERP/4, with their expected output and ntv4004 cycle counts checked. The C maze
generator/solver is checked against ntv4004 as well, along with a four-generation
Life animation whose VT100 output is replayed and checked against independent
Life rules. Both skip when the
images are missing.

## Runner notes

The runner is ntvcm's `plm80/pdp10.py` and `pdp10.cxx` with these images'
checksums. It is a Fortran-program runner, not a general PDP-10 or TYMCOM-X
emulator; see the comments there. Fortran reads past the end of a file are
not supported, so `interp4.py` always ends INTERP's input with `$E`.
