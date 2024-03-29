#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdarg.h>
#include "alex_iic.h"

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


u32 gpio_set_data(uintptr_t baseaddr, u32 data);


int main(void) {
    int axilte;
	u16 readback[1];
	void *iic_t;
	void *gpio_t;

    // 打开设备文件
    axilte = open("/dev/xdma0_user", O_RDWR | O_SYNC);//axi lite设备
    if (axilte == -1) {
        perror("Failed to open device");
		close(axilte);
        return -1;
    }

    // 映射设备文件到内存
	iic_t = mmap(NULL, 65536, PROT_READ | PROT_WRITE, MAP_SHARED, axilte, 0x00800000);
    if (iic_t == MAP_FAILED) {
        perror("Failed to map memory");
		close(axilte);
        return -1;
    }
	uintptr_t alex_iic = (uintptr_t) iic_t;
	gpio_t     = mmap(NULL, 65536, PROT_READ | PROT_WRITE, MAP_SHARED, axilte, 0x00840000);
    if (gpio_t  == MAP_FAILED) {
        perror("Failed to map memory");
		close(axilte);
        return -1;
    }
	uintptr_t gpio = (uintptr_t) gpio_t     ;
	
	gpio_set_data(gpio, 0x3);
	gpio_set_data(gpio, 0x0);
	
	// 尝试访问 
	for(int i = 0; i < 16; i++)
	{
		alex_iic_wb_read (alex_iic , 0x00, i, &readback[i]);
		printf("readback = %d\n", readback[i]);
	}
	
    munmap(iic_t  , 65536);
    munmap(gpio_t , 65536);
    close(axilte);

    return 0;
}


u32 gpio_set_data(uintptr_t baseaddr, u32 data)
{
    volatile u32 *LocalAddr = (volatile u32 *)(baseaddr);
    *LocalAddr = data;
	return 0;
}




