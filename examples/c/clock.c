/* clock.c: a 4040 clock driven by a timer interrupt. ntv4004's -I:9259
   requests an interrupt every 9,259 instruction cycles, a tenth of a second
   at 740 kHz; the handler counts tenths and seconds, and main sleeps in HLT
   between interrupts, printing each second and blinking a lamp:

       python3 cc4.py --4040 examples/c/clock.c
       ./ntv4004 -4 -I:9259 -s:740000 -o examples/c/clock.hex
*/

#include <stdio.h>

#define SECONDS 10

volatile __nibble tenths;
volatile int seconds;

/* Called for each interrupt, in the 4040's second register bank. */
__interrupt void tick(void)
{
    if (++tenths == 10) {
        tenths = 0;
        seconds++;
    }
}

int main()
{
    int now, shown;
    shown = 0;
    __ei();
    while (shown < SECONDS) {
        __halt();               /* sleep until the next interrupt */
        __di();                 /* read all four nibbles of seconds at once */
        now = seconds;
        __ei();
        if (now != shown) {
            shown = now;
            __rom_out(0, shown & 1);    /* a lamp blinks each second */
            printf("%d:%d%d\n", shown / 60, shown % 60 / 10, shown % 10);
        }
    }
    __di();
    puts("done");
    return 0;
}
