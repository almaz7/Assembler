#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "image_change.h"

int main(int argc, char** argv) {
	if (argc < 3) {
		printf("There are no input or output filenames!\n");
		return 1;
	}
	char* input = argv[1];
	char* output = argv[2];
	int x; int y; int channels;
	unsigned char* data = read_image(input, &x, &y, &channels);
	if (!data) {
		printf("Error with reading image!\n");
		return 1;
	}
	int st;
	clock_t start = clock();
	st = make_grey(x, y, channels, data);
	clock_t end = clock();
	if (st == 1) {
		printf("Count of channels is not equal to 3!\n");
		return 1;
	} else {
		printf("Time for making image grey = %lf\n", (double)(end - start) / CLOCKS_PER_SEC);
	}
	
	if (write_image(output, x, y, channels, data) == 0) {
		printf("Error with writing image!\n");
		return 1;
	}
	return 0;
}
