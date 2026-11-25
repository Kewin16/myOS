// util.c - random helper functions

#include "util.h"

// turn a number into a string, e.g. 42 -> "42"
// str needs to be big enough (12 chars covers any int)
void int_to_str(int n, char *str) {
    int i = 0;
    int negative = n < 0;
    if (negative) n = -n;

    // pull off digits from the right, so they come out backwards
    do {
        str[i++] = n % 10 + '0';
        n /= 10;
    } while (n > 0);

    if (negative) str[i++] = '-';
    str[i] = 0;

    // flip it round the right way
    for (int j = 0, k = i - 1; j < k; j++, k--) {
        char tmp = str[j];
        str[j] = str[k];
        str[k] = tmp;
    }
}
