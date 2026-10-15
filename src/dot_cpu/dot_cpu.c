/*
 * Copyright 1993-2010 NVIDIA Corporation.  All rights reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and 
 * proprietary rights in and to this software and related documentation. 
 * Any use, reproduction, disclosure, or distribution of this software 
 * and related documentation without an express license agreement from
 * NVIDIA Corporation is strictly prohibited.
 *
 * Please refer to the applicable NVIDIA end user license agreement (EULA) 
 * associated with this source code for terms and conditions that govern 
 * your use of this NVIDIA software.
 * 
 */

#include "measure.h"

#include <stdio.h>
#include <stdlib.h>

#define N (33 * 1024)

float dot(const float *a, const float *b) {
    float temp = 0;
    for (int i = 0; i < N; i++) {
        temp += a[i] * b[i];
    }
    return temp;
}

int main(void) {
    double start, elapsed;
    float *a, *b, c;

    a = (float *)malloc(N * sizeof(float));
    b = (float *)malloc(N * sizeof(float));

    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 2;
    }

    start = now_ms();
    c = dot(a, b);
    elapsed = now_ms() - start;

    printf("dot_cpu: %.3f ms\n", elapsed);

    #define sum_squares(x) (x*(x+1)*(2*x+1)/6)
    printf("Does CPU value %.6g = %.6g?\n", c, 2 * sum_squares((float)(N - 1)));

    free(a);
    free(b);

    return 0;
}
