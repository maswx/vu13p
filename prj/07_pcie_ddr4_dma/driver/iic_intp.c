#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>


int main() {
    // 打开设备
    int fd = open("/dev/xdma0_user", O_RDWR);
    if (fd < 0) {
        perror("open device");
        exit(1);
    }

    // 将0x00800000做内存映射
    void *mem = mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x00800000);
    if (mem == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }

    // 复位掉整个IIC
    *(volatile uint32_t *)(mem + 0x40) = 0xa;
    //复位掉 IIC  FIFO
    *(volatile uint32_t *)(mem + 0x100) = 0x2;
    *(volatile uint32_t *)(mem + 0x100) = 0x0;
    //
    // 配置中断条件1:RX FIFO收到2个数据
    *(volatile uint32_t *)(mem + 0x120) = 0x1;

    uint32_t val = *(volatile uint32_t *)(mem + 0x20);
    printf("The value at address 0x20 is 0x%08X\n", val);
    // 解除内存映射
    munmap(mem, 0x1000);

    // 关闭设备
    close(fd);

    return 0;
}
