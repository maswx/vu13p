
/***************************** Include Files *********************************/

#include "xiic_wbwr.h"


/*****************************************************************************/
/**
* This function writes a buffer of bytes to the IIC serial EEPROM.
*
* @param	wishboneAddr contains the address in the EEPROM to write to.
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
unsigned WishboneWriteByte(UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u16 ByteCount)
{
	volatile unsigned SentByteCount;
	volatile unsigned AckByteCount;
	u8 WriteBuffer[sizeof(wishboneAddr) + PAGE_SIZE];
	int Index;
	u32 CntlReg;

	/*
	 * A temporary write buffer must be used which contains both the address
	 * and the data to be written, put the address in first based upon the
	 * size of the address for the EEPROM.
	 */
	if (sizeof(AddressType) == 2) {
		WriteBuffer[0] = (u8)(wishboneAddr >> 8);
		WriteBuffer[1] = (u8)(wishboneAddr);
	} else if (sizeof(AddressType) == 1) {
		WriteBuffer[0] = (u8)(wishboneAddr);
	}

	/*
	 * Put the data in the write buffer following the address.
	 */
	for (Index = 0; Index < ByteCount; Index++) {
		WriteBuffer[sizeof(wishboneAddr) + Index] = BufferPtr[Index];
	}

	/*
	 * Set the address register to the specified address by writing
	 * the address to the device, this must be tried until it succeeds
	 * because a previous write to the device could be pending and it
	 * will not ack until that write is complete.
	 */
	do {
		SentByteCount = XIic_Send(IIC_BASE_ADDRESS,
					IICAddr,
					(u8 *)&wishboneAddr, sizeof(wishboneAddr),
					XIIC_STOP);
		if (SentByteCount != sizeof(wishboneAddr)) {

			/* Send is aborted so reset Tx FIFO */
			CntlReg = XIic_ReadReg(IIC_BASE_ADDRESS,
						XIIC_CR_REG_OFFSET);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					XIIC_CR_ENABLE_DEVICE_MASK);
		}

	} while (SentByteCount != sizeof(wishboneAddr));

	/*
	 * Write a page of data at the specified address to the EEPROM.
	 */
	SentByteCount = XIic_Send(IIC_BASE_ADDRESS, IICAddr,
				  WriteBuffer, sizeof(wishboneAddr) + PAGE_SIZE,
				  XIIC_STOP);

	/*
	 * Wait for the write to be complete by trying to do a write and
	 * the device will not ack if the write is still active.
	 */
	do {
		AckByteCount = XIic_Send(IIC_BASE_ADDRESS, IICAddr,
					(u8 *)&wishboneAddr, sizeof(wishboneAddr),
					XIIC_STOP);
		if (AckByteCount != sizeof(wishboneAddr)) {

			/* Send is aborted so reset Tx FIFO */
			CntlReg = XIic_ReadReg(IIC_BASE_ADDRESS,
					XIIC_CR_REG_OFFSET);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
			XIic_WriteReg(IIC_BASE_ADDRESS, XIIC_CR_REG_OFFSET,
					XIIC_CR_ENABLE_DEVICE_MASK);
		}

	} while (AckByteCount != sizeof(wishboneAddr));


	/*
	 * Return the number of bytes written to the EEPROM
	 */
	return SentByteCount - sizeof(wishboneAddr);
}

