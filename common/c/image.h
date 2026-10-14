#ifndef IMAGE_H
#define IMAGE_H

#ifdef __cplusplus
extern "C" {
#endif

int write_ppm(const char *path, const unsigned char *pixels, int width, int height, int channels);

#ifdef __cplusplus
}
#endif

#endif // IMAGE_H
