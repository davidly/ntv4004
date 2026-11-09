/*  sieve.c */

/* Eratosthenes Sieve Prime Number Program in C from Byte Jan 1983
   to compare the speed. */

/* For the 4004: 8,191 char flags would need 16,382 RAM characters, eight
   times what 4002s provide, so the flags are a _Bool array, which cc4.py
   packs four to a character. */

#include <stdio.h>

#define TRUE 1
#define FALSE 0
#define SIZE 8190

_Bool flags[SIZE+1];

main()
        {
        int i,k;
        int prime,count,iter;

        for (iter = 1; iter <= 10; iter++) {    /* do program 10 times */
                count = 0;                      /* initialize prime counter */
                for (i = 0; i <= SIZE; i++)     /* set all flags true */
                        flags[i] = TRUE;
                for (i = 0; i <= SIZE; i++) {
                        if (flags[i]) {         /* found a prime */
                                prime = i + i + 3;      /* twice index + 3 */
                                for (k = i + prime; k <= SIZE; k += prime)
                                        flags[k] = FALSE;       /* kill all multiples */
                                count++;                /* primes found */
                                }
                        }
                }
        printf("%d primes.\n",count);           /*primes found in 10th pass */
        return 0;
        }
