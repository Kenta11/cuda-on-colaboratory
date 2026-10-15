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

#include "image.h"
#include "measure.h"

#include <complex>

#include <cstdio>
#include <cstdlib>

#define DIM 1000

int julia(int x, int y) {
    const float scale = 1.5;
    float jx = scale * (float)(DIM/2 - x)/(DIM/2);
    float jy = scale * (float)(DIM/2 - y)/(DIM/2);

    std::complex<float> c(-0.8f, 0.156f);
    std::complex<float> a(jx, jy);

    for (int i = 0; i < 200; i++) {
        a = a * a + c;
        if (std::norm(a) > 1000) {
            return 0;
        }
    }

    return 1;
}

void kernel(int x, int y, unsigned char *ptr) {
    int offset = x + y * DIM;

    int juliaValue = julia(x, y);
    ptr[offset*4 + 0] = 255 * juliaValue;
    ptr[offset*4 + 1] = 0;
    ptr[offset*4 + 2] = 0;
    ptr[offset*4 + 3] = 255;
}

int main(void) {
    double start, elapsed;
    unsigned char *bitmap;

    bitmap = (unsigned char *)malloc(sizeof(unsigned char) * DIM * DIM * 4);

    start = now_ms();
    for (int y = 0; y < DIM; y++) {
        for (int x = 0; x < DIM; x++) {
            kernel(x, y, bitmap);
        }
    }
    elapsed = now_ms() - start;
    
    printf("julia_cpu: %.3f ms\n", elapsed);

    write_ppm("julia_cpu.ppm", bitmap, DIM, DIM, 4);

    free(bitmap);

    return 0;
}
