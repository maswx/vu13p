/*
描述符保存的基地址为0x30000, 大小64kB, 低32kB用于保存S2MM的描述符，高32kB用于保存MM2S的描述符;它可以通过字符设备/dev/xdma0_user访问。
另外 AXI_DMA控制器的寄存器空间可以通过字符设备/dev/xdma0_user 的地址 0x20000访问

1. 编写一个mm2s的驱动程序：
DMA可访问的空间为 MM2S_BUFFER_SIZE 这是 一个默认4GB大小的空间。
硬盘中存在一个10～100GB大小的文件，在初始化阶段一次性写满buffer（通过 /dev/xdma0_h2c_0访问）, 然后配置DMA 周期性地以每次 MM2S_ONE_PACKET_SIZE = 16MB的数据搬运出来
搬运完一次后触发中断（通过字符设备/dev/xdma0_events_1），然后再填满第一个buffer, 依次反复，直到发完文件。
1.1 一些特殊情况
如果文件小于MM2S_BUFFER_SIZE, 当然填满后就无需再次动态写入了。此时都无需配置Cyclic BD Enable
如果文件更小于MM2S_ONE_PACKET_SIZE ，则只需要一个描述符即可。

2. 编写一个s2mm的驱动程序：
DMA可访问的另一片空间为 S2MM_BUFFER_SIZE 这是 一个通过define定义的默认128MB大小的空间。
配完所有 DMA 描述符，将BUFFER平均分配给所有描述符，并且固定使能Cyclic BD Enable， 以此构建一个环形buffer。
配置中断函数，在中断函数中，一次性读回S2MM描述符的内容，找到帧开始到帧结束的已完成的描述符中对应buffer(这里应当注意避免重复查询), 
并将buffer中的内容通过字符设备/dev/xdma0_c2h_0读回主机。
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
#define MM2S_BUFFER_BASEADDR 0x0_0000_0000
#define MM2S_BUFFER_SIZE     (4ULL * 1024 * 1024 * 1024)  // 4GB
#define MM2S_ONE_PACKET_SIZE      (16 * 1024 * 1024)           // 16MB
#define MAX_DESC_COUNT       (DMA_DESC_ALL_SIZE/64/2)   // 最大描述符数量, 64是一个描述符的大小，2是S2MM/MM2S各占一半


// 缓冲区和传输大小定义
#define S2MM_BUFFER_BASEADDR 0x1_0000_0000        // 
#define S2MM_BUFFER_SIZE     (128 * 1024 * 1024)  // 128MB
#define S2MM_WORK_QUEUE      32                   // DMA到上位机的工作队列大小







#endif /* _AXIDMA_CFG_H_ */



