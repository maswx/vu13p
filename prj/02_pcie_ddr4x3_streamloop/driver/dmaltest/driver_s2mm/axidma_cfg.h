/*

你是一名Linux应用程序设计专家，熟悉Xilinx的PCIe/XDMA的Linux用户态驱动开发，现有一个PCIe的FPGA设备，FPGA中有一个AXI DMA模块以及附带一片DDR存储空间。

帮我写一个 AXI DMA的驱动，这个硬件设备通过字符设备BAR_SPACE_FD偏移DMA_DEV_BASE_ADDR访问。
固定配置4个描述符，并配置成环形描述符，将S2MM_BUFFER_SIZE 一分为4，构建4个缓冲区，并使能IOC中断。
创建额外的线程处理中断，在中断中清除中断标志，并依次轮询描述符的status&0x80000000,如果描述符完成，则并提交额外的工作队列，通过 C2H0_BUFFER_FD 读取buffer中的内容，并写入文件


一些额外的要求：
1. 避免使用全局变量，我希望做成动态库;
2. 注意AXI DMA控制器的启动顺序为：先配置 DMCSR_RS 再配置tail desc才能启动
3. 访问空间open(/dev/xdma0_user)后在做mmap时直接指定偏移地址DMA_DESC_BASE_ADDR和device的偏移地址DMA_DEV_BASE_ADDR, 这两个空间可以使用指针访问
4. 配置描述符时，应当优雅地使用memset()
8. 合理地区分好axidma_s2mm.h/axidma_s2mm.c文件,并且额外写一个recv_test.c测试文件, 一个调用动态库的recv_test_so.c , 以及一个Makefile



*/


#ifndef _AXIDMA_CFG_H_
#define _AXIDMA_CFG_H_ 

// 设备文件路径
#define BAR_SPACE_FD    "/dev/xdma0_user"
#define C2H0_BUFFER_FD  "/dev/xdma0_c2h_0"
#define H2C0_BUFFER_FD  "/dev/xdma0_h2c_0"
#define MM2S_INTERP_FD  "/dev/xdma0_events_2"
#define S2MM_INTERP_FD  "/dev/xdma0_events_3"

// 物理地址定义
#define DMA_DESC_BASE_ADDR 0x30000  // DMA描述符物理基地址
#define DMA_DESC_ALL_SIZE  0x10000  // 描述符存储空间的大小
#define DMA_DEV_BASE_ADDR  0x50000  // AXI DMA 设备的物理地址,大小固定为64k

// 缓冲区和传输大小定义
#define MM2S_BUFFER_BASEADDR 0x000000000
#define MM2S_BUFFER_SIZE     0x100000000


// 缓冲区和传输大小定义
#define S2MM_BUFFER_BASEADDR 0x100000000        // 
#define S2MM_BUFFER_SIZE     (128 * 1024 * 1024)  // 128MB








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



// DMA状态寄存器位定义
#define DMASR_DLY_IRQ  0x2000  // 延迟中断





#endif /* _AXIDMA_CFG_H_ */



