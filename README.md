# ntv4004

A portable Intel 4004 and 4040 emulator, a MAC4-compatible assembler, and
runnable examples, with Intel's own 1970s assemblers and simulator as
optional local references. The emulator implements both instruction sets,
4K (4004) or 8K (4040) of ROM, 4002 RAM, a console on a ROM I/O port,
instruction tracing and instruction-cycle accounting.

This builds and runs on Windows, macOS and Linux (tested on Ubuntu and
Windows).

Project code is **BSD-3-Clause**; see [LICENSE](LICENSE). Intel's historical
tools in [intel/](intel/README.md) are optional local inputs and are not part
of this repository.

## Contents

| Path | Contents |
| --- | --- |
| `i4004.cxx`, `i4004.hxx` | 4004 and 4040 CPU: instruction decoding, carry, 4002 RAM and status characters, ROM banks, the stack, and cycle accounting. |
| `ntv4004.cxx`, `trace.hxx` | Command-line host: Intel HEX loader, console ports, speed limiting, and debug and instruction tracing. |
| `asm4.py` | Assembler for Intel's MAC4 and MAC40 language, checked against them byte for byte. |
| `examples/` | hello, echo and fib, with their HEX and symbol maps. |
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
| `-t`, `-i` | trace to `ntv4004.log`; `-i` adds every instruction, labeled from an adjacent `.map` (or `-m:file`) |

A program ends successfully with `HLT` (4040) or a `JUN` to its own address,
the usual way to stop a 4004. Ctrl-C or Ctrl-Q also exits.

### The console

The 4004 has no console instructions, so ntv4004 uses its I/O ports: `SRC`
selects a ROM chip's port by the high nibble of a register pair, and `WRR` and
`RDR` write and read it four bits at a time.

* ROM port 15 (`FIM 14,0F0H` then `SRC 14`) is the console. Write a character
  with two `WRR`s, high nibble first; read one with two `RDR`s, high nibble
  first. The first read waits for a key.
* ROM port 14 reads 1 when a key is ready and 0 otherwise, without waiting.
* LF input becomes CR, and CR output becomes LF. Characters are 7-bit.

Other ROM ports read 0, and writes to them and to the 4002 output ports
(`WMP`) appear in the `-t` log. The `TEST` pin is 0.

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
  `AN7`, `LCR`, `EIN`, `DIN`, `BBS` and `RPM`. No interrupt source or 4289
  program memory is attached, so `RPM` reads 0.

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

## Examples

| Example | What it does | Instruction cycles |
| --- | --- | ---: |
| [hello](examples/hello.asm) | prints a message from a ROM table with `FIN` | 319 |
| [echo](examples/echo.asm) | copies input to output in uppercase until a period | depends on input |
| [fib](examples/fib.asm) | prints 70 Fibonacci numbers with 16-digit BCD arithmetic in RAM (`ADM`, `DAA`) | 31,710 (0.34 s on a 4004) |

```sh
echo "Hello, world." | ./ntv4004 examples/echo.hex
```

## Tests

```sh
./test.sh        # Windows: test.bat
```

* `tests/cpu.py` checks the instruction definitions above, the page
  boundaries, both stacks, the 4040 instructions and ROM banks, RAM banks,
  the console and the examples. It needs only ntv4004 and Python.
* `tests/asm.py` and `tests/interp.py` compare asm4.py with Intel's MAC4 and
  ntv4004 with Intel's INTERP/4 and INTERP/40 on 300 random programs and the
  examples, requiring identical registers, RAM, port writes and cycle counts.
  They skip without the images; see [intel/README.md](intel/README.md).
