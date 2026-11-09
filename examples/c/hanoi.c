/* hanoi.c: the Towers of Hanoi. Move a tower of discs from peg A to peg C,
   one disc at a time and never a larger disc on a smaller: move the discs
   above to the spare peg, move the bottom disc, and move them back on top.
   Show the moves for three discs, then count them for ten. */

#include <stdio.h>

#ifdef __CC4__
#define small __nibble  /* cc4.py's 4-bit type, four to a 4002 status register */
#else
#define small char
#endif

int moves;
_Bool showing;

void hanoi(small discs, small from, small to, small spare)
{
    if (discs == 0)
        return;
    hanoi(discs - 1, from, spare, to);
    moves++;
    if (showing)
        printf("disc %d from %c to %c\n", discs, 'A' + from, 'A' + to);
    hanoi(discs - 1, spare, to, from);
}

int main()
{
    showing = 1;
    hanoi(3, 0, 2, 1);
    printf("3 discs: %d moves\n", moves);
    showing = 0;
    moves = 0;
    hanoi(10, 0, 2, 1);
    printf("10 discs: %d moves\n", moves);
    return 0;
}
