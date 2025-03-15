/**
 * @file axidma_s2mm.h
 * @brief AXI DMA S2MM驱动头文件
 */

#ifndef _AXIDMA_S2MM_H_
#define _AXIDMA_S2MM_H_

#include <stdint.h>
#include <pthread.h>
#include <stdbool.h>

// 从axidma_cfg.h导入配置
#include "axidma_cfg.h"

/**
 * @brief AXI DMA S2MM描述符结构
 */
typedef struct {
    uint32_t nxtdesc;           // 下一个描述符地址
    uint32_t nxtdesc_msb;       // 下一个描述符地址高32位
    uint32_t buffer_addr;       // 缓冲区地址
    uint32_t buffer_addr_msb;   // 缓冲区地址高32位
    uint32_t reserved1;         // 保留
    uint32_t reserved2;         // 保留
    uint32_t control;           // 控制字
    uint32_t status;            // 状态字
    uint32_t app[8];            // 应用特定数据
} axidma_desc_t;

/**
 * @brief AXI DMA S2MM句柄结构
 */
typedef struct {
    int bar_fd;                 // BAR空间文件描述符
    int c2h_fd;                 // C2H缓冲区文件描述符
    int intr_fd;                // 中断文件描述符
    
    void *dma_regs;             // DMA寄存器映射
    void *desc_vaddr;           // 描述符虚拟地址
    
    uint32_t buffer_size;       // 单个缓冲区大小
    uint32_t num_buffers;       // 缓冲区数量
    
    pthread_t intr_thread;      // 中断处理线程
    bool thread_running;        // 线程运行标志
    
    char *output_file;          // 输出文件路径
    
    pthread_mutex_t mutex;      // 互斥锁
} axidma_s2mm_t;

/**
 * @brief 初始化AXI DMA S2MM
 * 
 * @param output_file 输出文件路径
 * @return axidma_s2mm_t* 成功返回句柄，失败返回NULL
 */
axidma_s2mm_t* axidma_s2mm_init(const char *output_file);

/**
 * @brief 启动AXI DMA S2MM传输
 * 
 * @param handle AXI DMA S2MM句柄
 * @return int 成功返回0，失败返回负数
 */
int axidma_s2mm_start(axidma_s2mm_t *handle);

/**
 * @brief 停止AXI DMA S2MM传输
 * 
 * @param handle AXI DMA S2MM句柄
 * @return int 成功返回0，失败返回负数
 */
int axidma_s2mm_stop(axidma_s2mm_t *handle);

/**
 * @brief 释放AXI DMA S2MM资源
 * 
 * @param handle AXI DMA S2MM句柄
 */
void axidma_s2mm_free(axidma_s2mm_t *handle);

#endif /* _AXIDMA_S2MM_H_ */

