/**
 * @file axidma_s2mm.c
 * @brief AXI DMA S2MM驱动实现
 */

#include "axidma_s2mm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <signal.h>
#include <pthread.h>

// 工作队列结构
typedef struct {
    axidma_s2mm_t *handle;
    uint32_t desc_idx;
} work_item_t;

// 静态函数声明
static void* intr_handler_thread(void *arg);
static void process_completed_buffer(axidma_s2mm_t *handle, uint32_t desc_idx);

/**
 * @brief 初始化AXI DMA S2MM
 */
axidma_s2mm_t* axidma_s2mm_init(const char *output_file)
{
    axidma_s2mm_t *handle = NULL;
    
    // 分配句柄内存
    handle = (axidma_s2mm_t *)malloc(sizeof(axidma_s2mm_t));
    if (!handle) {
        perror("Failed to allocate handle memory");
        return NULL;
    }
    
    // 初始化句柄
    memset(handle, 0, sizeof(axidma_s2mm_t));
    
    // 初始化互斥锁
    if (pthread_mutex_init(&handle->mutex, NULL) != 0) {
        perror("Failed to initialize mutex");
        free(handle);
        return NULL;
    }
    
    // 保存输出文件路径
    if (output_file) {
        handle->output_file = strdup(output_file);
        if (!handle->output_file) {
            perror("Failed to allocate output file path");
            pthread_mutex_destroy(&handle->mutex);
            free(handle);
            return NULL;
        }
    }
    
    // 打开BAR空间设备文件
    handle->bar_fd = open(BAR_SPACE_FD, O_RDWR);
    if (handle->bar_fd < 0) {
        perror("Failed to open BAR space device");
        if (handle->output_file) free(handle->output_file);
        pthread_mutex_destroy(&handle->mutex);
        free(handle);
        return NULL;
    }
    
    // 打开C2H缓冲区设备文件
    handle->c2h_fd = open(C2H0_BUFFER_FD, O_RDWR);
    if (handle->c2h_fd < 0) {
        perror("Failed to open C2H buffer device");
        close(handle->bar_fd);
        if (handle->output_file) free(handle->output_file);
        pthread_mutex_destroy(&handle->mutex);
        free(handle);
        return NULL;
    }
    
    // 打开中断设备文件
    handle->intr_fd = open(S2MM_INTERP_FD, O_RDWR);
    if (handle->intr_fd < 0) {
        perror("Failed to open interrupt device");
        close(handle->c2h_fd);
        close(handle->bar_fd);
        if (handle->output_file) free(handle->output_file);
        pthread_mutex_destroy(&handle->mutex);
        free(handle);
        return NULL;
    }
    
    // 映射DMA寄存器
    handle->dma_regs = mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, MAP_SHARED, 
                           handle->bar_fd, DMA_DEV_BASE_ADDR);
    if (handle->dma_regs == MAP_FAILED) {
        perror("Failed to map DMA registers");
        close(handle->intr_fd);
        close(handle->c2h_fd);
        close(handle->bar_fd);
        if (handle->output_file) free(handle->output_file);
        pthread_mutex_destroy(&handle->mutex);
        free(handle);
        return NULL;
    }
    
    // 映射描述符空间
    handle->desc_vaddr = mmap(NULL, DMA_DESC_ALL_SIZE/2, PROT_READ | PROT_WRITE, 
                             MAP_SHARED, handle->bar_fd, DMA_DESC_BASE_ADDR+ DMA_DESC_ALL_SIZE/2);
    if (handle->desc_vaddr == MAP_FAILED) {
        perror("Failed to map descriptor space");
        munmap(handle->dma_regs, 0x10000);
        close(handle->intr_fd);
        close(handle->c2h_fd);
        close(handle->bar_fd);
        if (handle->output_file) free(handle->output_file);
        pthread_mutex_destroy(&handle->mutex);
        free(handle);
        return NULL;
    }
    
    // 设置缓冲区参数
    handle->num_buffers = 4;  // 固定4个缓冲区
    handle->buffer_size = S2MM_BUFFER_SIZE / handle->num_buffers;
    
    printf("AXI DMA S2MM initialized successfully\n");
    printf("Buffer size: %u bytes, Number of buffers: %u\n", 
           handle->buffer_size, handle->num_buffers);
    
    return handle;
}

/**
 * @brief 配置S2MM描述符
 */
