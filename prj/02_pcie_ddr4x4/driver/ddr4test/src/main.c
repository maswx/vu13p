#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>

#define SIZE 0x40000000 // 1GB
#define TOTAL_SIZE 0x400000000 // 16GB

int main() {
    int fd_read = open("/dev/xdma0_c2h_0", O_RDONLY);
    int fd_write = open("/dev/xdma0_h2c_0", O_WRONLY);

    if (fd_read < 0 || fd_write < 0) {
        perror("Failed to open the device");
        return EXIT_FAILURE;
    }

    unsigned int *buffer = malloc(SIZE);
    if (buffer == NULL) {
        perror("Failed to allocate buffer");
        return EXIT_FAILURE;
    }

    // Fill the buffer with test data.
    for (unsigned long i = 0; i < SIZE / sizeof(unsigned int); i++) {
        buffer[i] = i;
    }

    // Write the buffer to the device memory.
    time_t start_time = time(NULL);
    for (unsigned long i = 0; i < TOTAL_SIZE; i += SIZE) {
        write(fd_write, buffer, SIZE);
    }
    time_t end_time = time(NULL);
    double write_speed = (double)TOTAL_SIZE / (end_time - start_time)/1e9;
    printf("写入16GB内存的速度为: %f GB/s\n", write_speed);

    // Read the device memory and verify the data.
    start_time = time(NULL);
    for (unsigned long i = 0; i < TOTAL_SIZE; i += SIZE) {
        read(fd_read, buffer, SIZE);
    }
    end_time = time(NULL);
    double read_speed = (double)TOTAL_SIZE / (end_time - start_time)/1e9;
    printf("读出16GB内存的速度为: %f GB/s\n",  read_speed);


    // Step 3: Read the device memory and verify the data.
    for (unsigned long i = 0; i < TOTAL_SIZE; i += SIZE) {
        printf("正在比对0x%09lx ~ 0x%09lx中的内容, ", i, i + SIZE);
        read(fd_read, buffer, SIZE);
        for (unsigned long j = 0; j < SIZE / sizeof(unsigned int); j++) {
            if (buffer[j] != j) {
                printf("Memory test failed at offset 0x%lx\n", i + j * sizeof(unsigned int));
                break;
            }
        }
        printf("比对完成\n");
    }
    free(buffer);
    close(fd_read);
    close(fd_write);
    return EXIT_SUCCESS;
}