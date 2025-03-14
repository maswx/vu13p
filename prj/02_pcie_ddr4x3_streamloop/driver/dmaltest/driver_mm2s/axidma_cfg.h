/*

你是一名Linux应用程序设计专家，熟悉Xilinx的PCIe/XDMA的Linux用户态驱动开发，现有一个PCIe的FPGA设备，FPGA中有一个AXI DMA模块以及附带一片DDR存储空间。

1. 编写一个mm2s的驱动程序将host端硬盘里的文件走pcie发送到FPGA内部的DDR作为缓存，然后再配置AXI DMA控制器将数据搬出即可:
1.1 首先要配置描述符：描述符的个数固定只有两个用于乒乓操作, 两个描述符将buffer 的大小MM2S_BUFFER_SIZE一分为2
1.2 在初始化阶段通过/dev/xdma0_h2c_0一次性写满buffer(基地址为MM2S_BUFFER_BASEADDR)
1.3 如果用户配置单次播放，则发完文件后就结束了，根据文件大小分情况处理：
1.3.1 如果文件小于等于MM2S_BUFFER_SIZE/2则将内容复制写入两个buffer，
1.3.2 否则如果文件小于等于MM2S_BUFFER_SIZE，前半MM2S_BUFFER_SIZE写入第一个buffer, 后半MM2S_BUFFER_SIZE写入第二个buffer;
1.3.3 否则文件大于buffer size，前半MM2S_BUFFER_SIZE写入第一个buffer, 后半MM2S_BUFFER_SIZE写入第二个buffer; 后续内容在中断中ping-pong填入, 这里配置cyclic BD Enable, 读完文件后配置cyclic BD disable

1.4 如果用户配置无限播放，则发完文件后自动回头继续发，根据文件大小分情况处理：无限播放模式固定配置cyclic BD Enable
1.4.1 如果文件小于等于MM2S_BUFFER_SIZE/2则将内容复制写入两个buffer，
1.4.2 否则如果文件小于等于MM2S_BUFFER_SIZE，前半MM2S_BUFFER_SIZE写入第一个buffer, 后半MM2S_BUFFER_SIZE写入第二个buffer;
1.4.3 否则文件大于buffer size，前半MM2S_BUFFER_SIZE写入第一个buffer, 后半MM2S_BUFFER_SIZE写入第二个buffer; 后续内容在中断中ping-pong填入


1.5 硬盘里的文件大小随机，可能是123Byte/1kB/1MB/1GB/10GB/100GB或者无限大(循环播放)

1.6 在中断中：对于单次播放的场景，读完文件就退出中断线程
1.7 在中断中：对于无限播放的场景，用户按下任意键就退出




一些额外的要求：
1. 避免使用全局变量，我希望做成动态库;
2. 注意AXI DMA控制器的启动顺序为：先配置 DMCSR_RS 再配置tail desc才能启动
3. 访问空间open(/dev/xdma0_user)后在做mmap时直接指定偏移地址DMA_DESC_BASE_ADDR和device的偏移地址DMA_DEV_BASE_ADDR, 这两个空间可以使用指针访问
4. 配置描述符时，应当优雅地使用memset()
6. 访问/dev/xdma0_h2c_0 时，只能通过write操作
7. 此外，额外编写一个API函数，允许用户通过动态库调用此函数将数据流从内存中传输，而不是读取文件。
8. 合理地区分好axidma_mm2s.h/axidma_mm2s.c文件,并且额外写一个play_test.c测试文件, 一个调用动态库的play_test_so.c , 以及一个Makefile


一些坑：
1. XILINX的AXIDMA完全不支持数据流的模式，仅仅支持包模式，如果强行要发送背靠背数据包，那么AXI-DMA坑会非常多。
2. 首先BD Cyclic Enable 的意思不是让描述符循环起来构成链表，而是让其无视描述符中的完成信号，使得描述符可以重复使用。
3. 如果要配置多个描述符，形成循环链，则需要中中断中重启描述符
4. xilinx 的AXI DMA 仅仅适用于包模式！！！！！

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


#endif /* _AXIDMA_CFG_H_ */



