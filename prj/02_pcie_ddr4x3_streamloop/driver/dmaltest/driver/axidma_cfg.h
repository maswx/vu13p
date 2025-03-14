/* 
你是一名Linux应用程序设计专家，熟悉Xilinx的PCIe/XDMA的Linux用户态驱动开发，现有一个PCIe的FPGA设备，FPGA中有一个AXI DMA模块以及附带一片DDR存储空间。

1. 编写一个mm2s的驱动程序将host端硬盘里的文件走pcie发送到FPGA内部的DDR作为缓存，然后再配置AXI DMA控制器将数据搬出即可:
1.1 首先要配置描述符：描述符的个数就是固定的 MM2S_DESC_COUNT，将描述串成一个循环链表，每个描述符可以DMA大小为MM2S_ONE_PACKET_SIZE的数据，总buffer固定为MM2S_BUFFER_SIZE      
1.2 在初始化阶段通过/dev/xdma0_h2c_0一次性写满buffer(基地址为MM2S_BUFFER_BASEADDR)
1.3 待发送的文件一定小于 MM2S_BUFFER_SIZE, 否则提示不支持，并建议加大buffer
1.3.1 如果文件size小于等于1个包的大小 MM2S_ONE_PACKET_SIZE, 注意配置正确的size， 启动DMA时, 如果是单次播放，配置起始/结尾描述符且播放一次就可以；如果用户配置无限播放，则开启cyclic BD Enable
1.3.2 如果文件size大于1个包的大小且小于等于总buffer大小，则也可直接填满buffer, 在启动DMA时，配置起始/结束描述符的位置。如果用户需要配置无限播放，则，则开启cyclic BD Enable
1.4 如果用户按下了结束键, 则配置 cyclic BD disable 也就是结束循环描述符，等待DMA控制器将buffer里的内容发完;确认数据都发完了之后，才关闭DMA

一些额外的要求：
1. 避免使用全局变量，我希望做成动态库;
2. 注意AXI DMA控制器的启动顺序为：先配置 DMCSR_RS 再配置tail desc才能启动
3. 访问空间open(/dev/xdma0_user)后在做mmap时直接指定偏移地址DMA_DESC_BASE_ADDR和device的偏移地址DMA_DEV_BASE_ADDR, 访问这两片空间时，应当优雅地使用指针结构体指向这两片空间
4. 配置描述符时，应当优雅地使用memset()
6. 访问/dev/xdma0_h2c_0 时，只能通过write操作
7. 此外，额外编写一个API函数，允许用户通过动态库调用此函数将数据流从内存中传输，而不是读取文件。
8. 合理地区分好axidma_mm2s.h/axidma_mm2s.c文件,并且额外写一个play_test.c测试文件, 一个调用动态库的play_test_so.c , 以及一个Makefile

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
#define MM2S_BUFFER_SIZE      (4ULL * 1024 * 1024 * 1024)  // 4GB
#define MM2S_DESC_COUNT       (DMA_DESC_ALL_SIZE/64/2  )   // 最大描述符数量, 64是一个描述符的大小，2是S2MM/MM2S各占一半
#define MM2S_ONE_PACKET_SIZE  (MM2S_BUFFER_SIZE/MM2S_DESC_COUNT)


// 缓冲区和传输大小定义
#define S2MM_BUFFER_BASEADDR 0x100000000        // 
#define S2MM_BUFFER_SIZE     (128 * 1024 * 1024)  // 128MB
#define S2MM_WORK_QUEUE      32                   // DMA到上位机的工作队列大小







#endif /* _AXIDMA_CFG_H_ */



