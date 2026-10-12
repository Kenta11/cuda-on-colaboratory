#include "measure.h"

#include <stdio.h>
#include <stdlib.h>

#define N 1000000

__global__ void add(const int *a, const int *b, int *c) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) {
        c[tid] = a[tid] + b[tid];
    }
}

int main (void) {
    double start, elapsed;
    int *a, *b, *c;
    int *dev_a, *dev_b, *dev_c;

    a = (int*)malloc(sizeof(int) * N);
    b = (int*)malloc(sizeof(int) * N);
    c = (int*)malloc(sizeof(int) * N);

    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_b, N * sizeof(int));
    cudaMalloc((void**)&dev_c, N * sizeof(int));

    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 2;
    }

    start = now_ms();
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice);
    add<<<(N + 255) / 256, 256>>>(dev_a, dev_b, dev_c);
    cudaMemcpy(c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost);
    elapsed = now_ms() - start;

    printf("add: %.3f ms\n", elapsed);
    // for (int i = 0; i < N; i++) {
    //     printf("%d + %d = %d\n", a[i], b[i], c[i]);
    // }

    free(a);
    free(b);
    free(c);

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    return 0;
}
