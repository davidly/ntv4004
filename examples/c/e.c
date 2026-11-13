/*
#include <string.h>
#include <stdlib.h>
*/
#include <stdio.h>

/* With 200 cells, counters are at most 200 and remainders at most 198.
   The intermediate x is nonnegative and stays below 2000. */
#define DIGITS_TO_FIND 200
main() {
  unsigned char N;
  unsigned x;
  unsigned char a[ DIGITS_TO_FIND ];
  unsigned char n;

  x = 0;
  N = DIGITS_TO_FIND;

  for (n = N - 1; n > 0; --n) {
      a[n] = 1;
  }

  a[1] = 2, a[0] = 0;
  while (N > 9) {
      n = N--;
      while (--n) {
          a[n] = x % n;

          x = 10 * a[n-1] + x/n;
      }
      printf("%u", x);
  }

  printf( "\ndone\n" );

  return 0;
}
