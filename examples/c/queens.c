/* queens.c: the eight queens problem by recursive backtracking. Place a
   queen in each row, in a column and on diagonals no other queen holds;
   count every arrangement, and show the first. */

#include <stdio.h>

#define N 8

#ifdef __CC4__
#define small __nibble  /* cc4.py's 4-bit type, four to a 4002 status register */
#else
#define small char
#endif

_Bool column[N], rising[2 * N - 1], falling[2 * N - 1];
small queen[N];
int solutions;

void show()
{
    small row, col;
    for (row = 0; row < N; row++) {
        for (col = 0; col < N; col++)
            putchar(queen[row] == col ? 'Q' : '.');
        putchar('\n');
    }
}

void place(small row)
{
    small col;
    if (row == N) {
        if (++solutions == 1)
            show();
        return;
    }
    for (col = 0; col < N; col++)
        if (!column[col] && !rising[row + col] && !falling[row - col + N - 1]) {
            queen[row] = col;
            column[col] = rising[row + col] = falling[row - col + N - 1] = 1;
            place(row + 1);
            column[col] = rising[row + col] = falling[row - col + N - 1] = 0;
        }
}

int main()
{
    place(0);
    printf("%d solutions\n", solutions);
    return 0;
}
