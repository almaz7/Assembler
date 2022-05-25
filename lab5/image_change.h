#ifndef IMAGE_CHANGE_H
#define IMAGE_CHANGE_H

unsigned char* read_image(char const* filename, int* x, int* y, int* channels); //NULL if error
int make_grey(int x, int y, int channels, unsigned char* data);
int make_grey_asm(int x, int y, int channels, unsigned char* data);
int write_image(char const* filename, int x, int y, int channels, unsigned char* data); // 0 on failure 

#endif
