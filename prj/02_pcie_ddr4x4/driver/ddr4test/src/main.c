#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/mman.h>
#include <time.h>
#include <stdint.h>

#define DEVICE_READ "/dev/xdma0_c2h_0"
#define DEVICE_WRITE "/dev/xdma0_h2c_0"
#define SIZE 0x3FFFFFFFF

int main() {
    int fd_read = open(DEVICE_READ, O_RDWR | O_SYNC);
    if (fd_read < 0) {
        perror("Failed to open the read device");
        return EXIT_FAILURE;
    }

    int fd_write = open(DEVICE_WRITE, O_RDWR | O_SYNC);
    if (fd_write < 0) {
        close(fd_read);
        perror("Failed to open the write device");
        return EXIT_FAILURE;
    }

    uintptr_t *map_base_read = mmap(0, SIZE, PROT_READ, MAP_SHARED, fd_read, 0);
    if (map_base_read == MAP_FAILED) {
        close(fd_read);
        close(fd_write);
        perror("Failed to map the read device");
        return EXIT_FAILURE;
    }

    uintptr_t *map_base_write = mmap(0, SIZE, PROT_WRITE, MAP_SHARED, fd_write, 0);
    if (map_base_write == MAP_FAILED) {
        munmap(map_base_read, SIZE);
        close(fd_read);
        close(fd_write);
        perror("Failed to map the write device");
        return EXIT_FAILURE;
    }

    // Test the memory.
    time_t start_time = time(NULL);
    for (unsigned long i = 0; i < SIZE; i += 4) {
        *((uint64_t *)(map_base_write + i)) = i;
    }
    time_t end_time = time(NULL);
    double timxx = (double)SIZE / (end_time - start_time);
    printf("写入16GB内存的速度为: %f MB/s\n", timxx);

    start_time = time(NULL);
    for (unsigned long i = 0; i < SIZE; i += 4) {
        if (*((uint64_t *)(map_base_read + i)) != i) {
            printf("Memory test failed at offset 0x%lx\n", i);
            break;
        }
    }
    end_time = time(NULL);
    printf("读出并比对16GB内存的时间为: %f s\n",  (end_time - start_time));

    if (munmap(map_base_read, SIZE) == -1 || munmap(map_base_write, SIZE) == -1) {
        close(fd_read);
        close(fd_write);
        perror("Failed to unmap the devices");
        return EXIT_FAILURE;
    }

    close(fd_read);
    close(fd_write);
    return EXIT_SUCCESS;
}