static int configure_s2mm_descriptors(axidma_s2mm_t *handle)
{
    axidma_desc_t *desc_base = (axidma_desc_t *)handle->desc_vaddr;
    uint32_t desc_phys_addr = DMA_DESC_BASE_ADDR+DMA_DESC_ALL_SIZE/2;
    uint64_t buffer_addr = S2MM_BUFFER_BASEADDR;
    
    // 配置4个描述符
    for (uint32_t i = 0; i < handle->num_buffers; i++) {
        axidma_desc_t *desc = &desc_base[i];
        uint32_t next_idx = (i + 1) % handle->num_buffers;
        uint32_t next_desc_phys = desc_phys_addr + (next_idx * 0x40);
        
        // 清空描述符
        memset(desc, 0, sizeof(axidma_desc_t));
        
        // 设置下一个描述符地址
        desc->nxtdesc = next_desc_phys;
        desc->nxtdesc_msb = 0;  // 假设不使用64位地址
        
        // 设置缓冲区地址
        desc->buffer_addr = (buffer_addr + (i * handle->buffer_size) ) & 0xFFFFFFFF;
        desc->buffer_addr_msb = (buffer_addr >> 32);
        
        // 设置控制字，包含缓冲区大小
        desc->control = handle->buffer_size;
        
        // 状态字初始化为0
        desc->status = 0;
        
        printf("Descriptor %u: next=0x%08x, buffer=0x%08x%08x, size=0x%08x\n",
               i, desc->nxtdesc, desc->buffer_addr_msb, desc->buffer_addr, handle->buffer_size);
    }
    
    return 0;
}

/**
 * @brief 启动AXI DMA S2MM传输
 */
int axidma_s2mm_start(axidma_s2mm_t *handle)
{
    volatile uint32_t *s2mm_dmacr;
    volatile uint32_t *s2mm_dmasr;
    volatile uint32_t *s2mm_curdesc;
    volatile uint32_t *s2mm_taildesc;
    volatile uint32_t *s2mm_taildesc_msb;
    uint32_t reg_val;
    int ret;
    
    if (!handle) {
        return -EINVAL;
    }
    
    // 获取寄存器地址
    s2mm_dmacr = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_DMACR);
    s2mm_dmasr = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_DMASR);
    s2mm_curdesc = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_CURDESC);
    s2mm_taildesc = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_TAILDESC);
    s2mm_taildesc_msb = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_TAILDESC_MSB);
    
    // 配置描述符
    ret = configure_s2mm_descriptors(handle);
    if (ret != 0) {
        return ret;
    }
    
    // 复位DMA控制器
	//*s2mm_dmacr = DMACR_RESET;
    //usleep(10000);  // 等待复位完成
    *s2mm_dmacr = 0;
    
    // 检查DMA状态
    reg_val = *s2mm_dmasr;
    if (!(reg_val & DMASR_HALTED)) {
        fprintf(stderr, "DMA not halted after reset: 0x%08x\n", reg_val);
        return -EIO;
    }
    
    // 设置当前描述符地址
    *s2mm_curdesc = DMA_DESC_BASE_ADDR+DMA_DESC_ALL_SIZE/2;
    
    // 启动中断处理线程
    handle->thread_running = true;
    if (pthread_create(&handle->intr_thread, NULL, intr_handler_thread, handle) != 0) {
        perror("Failed to create interrupt handler thread");
        return -EFAULT;
    }
    
    // 配置DMA控制寄存器，启用IOC中断
    *s2mm_dmacr = DMACR_RS | DMACR_IOC_IRQ | DMACR_CYCLIC;
    
    // 设置尾描述符地址，启动DMA
    *s2mm_taildesc = (DMA_DESC_ALL_SIZE/2 + DMA_DESC_BASE_ADDR) + ((handle->num_buffers - 1) * 0x40);
	*s2mm_taildesc_msb = 0;
    
    printf("AXI DMA S2MM started\n");
    printf("DMACR: 0x%08x, DMASR: 0x%08x\n", *s2mm_dmacr, *s2mm_dmasr);
    printf("CURDESC: 0x%08x, TAILDESC: 0x%08x\n", *s2mm_curdesc, *s2mm_taildesc);
    
    return 0;
}

/**
 * @brief 停止AXI DMA S2MM传输
 */
int axidma_s2mm_stop(axidma_s2mm_t *handle)
{
    volatile uint32_t *s2mm_dmacr;
    
    if (!handle) {
        return -EINVAL;
    }
    
    // 获取寄存器地址
    s2mm_dmacr = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_DMACR);
    
    // 停止DMA
    *s2mm_dmacr = 0;  // 清除RS位
    
    // 停止中断处理线程
    if (handle->thread_running) {
        handle->thread_running = false;
        pthread_join(handle->intr_thread, NULL);
    }
    
    printf("AXI DMA S2MM stopped\n");
    
    return 0;
}

/**
 * @brief 释放AXI DMA S2MM资源
 */
