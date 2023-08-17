#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdarg.h>
#include "xparameters.h"
#include "xiic_l.h"
#include "xiic.h"
#include "xiic_wbwr.h"

// FIR 的系数初值:	coeff_00 <= 16'd54    ;
// FIR 的系数初值:	coeff_01 <= 16'd159   ;
// FIR 的系数初值:	coeff_02 <= 16'd344   ;
// FIR 的系数初值:	coeff_03 <= 16'd671   ;
// FIR 的系数初值:	coeff_04 <= 16'd1198  ;
// FIR 的系数初值:	coeff_05 <= 16'd1970  ;
// FIR 的系数初值:	coeff_06 <= 16'd3009  ;
// FIR 的系数初值:	coeff_07 <= 16'd4314  ;
// FIR 的系数初值:	coeff_08 <= 16'd5856  ;
// FIR 的系数初值:	coeff_09 <= 16'd7574  ;
// FIR 的系数初值:	coeff_10 <= 16'd9386  ;
// FIR 的系数初值:	coeff_11 <= 16'd11189 ;
// FIR 的系数初值:	coeff_12 <= 16'd12871 ;
// FIR 的系数初值:	coeff_13 <= 16'd14321 ;
// FIR 的系数初值:	coeff_14 <= 16'd15438 ;
// FIR 的系数初值:	coeff_15 <= 16'd16143 ;
// FIR 的系数初值:	coeff_16 <= 16'd16384 ;
// FIR 的系数初值:	coeff_17 <= 16'd16143 ;
// FIR 的系数初值:	coeff_18 <= 16'd15438 ;
// FIR 的系数初值:	coeff_19 <= 16'd14321 ;
// FIR 的系数初值:	coeff_20 <= 16'd12871 ;
// FIR 的系数初值:	coeff_21 <= 16'd11189 ;
// FIR 的系数初值:	coeff_22 <= 16'd9386  ;
// FIR 的系数初值:	coeff_23 <= 16'd7574  ;
// FIR 的系数初值:	coeff_24 <= 16'd5856  ;
// FIR 的系数初值:	coeff_25 <= 16'd4314  ;
// FIR 的系数初值:	coeff_26 <= 16'd3009  ;
// FIR 的系数初值:	coeff_27 <= 16'd1970  ;
// FIR 的系数初值:	coeff_28 <= 16'd1198  ;
// FIR 的系数初值:	coeff_29 <= 16'd671   ;
// FIR 的系数初值:	coeff_30 <= 16'd344   ;
// FIR 的系数初值:	coeff_31 <= 16'd159   ;
// FIR 的系数初值:	coeff_32 <= 16'd54    ;

#define IIC_DEV_ADDR 0x00

off_t base_offset = 0x00800000;  // 基地址的偏移量
size_t mapping_size = 64 * 1024; // 映射的大小，64K

int reset_fir_module(UINTPTR baseaddr);


int main(void) {
    int axilte;
	int i;
    void *mapped_base;
	UINTPTR base_address;
	u8 rxdata[16];
	u8 txdata[16];

	for(i = 0; i < 16; i++)
	{
		rxdata[i] = 0;
		txdata[i] = 0;
	}

    // 打开设备文件
    axilte = open("/dev/xdma0_user", O_RDWR | O_SYNC);//axi lite设备
    if (axilte == -1) {
        perror("Failed to open device");
		close(axilte);
        return -1;
    }

    // 映射设备文件到内存
	mapped_base = mmap(NULL, mapping_size, PROT_READ | PROT_WRITE, MAP_SHARED, axilte, base_offset);
    if (mapped_base == MAP_FAILED) {
        perror("Failed to map memory");
		close(axilte);
        return -1;
    }

    // 将映射的地址转换为指定类型的指针
    base_address = (UINTPTR)mapped_base;
	// 复位模块
	reset_fir_module(base_address);


    // 使用 base_address 进行操作
	unsigned readbyte ;
	AddressType wishboneAddr = 0x00;
	u16 ByteCount = 2;
	printf("begin wishbone read\n");
	//readbyte = WishboneReadByte(base_address, IIC_DEV_ADDR , wishboneAddr, rxdata, ByteCount);
	readbyte = XIic_Recv(base_address, IIC_DEV_ADDR , rxdata, 2, XIIC_STOP);


	printf("readbyte=%x\n", readbyte);
	for(i = 0; i < 16; i++)
		printf("rxdata[%d]=%x\n", i , rxdata[i]);

    // 解除内存映射并关闭文件
    munmap(mapped_base, mapping_size);
    close(axilte);

    return 0;
}

int reset_fir_module(UINTPTR baseaddr)
{
	usleep(10);
	Xil_Out32(baseaddr + 0x00000124, 0x00000000);
	usleep(100);
	Xil_Out32(baseaddr + 0x00000124, 0x000000ff);
	return 0;
}

