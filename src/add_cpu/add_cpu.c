#include "measure.h"

#include <stdio.h>
#include <stdlib.h>

#define N 100000000

void add(const int *a, const int *b, int *c) {
    int tid = 0;
    while (tid < N) {
        c[tid] = a[tid] + b[tid];
        tid++;
    }
}

int main (void) {
    double start, elapsed;
    int *a, *b, *c;

    a = (int*)malloc(sizeof(int) * N);
    b = (int*)malloc(sizeof(int) * N);
    c = (int*)malloc(sizeof(int) * N);

    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * N;
    }

    start = now_ms();
    add(a, b, c);
    elapsed = now_ms() - start;

    printf("add: %.3f ms\n", elapsed);
    // for (int i = 0; i < N; i++) {
    //     printf("%d + %d = %d\n", a[i], b[i], c[i]);
    // }

    free(a);
    free(b);
    free(c);

    return 0;
}