/**
 * @file axidma_mm2s.h
 * @brief AXI DMA MM2S驱动程序头文件
 */

#ifndef _AXIDMA_MM2S_H_
#define _AXIDMA_MM2S_H_

#include <stdint.h>
#include <stdbool.h>
#include "axidma_cfg.h"

/**
 * @brief AXI DMA MM2S描述符结构
 */
typedef struct {
    uint32_t nxtdesc;           // 下一个描述符指针
    uint32_t nxtdesc_msb;       // 下一个描述符指针高32位
    uint32_t buffer_addr;       // 缓冲区地址
    uint32_t buffer_addr_msb;   // 缓冲区地址高32位
    uint32_t reserved1;         // 保留
    uint32_t reserved2;         // 保留
    uint32_t control;           // 控制字
    uint32_t status;            // 状态字
    uint32_t app0;              // 应用程序特定数据
    uint32_t app1;              // 应用程序特定数据
    uint32_t app2;              // 应用程序特定数据
    uint32_t app3;              // 应用程序特定数据
    uint32_t app4;              // 应用程序特定数据
    uint32_t app5;              // 应用程序特定数据
    uint32_t app6;              // 应用程序特定数据
    uint32_t app7;              // 应用程序特定数据
} mm2s_descriptor_t;

/**
 * @brief AXI DMA MM2S上下文结构
 */
typedef struct {
    int user_fd;                // /dev/xdma0_user文件描述符
    int h2c_fd;                 // /dev/xdma0_h2c_0文件描述符
    int intr_fd;                // /dev/xdma0_events_2文件描述符
    
    void *dma_desc_vaddr;       // DMA描述符虚拟地址
    void *dma_dev_vaddr;        // DMA设备寄存器虚拟地址
    
    volatile mm2s_descriptor_t *desc;    // 描述符数组指针
    uint64_t buffer_size;       // 缓冲区大小
    uint64_t buffer_addr;       // 缓冲区物理地址
    
    bool is_cyclic;             // 是否循环播放
    bool is_running;            // 是否正在运行
    bool file_completed;        // 文件是否读取完成
    
    uint64_t file_size;         // 文件大小
    int file_fd;                // 文件描述符
    
    uint64_t current_offset;    // 当前文件偏移量
    int current_desc_idx;       // 当前描述符索引
} axidma_mm2s_t;

/**
 * @brief 初始化AXI DMA MM2S驱动
 * 
 * @param is_cyclic 是否循环播放
 * @return axidma_mm2s_t* 成功返回上下文指针，失败返回NULL
 */
axidma_mm2s_t* axidma_mm2s_init(bool is_cyclic);

/**
 * @brief 释放AXI DMA MM2S驱动资源
 * 
 * @param ctx 上下文指针
 */
void axidma_mm2s_free(axidma_mm2s_t *ctx);

/**
 * @brief 从文件播放数据
 * 
 * @param ctx 上下文指针
 * @param filename 文件名
 * @return int 成功返回0，失败返回负数
 */
int axidma_mm2s_play_file(axidma_mm2s_t *ctx, const char *filename);

/**
 * @brief 从内存播放数据
 * 
 * @param ctx 上下文指针
 * @param buffer 内存缓冲区
 * @param size 缓冲区大小
 * @return int 成功返回0，失败返回负数
 */
int axidma_mm2s_play_memory(axidma_mm2s_t *ctx, const void *buffer, uint64_t size);

/**
 * @brief 停止播放
 * 
 * @param ctx 上下文指针
 * @return int 成功返回0，失败返回负数
 */
int axidma_mm2s_stop(axidma_mm2s_t *ctx);

/**
 * @brief 等待播放完成
 * 
 * @param ctx 上下文指针
 * @return int 成功返回0，失败返回负数
 */
int axidma_mm2s_wait(axidma_mm2s_t *ctx);

#endif /* _AXIDMA_MM2S_H_ */

