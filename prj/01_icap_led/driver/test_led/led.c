//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月18日 星期六 23时35分15秒
//========================================================================


#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>

#define GPIO_ADDR 0x20000
#define GPIO_DEV "/dev/xdma0_user"

int main() {
    int gpio_fd = open(GPIO_DEV, O_RDWR);
	size_t mapsize = 4*1024;

    uintptr_t* gpio_ptr = mmap(NULL, mapsize , PROT_READ | PROT_WRITE, MAP_SHARED, gpio_fd, GPIO_ADDR);

    for(int i = 0; i < 100; i++ ) 
	{
        *gpio_ptr = 0;
        usleep(500 * 1000);
        *gpio_ptr = 1;
        usleep(500 * 1000);
    }

    munmap(gpio_ptr, mapsize);
    close(gpio_fd);

    return 0;
}
