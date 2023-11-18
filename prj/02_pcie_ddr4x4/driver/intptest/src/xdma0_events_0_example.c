//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月18日 星期六 23时35分15秒
//========================================================================
//
//
//
// github Copilot: generate above code : 
// 1. 已知 xdma 的字符设备为 /dev/xdma0_user ,该设备的 0x0地址上挂载了一个 axi gpio IP
// 2. 已知 xdma 的中断 的字符设备为/dev/xdma0_events_0 以只读方式打开该文件，并监控中断事件
// 3. 创建中断函数，在中断函数中打印当前时间。
// 4. 使用for循环，每500ms 翻转GPIO电平值


#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#include <time.h>
#include <sys/mman.h>
#include <poll.h>
#include <stdint.h>
#include <sys/time.h>

#define GPIO_ADDR 0x0
#define GPIO_DEV "/dev/xdma0_user"

void print_current_time() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    time_t rawtime = tv.tv_sec;
    struct tm * timeinfo = localtime(&rawtime);
    char buffer[30];
    strftime(buffer, 30, "%Y-%m-%d %H:%M:%S", timeinfo);
    char timestamp[40];
    snprintf(timestamp, 40, "%s.%06ld", buffer, tv.tv_usec);
    printf("%s\n", timestamp);
}

void* irq_handler(void) {
    int fd = open("/dev/xdma0_events_0", O_RDONLY);
    struct pollfd fds[1];
    fds[0].fd = fd;
    fds[0].events = POLLIN;
    uint32_t events_user;

    while (1) {
        int ret = poll(fds, 1, 00);
        if (ret > 0 && (fds[0].revents & POLLIN)) {
            pread(fd, &events_user, sizeof(events_user), 0);
            print_current_time();
        }
    }
}

int main() {
    int gpio_fd = open(GPIO_DEV, O_RDWR);

    uintptr_t* gpio_ptr = mmap(NULL, sizeof(uintptr_t), PROT_READ | PROT_WRITE, MAP_SHARED, gpio_fd, GPIO_ADDR);

    pthread_t irq_thread;
    pthread_create(&irq_thread, NULL, irq_handler, NULL);

    uintptr_t val = 0;
    while (1) {
        *gpio_ptr = 0;
        usleep(500 * 1000);
        *gpio_ptr = 1;
        usleep(500 * 1000);
    }

    munmap(gpio_ptr, sizeof(uintptr_t));
    close(gpio_fd);

    return 0;
}