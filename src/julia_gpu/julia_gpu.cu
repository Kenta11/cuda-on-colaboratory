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

#define DIM 1000

struct cuComplex {
    float r;
    float i;

    __device__ cuComplex(float a, float b) : r(a), i(b) {}
    __device__ float magnitude2(void) {
        return r * r + i * i;
    }
    __device__ cuComplex operator*(const cuComplex& a) {
        return cuComplex(r*a.r - i*a.i, i*a.r + r*a.i);
    }
    __device__ cuComplex operator+(const cuComplex& a) {
        return cuComplex(r+a.r, i+a.i);
    }
};

__device__ int julia(int x, int y) {
    const float scale = 1.5;
    float jx = scale * (float)(DIM/2 - x)/(DIM/2);
    float jy = scale * (float)(DIM/2 - y)/(DIM/2);

    cuComplex c(-0.8, 0.156);
    cuComplex a(jx, jy);

    for (int i = 0; i < 200; i++) {
        a = a * a + c;
        if (a.magnitude2() > 1000) {
            return 0;
        }
    }

    return 1;
}

__global__ void kernel(unsigned char *ptr) {
    int x = blockIdx.x;
    int y = blockIdx.y;
    int offset = x + y * gridDim.x;

    int juliaValue = julia(x, y);
    ptr[offset*4 + 0] = 255 * juliaValue;
    ptr[offset*4 + 1] = 0;
    ptr[offset*4 + 2] = 0;
    ptr[offset*4 + 3] = 255;
}

struct DataBlock {
    unsigned char *dev_bitmap;
};

int main(void) {
    double start, elapsed;
    DataBlock data;
    unsigned char *bitmap;
    unsigned char *dev_bitmap;

    bitmap = (unsigned char *)malloc(sizeof(unsigned char) * DIM * DIM * 4);
    cudaMalloc((void**)&dev_bitmap, DIM * DIM * 4);
    data.dev_bitmap = dev_bitmap;

    start = now_ms();
    dim3 grid(DIM, DIM);
    kernel<<<grid, 1>>>(dev_bitmap);

    cudaMemcpy(bitmap, dev_bitmap, DIM * DIM * 4, cudaMemcpyDeviceToHost);
    elapsed = now_ms() - start;
    
    printf("julia_gpu: %.3f ms\n", elapsed);

    FILE *fp = fopen("julia_gpu.ppm", "wb");
    fprintf(fp, "P6\n%d %d\n255\n", DIM, DIM);
    for (int y = DIM - 1; y >= 0; y--) {
        for (int x = 0; x < DIM; x++) {
            fwrite(&(bitmap[(x + y * DIM) * 4]), 1, 3, fp);
        }
    }
    fclose(fp);

    free(bitmap);
    cudaFree(dev_bitmap);

    return 0;
}
