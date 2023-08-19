
#include "xiic.h"

int wishbone_read(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *buffer);
int wishbone_write(UINTPTR baseaddr, u8 iicaddr, u8 regaddr, u16 *buffer);