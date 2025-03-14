/**
 * @file axidma_mm2s.c
 * @brief AXI DMA MM2S驱动程序实现
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <termios.h>
#include <stdint.h>
#include "axidma_mm2s.h"

// 私有函数声明
static void* interrupt_handler(void *arg);
static int setup_descriptors(axidma_mm2s_t *ctx);
static int load_initial_data(axidma_mm2s_t *ctx);
static int start_dma_transfer(axidma_mm2s_t *ctx);
static int stop_dma_transfer(axidma_mm2s_t *ctx);
static int wait_for_keypress(void);

axidma_mm2s_t* axidma_mm2s_init(bool is_cyclic)
{
    axidma_mm2s_t *ctx = (axidma_mm2s_t *)malloc(sizeof(axidma_mm2s_t));
    if (!ctx) {
        perror("Failed to allocate memory for context");
        return NULL;
    }
    
    // 初始化上下文
    memset(ctx, 0, sizeof(axidma_mm2s_t));
    ctx->is_cyclic = is_cyclic;
    ctx->buffer_size = MM2S_BUFFER_SIZE/2 > 0x04000000 ? 0x04000000 : MM2S_BUFFER_SIZE/2 ;
    ctx->buffer_addr = MM2S_BUFFER_BASEADDR;
    
    // 打开设备文件
    ctx->user_fd = open(BAR_SPACE_FD, O_RDWR);
    if (ctx->user_fd < 0) {
        perror("Failed to open BAR space device");
        free(ctx);
        return NULL;
    }
    
    ctx->h2c_fd = open(H2C0_BUFFER_FD, O_WRONLY);
    if (ctx->h2c_fd < 0) {
        perror("Failed to open H2C buffer device");
        close(ctx->user_fd);
        free(ctx);
        return NULL;
    }
    
    ctx->intr_fd = open(MM2S_INTERP_FD, O_RDONLY);
    if (ctx->intr_fd < 0) {
        perror("Failed to open MM2S interrupt device");
        close(ctx->h2c_fd);
        close(ctx->user_fd);
        free(ctx);
        return NULL;
    }
    
    // 映射DMA描述符和设备寄存器
    ctx->dma_desc_vaddr = mmap(NULL, DMA_DESC_ALL_SIZE, PROT_READ | PROT_WRITE, 
                              MAP_SHARED, ctx->user_fd, DMA_DESC_BASE_ADDR);
    if (ctx->dma_desc_vaddr == MAP_FAILED) {
        perror("Failed to map DMA descriptor space");
        close(ctx->intr_fd);
        close(ctx->h2c_fd);
        close(ctx->user_fd);
        free(ctx);
        return NULL;
    }
    
    ctx->dma_dev_vaddr = mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, 
                             MAP_SHARED, ctx->user_fd, DMA_DEV_BASE_ADDR);
    if (ctx->dma_dev_vaddr == MAP_FAILED) {
        perror("Failed to map DMA device space");
        munmap(ctx->dma_desc_vaddr, DMA_DESC_ALL_SIZE);
        close(ctx->intr_fd);
        close(ctx->h2c_fd);
        close(ctx->user_fd);
        free(ctx);
        return NULL;
    }
    
    // 设置描述符指针
    ctx->desc = (mm2s_descriptor_t *)ctx->dma_desc_vaddr;
    
    // 初始化描述符
    if (setup_descriptors(ctx) != 0) {
        perror("Failed to setup descriptors");
        munmap(ctx->dma_dev_vaddr, 0x10000);
        munmap(ctx->dma_desc_vaddr, DMA_DESC_ALL_SIZE);
        close(ctx->intr_fd);
        close(ctx->h2c_fd);
        close(ctx->user_fd);
        free(ctx);
        return NULL;
    }
    
    return ctx;
}

void axidma_mm2s_free(axidma_mm2s_t *ctx)
{
    if (!ctx)
        return;
    
    // 停止DMA传输
    if (ctx->is_running) {
        stop_dma_transfer(ctx);
    }
    
    // 关闭文件描述符
    if (ctx->file_fd > 0) {
        close(ctx->file_fd);
    }
    
    // 解除内存映射
    munmap(ctx->dma_dev_vaddr, 0x10000);
    munmap(ctx->dma_desc_vaddr, DMA_DESC_ALL_SIZE);
    
    // 关闭设备文件
    close(ctx->intr_fd);
    close(ctx->h2c_fd);
    close(ctx->user_fd);
    
    // 释放上下文
    free(ctx);
}

int axidma_mm2s_play_file(axidma_mm2s_t *ctx, const char *filename)
{
    if (!ctx || !filename) {
        return -EINVAL;
    }
    
    // 打开文件
    ctx->file_fd = open(filename, O_RDONLY);
    if (ctx->file_fd < 0) {
        perror("Failed to open input file");
        return -errno;
    }
    
    // 获取文件大小
    struct stat st;
    if (fstat(ctx->file_fd, &st) < 0) {
        perror("Failed to get file size");
        close(ctx->file_fd);
        ctx->file_fd = -1;
        return -errno;
    }
    
    ctx->file_size = st.st_size;
    ctx->current_offset = 0;
    ctx->file_completed = false;
    
    // 加载初始数据
    int ret = load_initial_data(ctx);
    if (ret != 0) {
        close(ctx->file_fd);
        ctx->file_fd = -1;
        return ret;
    }
    
    // 启动DMA传输
    ret = start_dma_transfer(ctx);
    if (ret != 0) {
        close(ctx->file_fd);
        ctx->file_fd = -1;
        return ret;
    }
    
    return 0;
}

int axidma_mm2s_play_memory(axidma_mm2s_t *ctx, const void *buffer, uint64_t size)
{
    if (!ctx || !buffer || size == 0) {
        return -EINVAL;
    }
    
    ctx->file_fd = -1;  // 不使用文件
    ctx->file_size = size;
    ctx->current_offset = 0;
    ctx->file_completed = false;
    
    // 计算缓冲区大小
    ssize_t half_buffer = ctx->buffer_size / 2;
    ssize_t bytes_to_write;
    
    // 根据数据大小处理不同情况
    if (size <= half_buffer) {
        // 情况1: 数据小于等于半个缓冲区，复制到两个缓冲区
        bytes_to_write = size;
        
        // 写入第一个缓冲区
        if (pwrite(ctx->h2c_fd, buffer, bytes_to_write, ctx->buffer_addr) != bytes_to_write) {
            perror("Failed to write to first buffer");
            return -errno;
        }
        
        // 写入第二个缓冲区
        if (pwrite(ctx->h2c_fd, buffer, bytes_to_write, ctx->buffer_addr + half_buffer) != bytes_to_write) {
            perror("Failed to write to second buffer");
            return -errno;
        }
    } else if (size <= ctx->buffer_size) {
        // 情况2: 数据小于等于整个缓冲区，分别写入两个半缓冲区
        ssize_t first_half = size / 2;
        ssize_t second_half = size - first_half;
        
        // 写入第一个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer, first_half, ctx->buffer_addr) != first_half) {
            perror("Failed to write to first half buffer");
            return -errno;
        }
        
        // 写入第二个半缓冲区
        if (pwrite(ctx->h2c_fd, (char*)buffer + first_half, second_half, 
                   ctx->buffer_addr + half_buffer) != second_half) {
            perror("Failed to write to second half buffer");
            return -errno;
        }
    } else {
        // 情况3: 数据大于整个缓冲区，先写入整个缓冲区，后续在中断中处理
        // 写入第一个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer, half_buffer, ctx->buffer_addr) != half_buffer) {
            perror("Failed to write to first half buffer");
            return -errno;
        }
        
        // 写入第二个半缓冲区
        if (pwrite(ctx->h2c_fd, (char*)buffer + half_buffer, half_buffer, 
                   ctx->buffer_addr + half_buffer) != half_buffer) {
            perror("Failed to write to second half buffer");
            return -errno;
        }
        
        ctx->current_offset = ctx->buffer_size;
    }
    
    // 启动DMA传输
    int ret = start_dma_transfer(ctx);
    if (ret != 0) {
        return ret;
    }
    
    return 0;
}

int axidma_mm2s_stop(axidma_mm2s_t *ctx)
{
    if (!ctx) {
        return -EINVAL;
    }
    
    return stop_dma_transfer(ctx);
}

int axidma_mm2s_wait(axidma_mm2s_t *ctx)
{
    if (!ctx) {
        return -EINVAL;
    }
    
    pthread_t intr_thread;
    pthread_create(&intr_thread, NULL, interrupt_handler, ctx);
    
    // 等待线程结束
    pthread_join(intr_thread, NULL);
    
    return 0;
}

static int setup_descriptors(axidma_mm2s_t *ctx)
{
    if (!ctx) {
        return -EINVAL;
    }
    
    // 清空描述符区域
    memset(ctx->desc, 0, 20 * 0x40);
    
    // 设置第一个描述符
    ctx->desc[0].nxtdesc = (uint32_t)DMA_DESC_BASE_ADDR + 0x40;
    ctx->desc[0].nxtdesc_msb = 0;
    ctx->desc[0].buffer_addr = (uint32_t)ctx->buffer_addr;
    ctx->desc[0].buffer_addr_msb = (uint32_t)(ctx->buffer_addr >> 32);
    ctx->desc[0].control = (ctx->buffer_size / 2) | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用SOF，半个缓冲区大小
    ctx->desc[0].status = 0;
    
    // 设置第二个描述符
    ctx->desc[1].nxtdesc = (uint32_t)DMA_DESC_BASE_ADDR;
    ctx->desc[1].nxtdesc_msb = 0;
    ctx->desc[1].buffer_addr = (uint32_t)(ctx->buffer_addr + ctx->buffer_size / 2);
    ctx->desc[1].buffer_addr_msb = (uint32_t)((ctx->buffer_addr + ctx->buffer_size / 2) >> 32);
    ctx->desc[1].control = (ctx->buffer_size / 2) | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
    ctx->desc[1].status = 0;
    
    return 0;
}

static int load_initial_data(axidma_mm2s_t *ctx)
{
    if (!ctx) {
        return -EINVAL;
    }
    
    // 计算缓冲区大小
    ssize_t half_buffer = ctx->buffer_size / 2;
    ssize_t bytes_to_read;
    
    // 根据文件大小处理不同情况
    if (ctx->file_size <= half_buffer) {
        // 情况1: 文件小于等于半个缓冲区，复制到两个缓冲区
        char *buffer = malloc(ctx->file_size);
        if (!buffer) {
            perror("Failed to allocate memory for file buffer");
            return -ENOMEM;
        }
        
        // 读取文件内容
        bytes_to_read = ctx->file_size;
        if (read(ctx->file_fd, buffer, bytes_to_read) != bytes_to_read) {
            perror("Failed to read file");
            free(buffer);
            return -errno;
        }
        
        // 写入第一个缓冲区

        lseek(ctx->h2c_fd, ctx->buffer_addr , SEEK_SET);
        if (write(ctx->h2c_fd, buffer, bytes_to_read) != bytes_to_read) {
            perror("Failed to write to first buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[0].control = bytes_to_read | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        // 写入第二个缓冲区
        lseek(ctx->h2c_fd, ctx->buffer_addr + half_buffer, SEEK_SET);
        if (write(ctx->h2c_fd, buffer, bytes_to_read) != bytes_to_read) {
            perror("Failed to write to second buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[1].control = bytes_to_read | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        free(buffer);
        ctx->current_offset = ctx->file_size;
        ctx->file_completed = true;
    } else if (ctx->file_size <= ctx->buffer_size) {
        // 情况2: 文件小于等于整个缓冲区，分别写入两个半缓冲区
        char *buffer = malloc(ctx->file_size);
        if (!buffer) {
            perror("Failed to allocate memory for file buffer");
            return -ENOMEM;
        }
        
        // 读取文件内容
        if (read(ctx->file_fd, buffer, ctx->file_size) != ctx->file_size) {
            perror("Failed to read file");
            free(buffer);
            return -errno;
        }
        
        ssize_t first_half = ctx->file_size / 2;
        ssize_t second_half = ctx->file_size - first_half;
        
        // 写入第一个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer, first_half, ctx->buffer_addr) != first_half) {
            perror("Failed to write to first half buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[0].control = first_half | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        // 写入第二个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer + first_half, second_half, 
                   ctx->buffer_addr + half_buffer) != second_half) {
            perror("Failed to write to second half buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[1].control = second_half | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        free(buffer);
        ctx->current_offset = ctx->file_size;
        ctx->file_completed = true;
    } else {
        // 情况3: 文件大于整个缓冲区，先写入整个缓冲区，后续在中断中处理
        char *buffer = malloc(ctx->buffer_size);
        if (!buffer) {
            perror("Failed to allocate memory for file buffer");
            return -ENOMEM;
        }
        
        // 读取文件内容
        if (read(ctx->file_fd, buffer, ctx->buffer_size) != ctx->buffer_size) {
            perror("Failed to read file");
            free(buffer);
            return -errno;
        }
        
        // 写入第一个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer, half_buffer, ctx->buffer_addr) != half_buffer) {
            perror("Failed to write to first half buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[0].control = half_buffer | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        // 写入第二个半缓冲区
        if (pwrite(ctx->h2c_fd, buffer + half_buffer, half_buffer, 
                   ctx->buffer_addr + half_buffer) != half_buffer) {
            perror("Failed to write to second half buffer");
            free(buffer);
            return -errno;
        }
		ctx->desc[1].control = half_buffer | CONTROL_TXSOF | CONTROL_TXEOF;  // 启用EOF，半个缓冲区大小
        
        free(buffer);
        ctx->current_offset = ctx->buffer_size;
    }
    
    return 0;
}

static int start_dma_transfer(axidma_mm2s_t *ctx)
{
    if (!ctx) {
        return -EINVAL;
    }
    
    ctx->is_running = true;
    ctx->current_desc_idx = 0;
    
    // 启动中断处理线程
    pthread_t intr_thread;
    if (pthread_create(&intr_thread, NULL, interrupt_handler, ctx) != 0) {
        perror("Failed to create interrupt thread");
        stop_dma_transfer(ctx);
        return -errno;
    }
    
    // 分离线程，让它在后台运行
    pthread_detach(intr_thread);
   


    volatile uint32_t *mm2s_dmacr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMACR);
    volatile uint32_t *mm2s_dmasr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMASR);
    volatile uint32_t *mm2s_curdesc = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_CURDESC);
    volatile uint32_t *mm2s_curdesc_msb = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_CURDESC_MSB);
    volatile uint32_t *mm2s_taildesc = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_TAILDESC);
    volatile uint32_t *mm2s_taildesc_msb = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_TAILDESC_MSB);
    
    // 复位DMA控制器
    *mm2s_dmacr = DMACR_RESET;
    usleep(1000);  // 等待复位完成
    
    // 检查DMA状态
    if (!(*mm2s_dmasr & DMASR_HALTED)) {
        fprintf(stderr, "DMA not halted after reset\n");
        return -EIO;
    }
    
    // 设置当前描述符指针
    *mm2s_curdesc = (uint32_t)DMA_DESC_BASE_ADDR;
    *mm2s_curdesc_msb = 0;
    
    // 配置DMA控制寄存器
    uint32_t dmacr_val = DMACR_RS | DMACR_IOC_IRQ ;//| DMACR_ERR_IRQ;
    if (ctx->is_cyclic) {
        dmacr_val |= DMACR_CYCLIC;
    }
    
    // 启动DMA传输
    *mm2s_dmacr = dmacr_val;
    
    
    // 设置尾部描述符指针
    *mm2s_taildesc = (uint32_t)DMA_DESC_BASE_ADDR + 0x40;
    *mm2s_taildesc_msb = 0;

    //// 检查DMA是否启动
    //if (*mm2s_dmasr & DMASR_HALTED) {
    //    fprintf(stderr, "DMA still halted after start\n");
    //    return -EIO;
    //}
    
    return 0;
}

static int stop_dma_transfer(axidma_mm2s_t *ctx)
{
    if (!ctx || !ctx->is_running) {
        return 0;
    }
    
    volatile uint32_t *mm2s_dmacr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMACR);
    volatile uint32_t *mm2s_dmasr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMASR);
    
    // 停止DMA传输
    *mm2s_dmacr &= ~DMACR_RS;
    
    // 等待DMA停止
    int timeout = 100;  // 超时时间，单位：毫秒
    while (!(*mm2s_dmasr & DMASR_HALTED) && timeout > 0) {
        usleep(1000);  // 等待1毫秒
        timeout--;
    }
    
    if (timeout == 0) {
        fprintf(stderr, "Timeout waiting for DMA to halt\n");
        return -ETIMEDOUT;
    }
    
    // 如果是循环模式，禁用循环模式
    if (ctx->is_cyclic) {
        *mm2s_dmacr &= ~DMACR_CYCLIC;
    }
    
    ctx->is_running = false;
    
    return 0;
}

static void* interrupt_handler(void *arg)
{
    axidma_mm2s_t *ctx = (axidma_mm2s_t *)arg;
    uint32_t intr_status;
    uint32_t temp_status;;
    uint64_t half_buffer = ctx->buffer_size / 2;
    char *buffer = NULL;
    
    // 如果文件已经完全加载到缓冲区，不需要继续处理
    if (ctx->file_completed && !ctx->is_cyclic) {
        return NULL;
    }
    
    // 分配临时缓冲区
    if (!ctx->file_completed) {
        buffer = malloc(half_buffer);
        if (!buffer) {
            perror("Failed to allocate memory for interrupt buffer");
            return NULL;
        }
    }
    
    while (ctx->is_running) {
        // 等待中断
        if (read(ctx->intr_fd, &intr_status, sizeof(intr_status)) != sizeof(intr_status)) {
            if (errno == EINTR) {
                continue;  // 被信号中断，继续等待
            }
            perror("Failed to read interrupt status");
            break;
        }
		volatile uint32_t *mm2s_curdesc = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_CURDESC);
    	volatile uint32_t *mm2s_curdesc_msb = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_CURDESC_MSB);
        volatile uint32_t *mm2s_dmasr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMASR);
        volatile uint32_t *mm2s_dmacr = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_DMACR);
		volatile uint32_t *mm2s_taildesc = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_TAILDESC);
    	volatile uint32_t *mm2s_taildesc_msb = (volatile uint32_t *)(ctx->dma_dev_vaddr + MM2S_TAILDESC_MSB);
        
		//printf("mm2s_dmasr =%08x\n",*mm2s_dmasr );
        // 清除中断状态
		temp_status = *mm2s_dmasr ;
        *mm2s_dmasr = DMASR_IOC_IRQ | DMASR_ERR_IRQ;
        
        // 检查错误
        if (intr_status & DMASR_ERR_IRQ) {
            fprintf(stderr, "DMA error detected: 0x%08x\n", *mm2s_dmasr);
            break;
        }
		if(ctx->desc[0].status & 0x80000000)
		    ctx->desc[0].status = 0x00000000;
		if(ctx->desc[1].status & 0x80000000){
		    ctx->desc[1].status = 0x00000000; //--不要删除这句话--- printf("重启DMA\n");
			*mm2s_taildesc = (uint32_t)DMA_DESC_BASE_ADDR + 0x40;
    		*mm2s_taildesc_msb = 0;
		} 
        // 处理IOC中断
        if (temp_status & DMASR_IOC_IRQ) {
		//	printf("status =%08x\n",temp_status );
            
            // 切换到下一个描述符
            ctx->current_desc_idx = (ctx->current_desc_idx + 1) % 2;
            
            // 如果文件已经完全读取，且不是循环模式，则退出
            if (ctx->file_completed && !ctx->is_cyclic) {
                break;
            }
            // 如果是循环播放模式且用户按下任意键，则退出
            if (ctx->is_cyclic) {
                int key_pressed = wait_for_keypress();
                if (key_pressed) {
                    break;
                }
            }
            
            // 如果文件未完全读取，继续读取数据
            if (!ctx->file_completed) {
                // 计算要读取的数据大小
                uint64_t bytes_left = ctx->file_size - ctx->current_offset;
                ssize_t bytes_to_read = (bytes_left < half_buffer) ? bytes_left : half_buffer;
				//printf(" ctx->current_offset=%d\n",  ctx->current_offset) ;
                // 读取文件数据
                if (ctx->file_fd > 0) {
                    ssize_t bytes_read = read(ctx->file_fd, buffer, bytes_to_read);
                    if (bytes_read <= 0) {
                        // 文件读取错误或结束
                        ctx->file_completed = true;
                    } else {
                        // 计算当前需要写入的缓冲区地址
                        uint64_t buffer_addr = ctx->buffer_addr;
                        if (ctx->current_desc_idx == 0) {
                            buffer_addr += half_buffer;  // 写入第二个缓冲区
                        }
                        
                        // 写入数据到缓冲区
                        if (pwrite(ctx->h2c_fd, buffer, bytes_read, buffer_addr) != bytes_read) {
                            perror("Failed to write to buffer in interrupt handler");
                            break;
                        }
                        
                        ctx->current_offset += bytes_read;
                        
                        // 检查文件是否读取完成
                        if (ctx->current_offset >= ctx->file_size) {
                            ctx->file_completed = true;
                            
                            // 如果是单次播放模式，禁用循环模式
                            if (!ctx->is_cyclic) {
                                *mm2s_dmacr &= ~DMACR_CYCLIC;
                            } else {
                                // 如果是循环模式，重置文件偏移量
                                lseek(ctx->file_fd, 0, SEEK_SET);
                                ctx->current_offset = 0;
                                ctx->file_completed = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 释放临时缓冲区
    if (buffer) {
        free(buffer);
    }
    
    return NULL;
}

static int wait_for_keypress(void)
{
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    
    // 非阻塞检查是否有键盘输入
    select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv);
    
    if (FD_ISSET(STDIN_FILENO, &fds)) {
        char c;
        read(STDIN_FILENO, &c, 1);
        return 1;  // 有键盘输入
    }
    
    return 0;  // 无键盘输入
}

