#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdarg.h>
#include "xparameters.h"
#include "xiic_l.h"


#define IIC_DEV_ADDR 0x00

off_t base_offset = 0x00800000;  // 基地址的偏移量
size_t mapping_size = 64 * 1024; // 映射的大小，64K

int main(void) {
    int fd;
    void *mapped_base;
	UINTPTR base_address;
	u8 recdata[16];

    // 打开设备文件
    fd = open("/dev/xdma0_c2h_0", O_RDWR | O_SYNC);
    if (fd == -1) {
        perror("Failed to open device");
        return -1;
    }

    // 映射设备文件到内存
	mapped_base = mmap(NULL, mapping_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base_offset);
    if (mapped_base == MAP_FAILED) {
        perror("Failed to map memory");
        close(fd); 
        return -1;
    }

    // 将映射的地址转换为指定类型的指针
    base_address = (UINTPTR)mapped_base;

    // 使用 base_address 进行操作
	XIic_Recv(base_address , IIC_DEV_ADDR , recdata, 1, XIIC_STOP);


	for(int i = 0; i < 16; i++)
		printf("recdata[%d]=%x\n", i , recdata[i]);

    // 解除内存映射并关闭文件
    munmap(mapped_base, sizeof(uint32_t));
    close(fd);

    return 0;
}

