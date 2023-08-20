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

void Initialization_IIC(UINTPTR baseaddr) 
{
	Xil_Out32(baseaddr + XIIC_RFD_REG_OFFSET, 0x0000000f);//Set the RX_FIFO depth
	Xil_Out32(baseaddr + XIIC_CR_REG_OFFSET, Xil_In32(baseaddr + XIIC_CR_REG_OFFSET)|0x00000002);//Reset the TX_FIFO
	Xil_Out32(baseaddr + XIIC_CR_REG_OFFSET, Xil_In32(baseaddr + XIIC_CR_REG_OFFSET)|0x00000001);//Enable the AXI IIC
	Xil_Out32(baseaddr + XIIC_CR_REG_OFFSET, Xil_In32(baseaddr + XIIC_CR_REG_OFFSET)&0xfffffffd);//Remove the TX_FIFO reset
	Xil_Out32(baseaddr + XIIC_CR_REG_OFFSET, Xil_In32(baseaddr + XIIC_CR_REG_OFFSET)&0xffffffbf);//Disable the general call
	printf("Initialization_IIC Device finished.\n\r");
}

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
	readback[0] = 0;
	u16 buffer[16];
	int i = 0;
	for(i = 0; i < 16; i++)
		buffer[i] = 0;

	// TX_FIFO的地址为 baseaddr + 0x108 
	// 写入fifo前先清空FIFO
	// 1. 写入控制字 + START
	// 2. 写入地址
	// 3. 写入控制字 + RSTART
	// 4. 写入读数据数量 + STOP
	// 5. 启动发送
	// 首先要清除相关寄存器
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000002);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000000);
		printf("-----clear OK SR = 0x%x------\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) );
	printf("-----bus not busy 0x114 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x114) );
	printf("-----bus not busy 0x118 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x118) );
	printf("-----bus not busy 0x120 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x120) );
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000100 | iicaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000000 | regaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000101 | iicaddr);
	XIic_WriteReg(baseaddr, XIIC_DTR_REG_OFFSET, 0x00000202);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000025);
		printf("-----set begin OK SR = 0x%x------\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) );
	// 启动后读取 SR寄存器，在10ms 内返回 0x80则退出，并返回成功。如果超时则返回失败。
	int timeout = 0;
	while (timeout < 50000)
	{
		printf("SR = 0x%x\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) );
		if ((XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x88) == 0x88)
			break;
		usleep(5000);
		timeout++;
	}
	//if (timeout > 4)
	//	return -1;//IIC 发送超时失败

	printf("-----bus not busy SR = 0x%x------\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) );
	printf("-----bus not busy 0x114 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x114) );
	printf("-----bus not busy 0x118 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x118) );
	printf("-----bus not busy 0x120 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x120) );
	//--timeout = 0;
	//while (timeout < 50)
	i = 0;
	while(1)
	{
		if ((XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x40) == 0x40)
		{
			printf("SR = %x, b[0]=%x,b1=%x, i = %d \n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET), buffer[0], buffer[1],i);
			//XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000000);
			//if ((XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x08) == 0x00)
			break;
		}
		else
			buffer[i++] = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
		//if(i == 3)
		//	break;
		//usleep(1000);
		//timeout++;
	}
		usleep(10);
	printf("-----bus not busy SR = 0x%x------\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) );
	printf("-----bus not busy 0x114 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x114) );
	printf("-----bus not busy 0x118 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x118) );
	printf("-----bus not busy 0x120 = 0x%x------\n", XIic_ReadReg(baseaddr, 0x120) );
	for(i = 0; i < 16; i++)
		printf("buffer[%d] = %x\n",i,buffer[i]);
	readback[0] = buffer[0] | buffer[1] << 8;
	//--if (timeout > 4)
	//--	return -3;//IIC 发送超时失败


	//---//XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000000);
	//---//从RX FIFO 中读取2个数据，直到SR寄存器中RX_FIFO_EMPTY为1。
	//---//int i = 0;
	//---usleep(10000);
	//---u16 lsb = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
	//---usleep(10000);
	//---u16 msb = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
	//---usleep(10000);
	//---//while(!(XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET) & 0x40))
	//---//{
	//---//	printf("SR = %x\n", XIic_ReadReg(baseaddr, XIIC_SR_REG_OFFSET));
	//---//	buffer[0] = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
	//---//	buffer[1] = XIic_ReadReg(baseaddr, XIIC_DRR_REG_OFFSET);
	//---//	//if(i == 17)
	//---//	//	break;
	//---//}
	//---//if (i == 16)
	//---//	return -2; // 读取FIFO 失败
	//---//printf("timeout=%d ,i=%d,   ", timeout, i);
	//---printf("buff[0]=%d ,  ", lsb);
	//---printf("buff[1]=%d  \n", msb);
	//---readback[0] = lsb | msb << 8;
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
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000007);
	XIic_WriteReg(baseaddr, XIIC_CR_REG_OFFSET , 0x00000005);

	return 0;
}

int Single_Cell_Read(UINTPTR XPAR_AXI_IIC_0_BASEADDR,  u8 Device_ID, u8 regaddr,u16 *readback)
{
	readback[0] = 0;
	u16 Received_data[16];
	int i = 0;
	while((Xil_In32(XPAR_AXI_IIC_0_BASEADDR + XIIC_SR_REG_OFFSET) & 0x000000C4) != 0x000000c0) {}//Check that all FIFOs are empty and that the bus is not busy by reading the Status register
	Xil_Out32(XPAR_AXI_IIC_0_BASEADDR + XIIC_DTR_REG_OFFSET, (Device_ID<<1)|0x00000100);//Write 0x___ to the TX_FIFO (set the start bit, the device address, write access)
	Xil_Out32(XPAR_AXI_IIC_0_BASEADDR + XIIC_DTR_REG_OFFSET, regaddr);//Write 0x__ to the TX_FIFO (slave address for data)
	Xil_Out32(XPAR_AXI_IIC_0_BASEADDR + XIIC_DTR_REG_OFFSET, (Device_ID<<1)|0x00000101);//Write 0x___ to the TX_FIFO (set start bit, device address to 0x__, read access)
	Xil_Out32(XPAR_AXI_IIC_0_BASEADDR + XIIC_DTR_REG_OFFSET, 0x00000201);//Write 0x___ to the TX_FIFO (set stop bit, four bytes to be received by the AXI IIC)
	while((Xil_In32(XPAR_AXI_IIC_0_BASEADDR + XIIC_SR_REG_OFFSET) & 0x00000040) == 0x00000040) {}//Wait until the RX_FIFO is not empty.
	while((Xil_In32(XPAR_AXI_IIC_0_BASEADDR + XIIC_SR_REG_OFFSET) & 0x00000040) != 0x00000040){
		Received_data[i++] = Xil_In32(XPAR_AXI_IIC_0_BASEADDR + XIIC_DRR_REG_OFFSET);
	}
	readback[0] = Received_data[0] | Received_data[1] << 8;
	return 0;
}