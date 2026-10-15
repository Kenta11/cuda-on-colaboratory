#include "image.h"

#include <stdio.h>

int write_ppm(const char *path, const unsigned char *pixels, int width, int height, int channels) {
    FILE *fp = fopen(path, "wb");
    if (fp == NULL) {
        return -1;
    }
    fprintf(fp, "P6\n%d %d\n255\n", width, height);
    for (int y = height - 1; y >= 0; y--) {
        for (int x = 0; x < width; x++) {
            fwrite(&pixels[((long)y * width + x) * channels], 1, 3, fp);
        }
    }
    fclose(fp);
    return 0;
}
