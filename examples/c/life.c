/* Conway's Game of Life, with a fixed dead border and packed _Bool grids.
   VT100 cursor addressing updates only changed cells. Space pauses, n steps,
   r resets, q quits. Ends after GENERATIONS. Use -s to pace the emulator. */
#include <stdio.h>
#define WIDTH 32
#define HEIGHT 16
#define STRIDE (WIDTH+2)
#define CELLS (STRIDE*(HEIGHT+2))
#define GENERATIONS 120
#define PATTERN 0

_Bool current[CELLS], future[CELLS], paused;
unsigned generation, population;

void cursor(unsigned row, unsigned col)
{
    printf("\033[%u;%uH", row, col);
}

void status()
{
    printf("\033[2;1HGeneration %u  Live %u  ", generation, population);
    if (paused) printf("PAUSED");
    else printf("RUNNING");
    printf("\033[K");
}

void initialize()
{
    unsigned i;
    for (i = 0; i < CELLS; i++) {
        current[i] = 0;
        future[i] = 0;
    }
    /* 0 mixes all four patterns; 1 glider, 2 blinker, 3 block, 4 R-pentomino. */
#if PATTERN == 0 || PATTERN == 1
    current[2*STRIDE+3] = 1;
    current[3*STRIDE+4] = 1;
    current[4*STRIDE+2] = 1;
    current[4*STRIDE+3] = 1;
    current[4*STRIDE+4] = 1;
#endif
#if PATTERN == 0 || PATTERN == 2
    current[3*STRIDE+12] = 1;
    current[3*STRIDE+13] = 1;
    current[3*STRIDE+14] = 1;
#endif
#if PATTERN == 0 || PATTERN == 3
    current[3*STRIDE+25] = 1;
    current[3*STRIDE+26] = 1;
    current[4*STRIDE+25] = 1;
    current[4*STRIDE+26] = 1;
#endif
#if PATTERN == 0 || PATTERN == 4
    current[9*STRIDE+16] = 1;
    current[9*STRIDE+17] = 1;
    current[10*STRIDE+15] = 1;
    current[10*STRIDE+16] = 1;
    current[11*STRIDE+16] = 1;
#endif
#if PATTERN == 5
    /* Edge oscillator: births beyond the board are discarded. */
    current[STRIDE+1] = 1;
    current[STRIDE+2] = 1;
    current[STRIDE+3] = 1;
#endif
    generation = 0;
    population = 0;
    for (i = 0; i < CELLS; i++) population += current[i];
}

void horizontal()
{
    unsigned char col;
    putchar('+');
    for (col = 0; col < WIDTH*2; col++) putchar('-');
    putchar('+');
}

void draw()
{
    unsigned char row, col;
    unsigned cell;
    printf("\033[HSpace: pause  n: step  r: reset  q: quit");
    cursor(3, 1);
    horizontal();
    for (row = 0; row < HEIGHT; row++) {
        cursor(row+4, 1);
        putchar('|');
        cell = (row+1)*STRIDE+1;
        for (col = 0; col < WIDTH; col++) {
            if (current[cell++]) printf("[]");
            else printf("  ");
        }
        putchar('|');
    }
    cursor(HEIGHT+4, 1);
    horizontal();
    status();
}

void evolve()
{
    unsigned cell;
    unsigned char row, col, neighbors;
    _Bool adjacent;
    population = 0;
    for (row = 0; row < HEIGHT; row++) {
        cell = (row+1)*STRIDE+1;
        for (col = 0; col < WIDTH; col++) {
            neighbors = current[cell-STRIDE-1]+current[cell-STRIDE]+current[cell-STRIDE+1]
                      + current[cell-1]+current[cell+1]
                      + current[cell+STRIDE-1]+current[cell+STRIDE]+current[cell+STRIDE+1];
            future[cell] = neighbors == 3 || (current[cell] && neighbors == 2);
            population += future[cell];
            cell++;
        }
    }
    for (row = 0; row < HEIGHT; row++) {
        cell = (row+1)*STRIDE+1;
        adjacent = 0;
        for (col = 0; col < WIDTH; col++) {
            if (current[cell] != future[cell]) {
                /* Consecutive changed cells share one cursor movement. */
                if (!adjacent) cursor(row+4, col*2+2);
                if (future[cell]) printf("[]");
                else printf("  ");
                adjacent = 1;
            } else adjacent = 0;
            current[cell] = future[cell];
            cell++;
        }
    }
    generation++;
    status();
}

int main()
{
    _Bool advance;
#ifdef __CC4__
    unsigned char key;
#endif
    initialize();
    printf("\033[2J\033[?25l");
    draw();
    while (generation < GENERATIONS) {
        advance = !paused;
#ifdef __CC4__
        if (__rom_in(14)) {
            key = getchar();
            if (key == 'q' || key == 'Q') break;
            if (key == ' ') {
                paused = !paused;
                advance = !paused;
                status();
            }
            if (key == 'n' || key == 'N') {
                paused = 1;
                advance = 1;
            }
            if (key == 'r' || key == 'R') {
                initialize();
                draw();
                continue;
            }
        }
#endif
        if (advance) evolve();
    }
    cursor(HEIGHT+5, 1);
    printf("\033[?25hDone.\033[K\n");
    return 0;
}
