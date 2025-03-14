#ifndef _AXIDMA_H_
#define _AXIDMA_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdint.h>
#include <pthread.h>
#include <time.h>
#include <sys/poll.h>   // 用于poll函数和相关常量
typedef struct {
    int dma_fd;             // DMA控制器文件描述符
    int data_fd;            // 数据文件描述符
    int event_fd;           // 事件文件描述符
    void *dma_regs;         // DMA寄存器映射
    void *desc_base;        // 描述符基地址映射
    void *buffer;           // 数据缓冲区映射
    uint64_t file_size;     // 文件大小
    uint64_t bytes_sent;    // 已发送字节数
    uint64_t buffer_size;   // 缓冲区大小
    uint32_t desc_count;         // 描述符数量
    int is_cyclic;          // 是否为循环模式
    pthread_t event_thread; // 事件处理线程
    int running;            // 运行标志
} mm2s_dma_t;


// 工作队列项结构
typedef struct {
    void *buffer;           // 数据缓冲区指针
    size_t size;            // 数据大小
    int frame_index;        // 帧索引
    struct timespec ts;     // 时间戳
} work_item_t;

// 工作队列结构
typedef struct {
    work_item_t *items;     // 工作项数组
    int capacity;           // 队列容量
    int head;               // 队列头
    int tail;               // 队列尾
    int count;              // 队列中的项目数
    pthread_mutex_t mutex;  // 互斥锁
    pthread_cond_t not_empty; // 条件变量：队列非空
    pthread_cond_t not_full;  // 条件变量：队列非满
} work_queue_t;

// 描述符状态跟踪
typedef struct {
    int processed;          // 是否已处理
    uint32_t status;        // 描述符状态
    uint32_t bytes_received; // 接收到的字节数
    int is_sof;             // 是否为帧起始
    int is_eof;             // 是否为帧结束
} desc_status_t;

// S2MM DMA结构
typedef struct {
    int dma_fd;             // DMA控制器文件描述符
    int data_fd;            // 数据文件描述符
    int event_fd;           // 事件文件描述符
    void *dma_regs;         // DMA寄存器映射
    void *desc_base;        // 描述符基地址映射
    void *buffer;           // 数据缓冲区映射
    size_t buffer_size;     // 缓冲区大小
    size_t desc_size;       // 每个描述符的大小
    uint32_t desc_count;         // 描述符数量
    size_t segment_size;    // 每个描述符对应的缓冲区大小
    desc_status_t *desc_status; // 描述符状态数组
    work_queue_t work_queue;  // 工作队列
    pthread_t event_thread;   // 事件处理线程
    pthread_t worker_thread;  // 工作线程
    int running;            // 运行标志
    int frame_count;        // 接收到的帧计数
    char output_dir[256];   // 输出目录
} s2mm_dma_t;


// 函数声明
int init_mm2s_dma(mm2s_dma_t *dma, const char *filename);
int load_file_to_buffer(mm2s_dma_t *dma, const char *filename);
int setup_mm2s_descriptors(mm2s_dma_t *dma);
int start_mm2s_dma(mm2s_dma_t *dma);
void *event_handler_thread(void *arg);




// 函数声明
int init_s2mm_dma(s2mm_dma_t *dma, const char *output_dir);
int setup_s2mm_descriptors(s2mm_dma_t *dma);
int start_s2mm_dma(s2mm_dma_t *dma);
void cleanup_s2mm_dma(s2mm_dma_t *dma);
int init_work_queue(work_queue_t *queue, int capacity);
int enqueue_work(work_queue_t *queue, void *buffer, size_t size, int frame_index);
int dequeue_work(work_queue_t *queue, work_item_t *item);
void destroy_work_queue(work_queue_t *queue);
void *event_handler_thread(void *arg);
void *worker_thread(void *arg);




// =====================================================================================
// =====================================================================================
// =====================================================================================
// 以下是固定的寄存器
// DMA寄存器偏移量
#define MM2S_DMACR        0x00// MM2S DMA Control Register
#define MM2S_DMASR        0x04// MM2S DMA Status Register
#define MM2S_CURDESC      0x08// MM2S Current Descriptor
#define MM2S_CURDESC_MSB  0x0C// MM2S Current Descriptor MSB
#define MM2S_TAILDESC     0x10// MM2S Tail Descriptor
#define MM2S_TAILDESC_MSB 0x14// MM2S Tail Descriptor MSB
							  // ==========================
#define S2MM_DMACR        0x30// S2MM DMA Control Register
#define S2MM_DMASR        0x34// S2MM DMA Status Register
#define S2MM_CURDESC      0x38// S2MM Current Descriptor
#define S2MM_CURDESC_MSB  0x3C// S2MM Current Descriptor MSB
#define S2MM_TAILDESC     0x40// S2MM Tail Descriptor
#define S2MM_TAILDESC_MSB 0x44// S2MM Tail Descriptor MSB

// 描述符偏移量
#define NXTDESC_OFFSET         0x00
#define NXTDESC_MSB_OFFSET     0x04
#define BUFFER_ADDR_OFFSET     0x08
#define BUFFER_ADDR_MSB_OFFSET 0x0C
#define CONTROL_OFFSET         0x18
#define STATUS_OFFSET          0x1C
#define APP_OFFSET             0x20  // 应用特定数据偏移量
#define DESC_SIZE              64    // 描述符大小(字节)

// 控制寄存器位
#define DMACR_RS         (1 << 0)    // Run/Stop
#define DMACR_RESET      (1 << 2)    // Reset
#define DMACR_KEYHOLE    (1 << 3)    // Keyhole
#define DMACR_CYCLIC     (1 << 4)    // Cyclic BD Enable
#define DMACR_IOC_IRQ    (1 << 12)   // IOC中断使能
#define DMACR_DLY_IRQ    (1 << 13)   // DLY中断使能
#define DMACR_ERR_IRQ    (1 << 14)   // 错误中断使能
                         
// 状态寄存器位          
#define DMASR_HALTED     (1 << 0)    // DMA已停止
#define DMASR_IDLE       (1 << 1)    // DMA空闲
#define DMASR_IOC_IRQ    (1 << 12)   // IOC中断
#define DMASR_ERR_IRQ    (1 << 14)   // 错误中断
                         
// 描述符控制位          
#define CONTROL_RXEOF    (1 << 26)   // End of Frame
#define CONTROL_RXSOF    (1 << 27)   // Start of Frame

// 描述符状态位
#define STATUS_COMPLETED (1 << 31)  // 描述符已完成
#define STATUS_RXEOF     (1 << 26)  // 接收到EOF
#define STATUS_RXSOF     (1 << 27)  // 接收到SOF


// 描述符控制位
#define CONTROL_TXEOF  (1 << 26)   // End of Frame
#define CONTROL_TXSOF  (1 << 27)   // Start of Frame










#endif /* _AXIDMA_H_ */
