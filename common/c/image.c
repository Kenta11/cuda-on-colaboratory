#include "image.h"

#include <stdio.h>

int write_ppm(const char *path, const unsigned char *pixels, int width, int height, int channels) {
    FILE *fp = fopen(path, "wb");
    if (fp == NULL) {
        return -1;
    }
    fprintf(fp, "P6\n%d %d\n255\n", width, height);
    for (long i = 0; i < (long)width * height; i++) {
        fwrite(&pixels[i * channels], 1, 3, fp);
    }
    fclose(fp);
    return 0;
}
