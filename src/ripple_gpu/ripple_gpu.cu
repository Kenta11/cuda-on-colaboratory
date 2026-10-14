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

#include <stdio.h>
#include <stdlib.h>

#define DIM 1024
#define FRAMES 44

__global__ void kernel(unsigned char *ptr, int ticks) {
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;

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
    unsigned char *dev_bitmap;

    bitmap = (unsigned char *)malloc(DIM * DIM * 4);
    cudaMalloc((void**)&dev_bitmap, DIM * DIM * 4);

    dim3 blocks(DIM / 16, DIM / 16);
    dim3 threads(16, 16);

    double elapsed = 0.0;
    for (int ticks = 0; ticks < FRAMES; ticks++) {
        double start = now_ms();
        kernel<<<blocks, threads>>>(dev_bitmap, ticks);
        cudaMemcpy(bitmap, dev_bitmap, DIM * DIM * 4, cudaMemcpyDeviceToHost);
        elapsed += now_ms() - start;

        char name[32];
        snprintf(name, sizeof(name), "frame_%03d.ppm", ticks);
        write_ppm(name, bitmap, DIM, DIM, 4);
    }

    printf("ripple_gpu: %.3f ms/frame\n", elapsed / FRAMES);

    free(bitmap);
    cudaFree(dev_bitmap);

    return 0;
}
