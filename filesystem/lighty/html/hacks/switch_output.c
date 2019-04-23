#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <linux/fb.h> // Defines FBIOGET_VSCREENINFO, fb_var_screeninfo, etc.
#include <string.h>
#include <unistd.h>


int print_usage(char *prog) {
	return printf("Usage: %s -mode\nWhere mode is [l]cd, [n]tsc, or [p]al\n", prog);
}

int main(int argc, char **argv) {
	int fd;
	struct fb_var_screeninfo fbdata;
	int new_width, new_height, new_vheight, new_bpp;

	if(argc < 2)
		return print_usage(argv[0]);

	if(!strcmp(argv[1], "-l")) {
		new_width   = 320;
		new_height  = 240;
		new_vheight = new_height*2;
		new_bpp     = 16;
	}
	else if(!strcmp(argv[1], "-n")) {
		new_width   = 480;
		new_height  = 720;
		new_vheight = new_height;
		new_bpp     = 32;
	}
	else if(!strcmp(argv[1], "-p")) {
		new_width   = 576;
		new_height  = 720;
		new_vheight = new_height;
		new_bpp     = 32;
	}
	else {
		return print_usage(argv[0]);
	}


	fd = open("/dev/fb0", O_RDWR);
	if(fd <= 0) {
		perror("Unable to open framebuffer");
		return 1;
	}

	if(ioctl(fd, FBIOGET_VSCREENINFO, &fbdata)) {
		perror("Unable to call FBIOGET_VSCREENINFO");
		return 1;
	}

	fprintf(stderr, "current x and y res is: %d %d\n",
			fbdata.xres, fbdata.yres);
	fprintf(stderr, "current bits per pixel: %d\n", fbdata.bits_per_pixel);
	fprintf(stderr, "current width and height defined as : %d %d\n",
			fbdata.width, fbdata.height);


	// To reset colospace, we need to specify the individual colors...
	fbdata.xres           = new_width;
	fbdata.yres           = new_height;
	fbdata.width          = new_width;
	fbdata.height         = new_height;
	fbdata.xres_virtual   = new_width;
	fbdata.yres_virtual   = new_vheight;
	fbdata.xoffset        = 0;
	fbdata.yoffset        = 0;
	fbdata.bits_per_pixel = new_bpp;

	if (ioctl(fd, FBIOPUT_VSCREENINFO, &fbdata)!=0) {
		perror("Unable to FBIOPUT_VSCREENINFO");
		return 1;
	}

	close(fd);

	return 0;
}
