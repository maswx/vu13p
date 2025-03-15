//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2025年03月13日 星期四 15时50分09秒
//========================================================================
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define C2H_DEVICE "/dev/xdma0_c2h_0"  // C2H设备文件路径
#define BUFFER_SIZE 256                 // 读取的数据大小，固定为256字节

int main(int argc, char *argv[])
{
    int fd;
    ssize_t bytes_read;
    uint8_t buffer[BUFFER_SIZE];
    uint64_t start_address = 0;

    // 检查命令行参数
    if (argc != 2) {
        printf("用法: %s <起始地址(十六进制)>\n", argv[0]);
        return -1;
    }

    // 解析起始地址参数
    if (sscanf(argv[1], "0x%lx", &start_address) != 1) {
        printf("错误: 无法解析起始地址 '%s'，请使用十六进制格式 (例如: 0x1000)\n", argv[1]);
        return -1;
    }

    printf("准备从地址 0x%lx 读取 %d 字节的数据\n", start_address, BUFFER_SIZE);

    // 打开C2H设备
    fd = open(C2H_DEVICE, O_RDONLY);
    if (fd < 0) {
        perror("无法打开C2H设备");
        return -1;
    }

    // 设置文件偏移量为起始地址
    if (lseek(fd, start_address, SEEK_SET) == (off_t)-1) {
        perror("设置地址偏移量失败");
        close(fd);
        return -1;
    }

    // 从C2H通道读取数据
    memset(buffer, 0, BUFFER_SIZE);
    bytes_read = read(fd, buffer, BUFFER_SIZE);

    if (bytes_read < 0) {
        perror("读取数据失败");
        close(fd);
        return -1;
    }

    printf("成功读取 %ld 字节数据\n", bytes_read);

    // 以十六进制格式打印数据
    printf("数据内容 (十六进制):\n");
    for (int i = 0; i < bytes_read; i++) {
        printf("%02X ", buffer[i]);
        if ((i + 1) % 16 == 0) {
            printf("\n");
        }
    }
    printf("\n");

    // 关闭设备
    close(fd);
    return 0;
}