void axidma_s2mm_free(axidma_s2mm_t *handle)
{
    if (!handle) {
        return;
    }
    
    // 停止DMA
    axidma_s2mm_stop(handle);
    
    // 解除内存映射
    if (handle->desc_vaddr != MAP_FAILED && handle->desc_vaddr != NULL) {
        munmap(handle->desc_vaddr, DMA_DESC_ALL_SIZE/2);
    }
    
    if (handle->dma_regs != MAP_FAILED && handle->dma_regs != NULL) {
        munmap(handle->dma_regs, 0x10000);
    }
    
    // 关闭文件描述符
    if (handle->intr_fd >= 0) {
        close(handle->intr_fd);
    }
    
    if (handle->c2h_fd >= 0) {
        close(handle->c2h_fd);
    }
    
    if (handle->bar_fd >= 0) {
        close(handle->bar_fd);
    }
    
    // 释放输出文件路径
    if (handle->output_file) {
        free(handle->output_file);
    }
    
    // 销毁互斥锁
    pthread_mutex_destroy(&handle->mutex);
    
    // 释放句柄
    free(handle);
    
    printf("AXI DMA S2MM resources freed\n");
}

/**
 * @brief 中断处理线程
 */
static void* intr_handler_thread(void *arg)
{
    axidma_s2mm_t *handle = (axidma_s2mm_t *)arg;
    volatile uint32_t *s2mm_dmasr;
    axidma_desc_t *desc_base;
	uint64_t intpcnt=0;
    uint32_t events;
    volatile uint32_t *s2mm_dmacr;
    volatile uint32_t *s2mm_taildesc;
    volatile uint32_t *s2mm_taildesc_msb;
    s2mm_dmacr = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_DMACR);
    s2mm_taildesc = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_TAILDESC);
    s2mm_taildesc_msb = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_TAILDESC_MSB);
    
    // 获取寄存器地址
    s2mm_dmasr = (volatile uint32_t *)((char *)handle->dma_regs + S2MM_DMASR);
    desc_base = (axidma_desc_t *)handle->desc_vaddr;
    
    printf("Interrupt handler thread started\n");
    
    while (handle->thread_running) {
        // 等待中断
        if (read(handle->intr_fd, &events, sizeof(events)) < 0) {
            if (errno == EINTR) {
                continue;  // 被信号中断，继续等待
            }
            perror("Failed to read interrupt event");
            break;
        }
        //if (desc_base[0].status & 0x80000000) {
			*s2mm_dmacr = DMACR_RS | DMACR_IOC_IRQ | DMACR_CYCLIC;
			*s2mm_taildesc = (DMA_DESC_ALL_SIZE/2 + DMA_DESC_BASE_ADDR) + ((handle->num_buffers - 1) * 0x40);
			*s2mm_taildesc_msb = 0;
		//}
        
        // 检查中断类型
        uint32_t status = *s2mm_dmasr;
        
        // 清除中断标志
        if (status & DMASR_IOC_IRQ) {
            *s2mm_dmasr = status | DMASR_IOC_IRQ;
			printf("IOC interrupt %03ld received, status: 0x%08x\n",intpcnt++, status);
        }
        
        //// 检查错误
        //if (status & DMASR_ERR_IRQ) {
        //    *s2mm_dmasr = status | DMASR_ERR_IRQ;
        //    fprintf(stderr, "DMA error interrupt received: 0x%08x\n", status);
        //}
        
        // 轮询所有描述符的状态
        for (uint32_t i = 0; i < handle->num_buffers; i++) {
            // 检查描述符完成标志 (STATUS_COMPLETED = 0x80000000)
            if (desc_base[i].status & 0x80000000) {
                // 处理完成的缓冲区
                process_completed_buffer(handle, i);
                
                // 清除完成标志
                desc_base[i].status &= ~0x80000000;
            }
        }
    }
    
    printf("Interrupt handler thread exited\n");
    return NULL;
}

/**
 * @brief 处理完成的缓冲区
 */
static void process_completed_buffer(axidma_s2mm_t *handle, uint32_t desc_idx)
{
    axidma_desc_t *desc = &((axidma_desc_t *)handle->desc_vaddr)[desc_idx];
    uint32_t bytes_received = desc->status & 0x03FFFFFF;  // 低26位为传输字节数
    uint32_t buffer_offset = desc->buffer_addr - S2MM_BUFFER_BASEADDR;
    
    //printf("Buffer %u completed: %u bytes received\n", desc_idx, bytes_received);
    
    // 如果没有接收到数据，跳过
    if (bytes_received == 0) {
        return;
    }
    
    // 如果没有指定输出文件，跳过
    if (!handle->output_file) {
        return;
    }
    
    // 读取接收到的数据
    void *buffer = malloc(bytes_received);
    if (!buffer) {
        perror("Failed to allocate buffer memory");
        return;
    }
    
    // 从C2H设备读取数据
    if (pread(handle->c2h_fd, buffer, bytes_received, buffer_offset) != bytes_received) {
        perror("Failed to read data from C2H buffer");
        free(buffer);
        return;
    }
    
    // 写入到输出文件
    FILE *fp = fopen(handle->output_file, "ab");
    if (!fp) {
        perror("Failed to open output file");
        free(buffer);
        return;
    }
    
    // 写入数据
    if (fwrite(buffer, 1, bytes_received, fp) != bytes_received) {
        perror("Failed to write data to output file");
    }
    
    fclose(fp);
    free(buffer);
}

