/***************************** Include Files *********************************/
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdarg.h>
#include "xiic.h"

#include "lib_wbwr.h"

// 定义wishbone读写函数。
// 读函数
// 将数据buffer写入TX_FIFO
// 寄存器	值	说明
// TX_FIFO	000001A0	写控制字 + START
// TX_FIFO	00000000	地址8位
// TX_FIFO	000001A1	读控制字 + RSTART
// TX_FIFO	00000205	读数据数量 + STOP
// CR	00000025	启动发送

int wishbone_read(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *readback)
{
	// TX_FIFO的地址为 baseaddr + 0x108 
	// 写入fifo前先清空FIFO
	// 1. 写入控制字 + START
	// 2. 写入地址
	// 3. 写入控制字 + RSTART
	// 4. 写入读数据数量 + STOP
	// 5. 启动发送
	// 首先要清除相关寄存器
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000100 | iicaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000000 | regaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000101 | iicaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000202);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000025);
	// 启动后读取 SR寄存器，在10ms 内返回 0x80则退出，并返回成功。如果超时则返回失败。
	int timeout = 0;
	while (timeout < 10)
	{
		if (XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x80)
		{
			break;
		}
		usleep(1000);
		timeout++;
	}
	if (timeout == 10)
	{
		return -1;//IIC 发送超时失败
	}
	//从RX FIFO 中读取2个数据，直到SR寄存器中RX_FIFO_EMPTY为1。
	int i = 0;
	u8 buffer[16];
	while(!(XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x40))
	{
		buffer[i++] = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
		if(i == 16)
			break;
	}
	if (i == 16)
		return -2; // 读取FIFO 失败
	printf("timeout=%d ,i=%d,   ", timeout, i);
	printf("buff[0]=%d ,  ", buffer[0]);
	printf("buff[1]=%d  \n", buffer[1]);
	readback[0] = buffer[0] | buffer[1] << 8;
	// 结束后清空FIFO
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000002);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000000);
	return 0;
}
int wishbone_write(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *buffer)
{
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000100 | iicaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000000 | regaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000000 | buffer[0] >> 8);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000200 | buffer[0]);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x0000000D); //启动发送
	//接下来读取SR，判断TX_FIFO是否为空（0000_00C0）。同样采用超时机制，超时时间为10ms。
	int timeout = 0;
	while (timeout < 10)
	{
		if (XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x80)
			break;
		usleep(1000);
		timeout++;
	}
	if (timeout == 10)
		return -1;//IIC 发送超时失败
	// 结束后清空FIFO
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000002);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000000);

	return 0;
}