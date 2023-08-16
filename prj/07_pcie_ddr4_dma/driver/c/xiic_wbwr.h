
#include "xparameters.h"
#include "xiic.h"
#include "xil_io.h"
#include "xil_printf.h"

#define PAGE_SIZE	128
typedef u8 AddressType;

unsigned WishboneWriteByte   (UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u16 ByteCount);
unsigned WishboneReadByte    (UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u16 ByteCount);
u8       WishboneDynWriteByte(UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u8  ByteCount);
u8       WishboneDynReadByte (UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u8  ByteCount);