/*****************************************************************************/
/**
* This function reads a number of bytes from the IIC serial EEPROM into a
* specified buffer.
*
* @param	wishboneAddr contains the address in the EEPROM to read from.
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
unsigned WishboneReadByte(UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u16 ByteCount)
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
							IICAddr,
							(u8 *)&wishboneAddr,
							sizeof(wishboneAddr),
							XIIC_STOP);

			if (ReceivedByteCount != sizeof(wishboneAddr)) {

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

	} while (ReceivedByteCount != sizeof(wishboneAddr));

	/*
	 * Read the number of bytes at the specified address from the EEPROM.
	 */
	ReceivedByteCount = XIic_Recv(IIC_BASE_ADDRESS, IICAddr,
					BufferPtr, ByteCount, XIIC_STOP);

	/*
	 * Return the number of bytes read from the EEPROM.
	 */
	return ReceivedByteCount;
}
/*****************************************************************************/
/**
* This function writes a buffer of bytes to the IIC serial EEPROM.
*
* @param	BufferPtr contains the address of the data to write.
* @param	ByteCount contains the number of bytes in the buffer to be
*		written. Note that this should not exceed the page size of the
*		EEPROM as noted by the constant PAGE_SIZE.
*
* @return	The number of bytes written, a value less than that which was
*		specified as an input indicates an error.
*
* @note		one.
*
******************************************************************************/
u8 WishboneDynWriteByte(UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr, u8 *BufferPtr, u8 ByteCount)
{
	u8 SentByteCount;
	u8 WriteBuffer[sizeof(wishboneAddr) + PAGE_SIZE];
	u8 Index;

	/*
	 * A temporary write buffer must be used which contains both the address
	 * and the data to be written, put the address in first based upon the
	 * size of the address for the EEPROM
	 */
	if (sizeof(AddressType) == 2) {
		WriteBuffer[0] = (u8) (wishboneAddr >> 8);
		WriteBuffer[1] = (u8) (wishboneAddr);
	} else if (sizeof(AddressType) == 1) {
		WriteBuffer[0] = (u8) (wishboneAddr);
	}

	/*
	 * Put the data in the write buffer following the address.
	 */
	for (Index = 0; Index < ByteCount; Index++) {
		WriteBuffer[sizeof(wishboneAddr) + Index] = BufferPtr[Index];
	}

	/*
	 * Write a page of data at the specified address to the EEPROM.
	 */
	SentByteCount = XIic_DynSend(IIC_BASE_ADDRESS, IICAddr,
				WriteBuffer, sizeof(wishboneAddr) + PAGE_SIZE,
				XIIC_STOP);

	/*
	 * Return the number of bytes written to the EEPROM.
	 */
	return SentByteCount - sizeof(wishboneAddr);
}

/******************************************************************************
/**
*
* This function reads a number of bytes from the IIC serial EEPROM into a
* specified buffer.
*
* @param	BufferPtr contains the address of the data buffer to be filled.
* @param	ByteCount contains the number of bytes in the buffer to be read.
*		This value is constrained by the page size of the device such
*		that up to 64K may be read in one call.
*
* @return	The number of bytes read. A value less than the specified input
*		value indicates an error.
*
* @note		None.
*
******************************************************************************/
u8 WishboneDynReadByte(UINTPTR IIC_BASE_ADDRESS, u8 IICAddr, AddressType wishboneAddr,  u8 *BufferPtr, u8 ByteCount)
{
	u8 ReceivedByteCount;
	u8 SentByteCount;
	u16 StatusReg;

	/*
	 * Position the Read pointer to specific location in the EEPROM.
	 */
	do {
		StatusReg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
		if (!(StatusReg & XIIC_SR_BUS_BUSY_MASK)) {
			SentByteCount = XIic_DynSend(IIC_BASE_ADDRESS,
							IICAddr,
							(u8 *) &wishboneAddr,
							sizeof(wishboneAddr),
							XIIC_STOP);
		}

	} while (SentByteCount != sizeof(wishboneAddr));

	StatusReg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);

	while ((StatusReg & XIIC_SR_BUS_BUSY_MASK)) {
		StatusReg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
	}

	do {
		/*
		 * Receive the data.
		 */
		ReceivedByteCount = XIic_DynRecv(IIC_BASE_ADDRESS,
						 IICAddr, BufferPtr,
						 ByteCount);
	} while (ReceivedByteCount != ByteCount);

	/*
	 * Return the number of bytes received from the EEPROM.
	 */
	return ReceivedByteCount;
}
