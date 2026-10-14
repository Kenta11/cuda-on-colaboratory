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

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define DIM 1024
#define FRAMES 44

void kernel(unsigned char *ptr, int ticks, int x, int y, int offset) {
    float fx = x - DIM/2;
    float fy = y - DIM/2;
    float d = sqrtf(fx * fx + fy * fy);
    unsigned char grey = (unsigned char)(128.0f + 127.0f *
                                         cos(d/10.0f - ticks/7.0f) /
                                         (d/10.0f + 1.0f));
    ptr[offset*4 + 0] = grey;
    ptr[offset*4 + 1] = grey;
    ptr[offset*4 + 2] = grey;
    ptr[offset*4 + 3] = 255;
}

int main(void) {
    unsigned char *bitmap;

    bitmap = (unsigned char *)malloc(DIM * DIM * 4);

    double elapsed = 0.0;
    for (int ticks = 0; ticks < FRAMES; ticks++) {
        double start = now_ms();
        for (int y = 0; y < DIM; y++) {
            for (int x = 0; x < DIM; x++) {
                int offset = x + y * DIM;
                kernel(bitmap, ticks, x, y, offset);
            }
        }
        elapsed += now_ms() - start;

        char name[32];
        snprintf(name, sizeof(name), "frame_%03d.ppm", ticks);
        write_ppm(name, bitmap, DIM, DIM, 4);
    }

    printf("ripple_cpu: %.3f ms/frame\n", elapsed / FRAMES);

    free(bitmap);

    return 0;
}
