
#include "xiic.h"

int Single_Cell_Read(UINTPTR XPAR_AXI_IIC_0_BASEADDR,  u8 Device_ID, u8 regaddr,u16 *readback);
int wishbone_read(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *buffer);
int wishbone_write(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *buffer);
void Initialization_IIC(UINTPTR baseaddr) ;