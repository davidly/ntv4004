/* A 5x5 perfect maze, generated and solved by iterative depth-first search.
   Passage bits are north/east/south/west. The stack holds cell numbers;
   no recursion or dynamically allocated storage is needed. */
#include <stdio.h>
#define SIDE 5
#define CELLS 25
#define SEED 37

#ifdef __CC4__
#define nibble __nibble
#else
#define nibble unsigned char
#endif

nibble passage[CELLS];
_Bool visited[CELLS], path[CELLS];
unsigned char stack[CELLS], seed;

unsigned char neighbor(unsigned char cell, unsigned char direction)
{
    if (direction == 0 && cell >= SIDE) return cell-SIDE;
    if (direction == 1 && cell%SIDE != SIDE-1) return cell+1;
    if (direction == 2 && cell < CELLS-SIDE) return cell+SIDE;
    if (direction == 3 && cell%SIDE != 0) return cell-1;
    return 255;
}

void walk(_Bool generating)
{
    unsigned char depth, cell, next, direction, tries, i;
    depth = 0;
    stack[0] = 0;
    for (i = 0; i < CELLS; i++) visited[i] = 0;
    visited[0] = 1;
    while (1) {
        cell = stack[depth];
        if (!generating && cell == CELLS-1) break;
        direction = 0;
        if (generating) {
            /* Eight-bit LCG: assignment to char wraps modulo 256. */
            seed = seed*5+1;
            direction = seed >> 6;
        }
        for (tries = 0; tries < 4; tries++) {
            next = neighbor(cell, direction);
            if (next < CELLS && !visited[next] &&
                (generating || (passage[cell] & (1 << direction)))) {
                if (generating) {
                    passage[cell] |= 1 << direction;
                    passage[next] |= 1 << ((direction+2)&3);
                }
                stack[++depth] = next;
                visited[next] = 1;
                break;
            }
            direction = (direction+1)&3;
        }
        if (tries == 4) {
            if (depth == 0) break;
            depth--;
        }
    }
    if (!generating)
        for (i = 0; i <= depth; i++) path[stack[i]] = 1;
}

void show(_Bool solved)
{
    unsigned char row, col, cell;
    puts("# #########");
    for (row = 0; row < SIDE; row++) {
        putchar('#');
        for (col = 0; col < SIDE; col++) {
            cell = row*SIDE+col;
            putchar(solved && path[cell] ? '.' : ' ');
            putchar(passage[cell]&2 ? ' ' : '#');
        }
        putchar('\n');
        if (row < SIDE-1) {
            putchar('#');
            for (col = 0; col < SIDE; col++) {
                cell = row*SIDE+col;
                putchar(passage[cell]&4 ? ' ' : '#');
                putchar('#');
            }
            putchar('\n');
        }
    }
    puts("######### #");
}

int main()
{
    seed = SEED;
    walk(1);
    puts("MAZE");
    show(0);
    walk(0);
    puts("SOLUTION");
    show(1);
    return 0;
}
