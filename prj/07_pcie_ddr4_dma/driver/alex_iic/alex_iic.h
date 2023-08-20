//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年08月20日 星期日 23时25分15秒
//========================================================================

#ifndef __ALEX_IIC_H__
#define __ALEX_IIC_H__


#include <stdint.h>
#include <stddef.h>

typedef int8_t   s8 ;
typedef int16_t  s16;
typedef int32_t  s32;
typedef int64_t  s64;
typedef uint8_t  u8 ;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

//typedef intptr_t INTPTR;
//typedef uintptr_t UINTPTR;


#define ALEX_MASK_BUSY      0x00000001//当模块正在执行 I2C 操作时为高
#define ALEX_MASK_BUS_CONT  0x00000002//当模块控制活动总线时为高
#define ALEX_MASK_BUS_ACT   0x00000004//总线活动时为高
#define ALEX_MASK_MISS_ACK  0x00000008//当来自从设备的 ACK 脉冲未被检测到时设置为高；写入 1 来清除
#define ALEX_MASK_CMD_EMPTY 0x00000100//命令 FIFO 为空
#define ALEX_MASK_CMD_FULL  0x00000200//命令 FIFO 满
#define ALEX_MASK_CMD_OVF   0x00000400//命令 FIFO 溢出；写入 1 来清除
#define ALEX_MASK_WR_EMPTY  0x00000800//写入数据 FIFO 为空
#define ALEX_MASK_WR_FULL   0x00001000//写入数据 FIFO 满
#define ALEX_MASK_WR_OVF    0x00002000//写入数据 FIFO 溢出；写入 1 来清除
#define ALEX_MASK_RD_EMPTY  0x00004000//读取数据 FIFO 为空
#define ALEX_MASK_RD_FULL   0x00008000//读取数据 FIFO 满


#define ALEX_CMD_START          0x00000100 //：设置为高以发出 I2C 启动，写入以将其推入命令 FIFO
#define ALEX_CMD_READ           0x00000200 //：设置为高以开始读取，写入以将其推入命令 FIFO
#define ALEX_CMD_WRITE          0x00000400 //：设置为高以开始写入，写入以将其推入命令 FIFO
#define ALEX_CMD_WRITE_MULTIPLE 0x00000800 //：设置为高以开始块写入，写入以将其推入命令 FIFO
#define ALEX_CMD_STOP           0x00000100 //：设置为高以发出 I2C 停止，写入以将其推入命令 FIFO

#define ALEX_DATA_VALID         0x00000100 //：表示有效的读取数据，必须使用原子 16 位读取和写入访问
#define ALEX_DATA_LAST          0x00000200 //：指示块写入（write_multiple）的最后一个字节，必须使用原子 16 位读取和写入访问



u32 alex_read_status(uintptr_t baseaddr);
u32 alex_get_command(uintptr_t baseaddr);
u32 alex_set_command(uintptr_t baseaddr, u32 cmd);
u32 alex_get_fifo(uintptr_t baseaddr);
u32 alex_put_fifo(uintptr_t baseaddr, u32 data);

int alex_iic_wb_read (uintptr_t baseaddr, u8 iicaddr, u8 regaddr, u16 *readback);
int alex_iic_wb_write(uintptr_t baseaddr, u8 iicaddr, u8 regaddr, u16 *readback);

#endif
