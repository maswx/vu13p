
/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xiic.h"
#include "xil_io.h"
#include "xil_printf.h"

#define PAGE_SIZE	64
#define EEPROM_TEST_START_ADDRESS	128


/**************************** Type Definitions *******************************/

/*
 * The AddressType for ML300/ML310/ML510 boards should be u16 as the address
 * pointer in the on board EEPROM is 2 bytes.
 * The AddressType for ML403/ML501/ML505/ML507/ML605/SP601/SP605 boards should
 * be u8 as the address pointer in the on board EEPROM is 1 bytes.
 */
typedef u8 AddressType;



int IicLowLevelEeprom();

int ReadWriteVerify(AddressType Address);

unsigned EepromWriteByte(AddressType Address, u8 *BufferPtr, u16 ByteCount);

unsigned EepromReadByte(AddressType Address, u8 *BufferPtr, u16 ByteCount);

/************************** Variable Definitions **************************/



u8 EepromIicAddr;		  /* Variable for storing Eeprom IIC address */


/*****************************************************************************/
/**
* This function writes a buffer of bytes to the IIC serial EEPROM.
*
* @param	Address contains the address in the EEPROM to write to.
* @param	BufferPtr contains the address of the data to write.
* @param	ByteCount contains the number of bytes in the buffer to be written.
*		Note that this should not exceed the page size of the EEPROM as
*		noted by the constant PAGE_SIZE.
*
* @return	The number of bytes written, a value less than that which was
*		specified as an input indicates an error.
*
* @note		None.
*
****************************************************************************/
unsigned EepromWriteByte(UINTPTR IIC_BASE_ADDRESS, AddressType Address, u8 *BufferPtr, u16 ByteCount)
{
	volatile unsigned SentByteCount;
	volatile unsigned AckByteCount;
	u8 WriteBuffer[sizeof(Address) + PAGE_SIZE];
	int Index;
	u32 CntlReg;

	/*
	 * A temporary write buffer must be used which contains both the address
	 * and the data to be written, put the address in first based upon the
	 * size of the address for the EEPROM.
	 */
	if (sizeof(AddressType) == 2) {
		WriteBuffer[0] = (u8)(Address >> 8);
		WriteBuffer[1] = (u8)(Address);
	} else if (sizeof(AddressType) == 1) {
		WriteBuffer[0] = (u8)(Address);
		EepromIicAddr |= (EEPROM_TEST_START_ADDRESS >> 8) & 0x7;
	}

	/*
	 * Put the data in the write buffer following the address.
	 */
	for (Index = 0; Index < ByteCount; Index++) {
		WriteBuffer[sizeof(Address) + Index] = BufferPtr[Index];
	}

	/*
	 * Set the address register to the specified address by writing
	 * the address to the device, this must be tried until it succeeds
	 * because a previous write to the device could be pending and it
	 * will not ack until that write is complete.
	 */
	do {
		SentByteCount = XIic_Send(IIC_BASE_ADDRESS,
					EepromIicAddr,
					(u8 *)&Address, sizeof(Address),
					XIIC_STOP);
		if (SentByteCount != sizeof(Address)) {

			/* Send is aborted so reset Tx FIFO */
			CntlReg = XIic_ReadReg(IIC_BASE_ADDRESS,
						XIIC_CR_REG_OFFSET);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					XIIC_CR_ENABLE_DEVICE_MASK);
		}

	} while (SentByteCount != sizeof(Address));

	/*
	 * Write a page of data at the specified address to the EEPROM.
	 */
	SentByteCount = XIic_Send(IIC_BASE_ADDRESS, EepromIicAddr,
				  WriteBuffer, sizeof(Address) + PAGE_SIZE,
				  XIIC_STOP);

	/*
	 * Wait for the write to be complete by trying to do a write and
	 * the device will not ack if the write is still active.
	 */
	do {
		AckByteCount = XIic_Send(IIC_BASE_ADDRESS, EepromIicAddr,
					(u8 *)&Address, sizeof(Address),
					XIIC_STOP);
		if (AckByteCount != sizeof(Address)) {

			/* Send is aborted so reset Tx FIFO */
			CntlReg = XIic_ReadReg(IIC_BASE_ADDRESS,
					XIIC_CR_REG_OFFSET);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					XIIC_CR_ENABLE_DEVICE_MASK);
		}

	} while (AckByteCount != sizeof(Address));


	/*
	 * Return the number of bytes written to the EEPROM
	 */
	return SentByteCount - sizeof(Address);
}

/*****************************************************************************/
/**
* This function reads a number of bytes from the IIC serial EEPROM into a
* specified buffer.
*
* @param	Address contains the address in the EEPROM to read from.
* @param	BufferPtr contains the address of the data buffer to be filled.
* @param	ByteCount contains the number of bytes in the buffer to be read.
*		This value is not constrained by the page size of the device
*		such that up to 64K may be read in one call.
*
* @return	The number of bytes read. A value less than the specified input
*		value indicates an error.
*
* @note		None.
*
****************************************************************************/
unsigned EepromReadByte(UINTPTR IIC_BASE_ADDRESS, AddressType Address, u8 *BufferPtr, u16 ByteCount)
{
	volatile unsigned ReceivedByteCount;
	u16 StatusReg;
	u32 CntlReg;

	/*
	 * Set the address register to the specified address by writing
	 * the address to the device, this must be tried until it succeeds
	 * because a previous write to the device could be pending and it
	 * will not ack until that write is complete.
	 */
	do {
		StatusReg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
		if(!(StatusReg & XIIC_SR_BUS_BUSY_MASK)) {
			ReceivedByteCount = XIic_Send(IIC_BASE_ADDRESS,
							EepromIicAddr,
							(u8 *)&Address,
							sizeof(Address),
							XIIC_STOP);

			if (ReceivedByteCount != sizeof(Address)) {

				/* Send is aborted so reset Tx FIFO */
				CntlReg = XIic_ReadReg(IIC_BASE_ADDRESS,
							XIIC_CR_REG_OFFSET);
				XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
						CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
				XIic_WriteReg(IIC_BASE_ADDRESS,
						XIIC_CR_REG_OFFSET,
						XIIC_CR_ENABLE_DEVICE_MASK);
			}
		}

	} while (ReceivedByteCount != sizeof(Address));

	/*
	 * Read the number of bytes at the specified address from the EEPROM.
	 */
	ReceivedByteCount = XIic_Recv(IIC_BASE_ADDRESS, EepromIicAddr,
					BufferPtr, ByteCount, XIIC_STOP);

	/*
	 * Return the number of bytes read from the EEPROM.
	 */
	return ReceivedByteCount;
}
