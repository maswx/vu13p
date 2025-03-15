#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

#define BAR_SIZE 1024/2  // 固定读取1024字节

int main(int argc, char *argv[]) {
    int fd;
    void *map_base;
    off_t offset;
    
    // 检查命令行参数
    if (argc != 2) {
        fprintf(stderr, "用法: %s <偏移地址(十六进制)>\n", argv[0]);
        return 1;
    }
    
    // 解析偏移地址参数
    offset = strtoul(argv[1], NULL, 16);
    
    // 打开设备文件
    fd = open("/dev/xdma0_user", O_RDWR | O_SYNC);
    if (fd == -1) {
        fprintf(stderr, "无法打开设备文件: %s\n", strerror(errno));
        return 1;
    }
    
    // 映射内存区域
    map_base = mmap(NULL, BAR_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x30000);
    if (map_base == MAP_FAILED) {
        fprintf(stderr, "内存映射失败: %s\n", strerror(errno));
        close(fd);
        return 1;
    }
    
    printf("成功映射内存，地址偏移: 0x%lx\n", offset);
    
    // 读取并显示内存内容
    printf("内存内容 (1024 字节):\n");
    for (int i = 0; i < BAR_SIZE; i++) {
        if (i % 16 == 0) {
            printf("\n0x%04x: ", i);
        }
        if (i % 4 == 0) {
			printf("%08x ", *((unsigned int*)(map_base + i)));
		}
    }
    printf("\n");
    
    // 清理
    if (munmap(map_base, BAR_SIZE) == -1) {
        fprintf(stderr, "取消内存映射失败: %s\n", strerror(errno));
    }
    
    close(fd);
    return 0;
}

