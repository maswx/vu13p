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

#define BRAM_ADDR 0x20000
#define BRAM_DEV "/dev/xdma0_user"

int main() {
    int fd = open(BRAM_DEV, O_RDWR);
	int i;
	uint32_t val;
	size_t mapsize = 4*1024;

    uintptr_t  *bram_ptr = mmap(NULL, mapsize , PROT_READ | PROT_WRITE, MAP_SHARED, fd, BRAM_ADDR);

    for(i = 0; i < 100; i++ ) 
		*((volatile uint32_t *)(bram_ptr + i)) = i;

    for(i = 0; i < 100; i++ ) 
	{
		val = *((volatile uint32_t *)(bram_ptr + i));
		if(val != i)
			printf("error: check addr 0x%016lx[%02d] fail : readbak=%08x ", (unsigned long )bram_ptr , i , val);
	}



    munmap(bram_ptr, mapsize);
    close(fd);

    return 0;
}
