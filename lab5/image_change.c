#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

#include <stdlib.h>
#include "image_change.h"

#define max(a,b) a > b ? a : b
#define min(a,b) a < b ? a : b 
unsigned char* read_image(char const* filename, int* x, int* y, int* channels) {
	return stbi_load(filename, x, y, channels, 0); //NULL if error
}

int make_grey(int x, int y, int channels, unsigned char* data) { //x - width, y - height
	// i - lines, j - columns
	if (channels != 3) {
		return 1;
	}
	int index;
	int a, b;
	for (int i = 0; i < y; i++) {
		for (int j = 0; j < x; j++) {
			index = (i*x+j)*channels;
			a = max(max(data[index], data[index+1]), data[index+2]);
			b = min(min(data[index], data[index+1]), data[index+2]);
			/*data[index] = 255 - data[index];
			data[index+1] = 255 - data[index+1];
			data[index+2] = 255 - data[index+2];*/
			a = (a+b)/2;
			data[index] = a;
			data[index+1] = a;
			data[index+2] = a;			
		} 
	}
	return 0;
}

int write_image(char const* filename, int x, int y, int channels, unsigned char* data) {
	
	return stbi_write_bmp(filename, x, y, channels, data); // 0 on failure 
}
