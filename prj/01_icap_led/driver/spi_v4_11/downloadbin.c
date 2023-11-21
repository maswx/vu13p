//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月19日 星期日 23时25分26秒
//========================================================================




// add by masw@masw.tech
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdarg.h>

#include <pthread.h>
#include <fcntl.h>
#include <poll.h>

#define XPAR_XSPI_NUM_INSTANCES 1
#define XIL_INTERRUPT

// add by masw@masw.tech end ====================================================



#include "xspi.h"		/* SPI device driver */

/************************** Constant Definitions *****************************/

#define SPI_SELECT 			0x01

// Flash 命令
#define COMMAND_PAGE_PROGRAM		0x02 /* Page Program command */
#define COMMAND_QUAD_WRITE		    0x32 /* Quad Input Fast Program */
#define COMMAND_RANDOM_READ		    0x03 /* Random read command */
#define COMMAND_DUAL_READ		    0x3B /* Dual Output Fast Read */
#define COMMAND_DUAL_IO_READ		0xBB /* Dual IO Fast Read */
#define COMMAND_QUAD_READ		    0x6B /* Quad Output Fast Read */
#define COMMAND_QUAD_IO_READ		0xEB /* Quad IO Fast Read */
#define	COMMAND_WRITE_ENABLE		0x06 /* Write Enable command */
#define COMMAND_SECTOR_ERASE		0xD8 /* Sector Erase command */
#define COMMAND_BULK_ERASE		    0xC7 /* Bulk Erase command */
#define COMMAND_STATUSREG_READ		0x05 /* Status read command */

/**
 * This definitions specify the EXTRA bytes in each of the command
 * transactions. This count includes Command byte, address bytes and any
 * don't care bytes needed.
 */
#define READ_WRITE_EXTRA_BYTES		4 /* Read/Write extra bytes */
#define	WRITE_ENABLE_BYTES		    1 /* Write Enable bytes */
#define SECTOR_ERASE_BYTES		    4 /* Sector erase extra bytes */
#define BULK_ERASE_BYTES		    1 /* Bulk erase extra bytes */
#define STATUS_READ_BYTES		    2 /* Status read bytes count */
#define STATUS_WRITE_BYTES		    2 /* Status write bytes count */

/*
 * Flash not busy mask in the status register of the flash device.
 */
#define FLASH_SR_IS_READY_MASK		0x01 /* Ready mask */

/*
 * Number of bytes per page in the flash device.
 */
#define PAGE_SIZE			256

/*
 * Address of the page to perform Erase, Write and Read operations.
 */
#define FLASH_TEST_ADDRESS		0x00

/*
 * Byte Positions.
 */
#define BYTE1				0 /* Byte 1 position */
#define BYTE2				1 /* Byte 2 position */
#define BYTE3				2 /* Byte 3 position */
#define BYTE4				3 /* Byte 4 position */
#define BYTE5				4 /* Byte 5 position */
#define BYTE6				5 /* Byte 6 position */
#define BYTE7				6 /* Byte 7 position */
#define BYTE8				7 /* Byte 8 position */

/*
 * The following definitions specify the number of dummy bytes to ignore in the
 * data read from the flash, through various Read commands. This is apart from
 * the dummy bytes returned in response to the command and address transmitted.
 */
/*
 * After transmitting Dual Read command and address on DIO0, the quad spi device
 * configures DIO0 and DIO1 in input mode and receives data on both DIO0 and
 * DIO1 for 8 dummy clock cycles. So we end up with 16 dummy bits in DRR. The
 * same logic applies Quad read command, so we end up with 4 dummy bytes in that
 * case.
 */
#define DUAL_READ_DUMMY_BYTES		2
#define QUAD_READ_DUMMY_BYTES		4

#define DUAL_IO_READ_DUMMY_BYTES	1
#define QUAD_IO_READ_DUMMY_BYTES	3

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

int SpiFlashWriteEnable(XSpi *SpiPtr);
int SpiFlashWrite(XSpi *SpiPtr, u32 Addr, uint8_t *buffer, u32 ByteCount, u8 WriteCmd);
int SpiFlashRead(XSpi *SpiPtr, u32 Addr, u32 ByteCount, u8 ReadCmd);
int SpiFlashBulkErase(XSpi *SpiPtr);
int SpiFlashSectorErase(XSpi *SpiPtr, u32 Addr);
int SpiFlashGetStatus(XSpi *SpiPtr);
int SpiFlashQuadEnable(XSpi *SpiPtr);
int SpiFlashEnableHPM(XSpi *SpiPtr);
void* monitor_device(void* InstancePtr) ;
static int SpiFlashWaitForFlashReady(void);
void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount);

/************************** Variable Definitions *****************************/

/*
 * The instances to support the device drivers are global such that they
 * are initialized to zero each time the program runs. They could be local
 * but should at least be static so they are zeroed.
 */
static XSpi Spi;

/*
 * The following variables are shared between non-interrupt processing and
 * interrupt processing such that they must be global.
 */
volatile static int TransferInProgress;

/*
 * The following variable tracks any errors that occur during interrupt
 * processing.
 */
static int ErrorCount;

/*
 * Buffers used during read and write transactions.
 */
static u8 ReadBuffer [PAGE_SIZE + READ_WRITE_EXTRA_BYTES + 4];
static u8 WriteBuffer[PAGE_SIZE + READ_WRITE_EXTRA_BYTES];

/*
 * Byte offset value written to Flash. This needs to be redefined for writing
 * different patterns of data to the Flash device.
 */
static u8 TestByte = 0x20;

/************************** Function Definitions ******************************/

/*****************************************************************************/
/**
*
* Main function to run the quad flash example.
*
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int main(int argc, char *argv[]) 
{
	int Status;
	u32 Index;
	u32 Address;
	int TestPass = FALSE;
	XSpi_Config *ConfigPtr = malloc(sizeof(XSpi_Config));
	if (ConfigPtr == NULL) {
		printf("内存分配失败\n");
		return XST_FAILURE;
	}
	
    //==================================================================================
    //============================add by masw@masw.tech=================================
    //==================================================================================
    //
    int axilte, Intrp;
    void *mapped_base;
    off_t  base_offset  = 0x00020000;  // 基地址的偏移量, 512kB, 前一大段是给 BRAM 的
    size_t mapping_size = 64 * 1024; // 映射的大小，64K
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

	ConfigPtr->BaseAddress        = (uintptr_t)mapped_base;
	ConfigPtr->HasFifos           = 1;		//配置IP的时候配了16的深度
	ConfigPtr->SlaveOnly          = 0;		/**< Is the device slave only? */
	ConfigPtr->NumSlaveBits       = 1;   	//IP 配的1/**< Num of slave select bits on the device */
	ConfigPtr->DataWidth          = 8;		/**< Data transfer Width */
	ConfigPtr->SpiMode            = 2;		/**< Standard/Dual/Quad mode */
	ConfigPtr->AxiInterface       = 0;	/**< AXI-Lite/AXI Full Interface */
	ConfigPtr->AxiFullBaseAddress = 0x00020000;	/**< AXI Full Interface Base address of the device */
	ConfigPtr->XipMode            = 0;             /**< 0 if Non-XIP, 1 if XIP Mode */
	ConfigPtr->Use_Startup        = 1;		/**< 1 if Starup block is used in h/w */
	ConfigPtr->FifosDepth         = 16;		/**< TX and RX FIFO Depth */


	Status = XSpi_CfgInitialize(&Spi, ConfigPtr, ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//创建中断处理函数
	pthread_t thread;
	pthread_create(&thread, NULL, &monitor_device , &Spi);
	// 使能中断

	/*
	 * Setup the handler for the SPI that will be called from the interrupt
	 * context when an SPI status occurs, specify a pointer to the SPI
	 * driver instance as the callback reference so the handler is able to
	 * access the instance data.
	 */
	XSpi_SetStatusHandler(&Spi, &Spi, (XSpi_StatusHandler)SpiHandler);

	/*
	 * Set the SPI device as a master and in manual slave select mode such
	 * that the slave select signal does not toggle for every byte of a
	 * transfer, this must be done before the slave select is set.
	 */
	Status = XSpi_SetOptions(&Spi, XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Select the quad flash device on the SPI bus, so that it can be
	 * read and written using the SPI bus.
	 */
	Status = XSpi_SetSlaveSelect(&Spi, SPI_SELECT);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the SPI driver so that interrupts and the device are enabled.
	 */
	XSpi_Start(&Spi);

	/*
	 * Specify the address in the Quad Serial Flash for the Erase/Write/Read
	 * operations.
	 */
	Address = FLASH_TEST_ADDRESS;
//=============================================================================================
	// 使能 Flash 写
	Status = SpiFlashWriteEnable(&Spi);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// 擦除 扇区
	Status = SpiFlashSectorErase(&Spi, Address);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// 使能4bit QE模式
	Status = SpiFlashQuadEnable(&Spi);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// 使能 Flash 写
	Status = SpiFlashWriteEnable(&Spi);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	// 从这里开始，编写一段程序代码，将外部 的 test.bin文件写入到Flash中

	// 1. 打开文件
	char *filename;
	if (argc > 1) {
        filename = argv[1];
    } else {
        filename = "test.bin";
    }
	FILE *file = fopen(filename , "rb");
	if (file == NULL) {
		printf("无法打开文件%s\n", filename);
		return XST_FAILURE;
	}
	printf("正在下载文件%s\n", filename);

	// 2. 获取文件大小
	fseek(file, 0, SEEK_END);
	long size = ftell(file);
	fseek(file, 0, SEEK_SET);

	u8 *buffer = malloc(PAGE_SIZE+READ_WRITE_EXTRA_BYTES);

	// 3. 读取文件内容并写入到Flash
	// 增加计时开始
	clock_t start, finish;
	double  duration;
	start = clock();
	long totalSize = size; // 记录文件总大小
	long readSize = 0; // 记录已读取的大小
	int barWidth = 100; // 进度条的宽度
	int pos;
	// 读取文件内容并写入到Flash
	long address = 0;
	while (size > 0) {
		// 读取一页数据
		size_t bytes = fread(buffer+ READ_WRITE_EXTRA_BYTES , 1, PAGE_SIZE, file);
		size -= bytes;

		// 更新已读取的大小

		//printf("%ld\n", size);

		// 写入一页数据到Flash
		Status = SpiFlashWrite(&Spi, address,buffer,  bytes, COMMAND_PAGE_PROGRAM);
		if (Status != XST_SUCCESS) {
			printf("写入Flash失败\n");
			fclose(file);
			return XST_FAILURE;
		}

		// 更新地址
		address += PAGE_SIZE;
		// 打印进度条
    	printf("[");
    	pos = barWidth * (totalSize-size) / totalSize;
    	for (int i = 0; i < barWidth; ++i) {
    	    if (i < pos) printf("=");
    	    else if (i == pos) printf(">");
    	    else printf(" ");
    	}
    	printf("] %d%%\r", (int)(100.0 * size / totalSize));
    	fflush(stdout);
	}
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC;
	printf("写入Flash成功，耗时%f秒\n", duration);

	fclose(file);
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function enables writes to the Winbond Serial Flash memory.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int SpiFlashWriteEnable(XSpi *SpiPtr)
{
	int Status;

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = COMMAND_WRITE_ENABLE;

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, NULL,
			       WRITE_ENABLE_BYTES);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function writes the data to the specified locations in the Winbond Serial
* Flash memory.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
* @param	Addr is the address in the Buffer, where to write the data.
* @param	ByteCount is the number of bytes to be written.
* @param 	WriteCmd is the command used for writing data to flash.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int SpiFlashWrite(XSpi *SpiPtr, u32 Addr,uint8_t *buffer,  u32 ByteCount, u8 WriteCmd)
{
	u32 Index;
	int Status;

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//--/*
	//-- * Prepare the WriteBuffer.
	//-- */
	buffer[BYTE1] = WriteCmd;
	buffer[BYTE2] = (u8) (Addr >> 16);
	buffer[BYTE3] = (u8) (Addr >> 8);
	buffer[BYTE4] = (u8) Addr;



	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, buffer, NULL, (ByteCount + READ_WRITE_EXTRA_BYTES));
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction.
	 */
	//uint32_t Tx_Empty;
	while (TransferInProgress);
	//{
	//	Tx_Empty = *(volatile u64 *) (SpiPtr->BaseAddr+0x60) ;
	//	Tx_Empty = *(volatile u64 *) (SpiPtr->BaseAddr+0x64) ;
	//	Tx_Empty = *(volatile u64 *) (SpiPtr->BaseAddr+0x1c) ;
	//	Tx_Empty = *(volatile u64 *) (SpiPtr->BaseAddr+0x20) ;
	//	Tx_Empty = *(volatile u64 *) (SpiPtr->BaseAddr+0x28) ;
	//}
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function reads the data from the Winbond Serial Flash Memory
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
* @param	Addr is the starting address in the Flash Memory from which the
*		data is to be read.
* @param	ByteCount is the number of bytes to be read.
* @param	ReadCmd is the command used for reading data from flash.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int SpiFlashRead(XSpi *SpiPtr, u32 Addr, u32 ByteCount, u8 ReadCmd)
{
	int Status;

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = ReadCmd;
	WriteBuffer[BYTE2] = (u8) (Addr >> 16);
	WriteBuffer[BYTE3] = (u8) (Addr >> 8);
	WriteBuffer[BYTE4] = (u8) Addr;

	if (ReadCmd == COMMAND_DUAL_READ) {
		ByteCount += 2;
	} else if (ReadCmd == COMMAND_DUAL_IO_READ) {
		ByteCount++;
	} else if (ReadCmd == COMMAND_QUAD_IO_READ) {
		ByteCount += 3;
	} else if (ReadCmd == COMMAND_QUAD_READ) {
		ByteCount += 4;
	}

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer( SpiPtr, WriteBuffer, ReadBuffer,
				(ByteCount + READ_WRITE_EXTRA_BYTES));
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction.
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function erases the entire contents of the Winbond Serial Flash device.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		The erased bytes will read as 0xFF.
*
******************************************************************************/
int SpiFlashBulkErase(XSpi *SpiPtr)
{
	int Status;

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = COMMAND_BULK_ERASE;

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, NULL,
			       BULK_ERASE_BYTES);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function erases the contents of the specified Sector in the Winbond
* Serial Flash device.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
* @param	Addr is the address within a sector of the Buffer, which is to
*		be erased.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		The erased bytes will be read back as 0xFF.
*
******************************************************************************/
int SpiFlashSectorErase(XSpi *SpiPtr, u32 Addr)
{
	int Status;

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = COMMAND_SECTOR_ERASE;
	WriteBuffer[BYTE2] = (u8) (Addr >> 16);
	WriteBuffer[BYTE3] = (u8) (Addr >> 8);
	WriteBuffer[BYTE4] = (u8) (Addr);

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, NULL,
			       SECTOR_ERASE_BYTES);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function reads the Status register of the Winbond Flash.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		The status register content is stored at the second byte pointed
*		by the ReadBuffer.
*
******************************************************************************/
int SpiFlashGetStatus(XSpi *SpiPtr)
{
	int Status;

	/*
	 * Prepare the Write Buffer.
	 */
	WriteBuffer[BYTE1] = COMMAND_STATUSREG_READ;

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, ReadBuffer, STATUS_READ_BYTES);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//debug by masw
	// 中断地址为base+ 0x1c bit31 读回看看数值
	//printf("GIER = %x \r\n", *(volatile u64 *) (SpiPtr->BaseAddr+0x1c)); //
	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function sets the QuadEnable bit in Winbond flash.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int SpiFlashQuadEnable(XSpi *SpiPtr)
{
	int Status;

	/*
	 * Perform the Write Enable operation.
	 */
	Status = SpiFlashWriteEnable(SpiPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = 0x01;
	WriteBuffer[BYTE2] = 0x00;
	WriteBuffer[BYTE3] = 0x02; /* QE = 1 */

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, NULL, 3);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Verify that QE bit is set by reading status register 2.
	 */

	/*
	 * Prepare the Write Buffer.
	 */
	WriteBuffer[BYTE1] = 0x35;

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, ReadBuffer,
			       STATUS_READ_BYTES);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function enabled High Performance Mode in Winbond flash, so that data can
* be read from the flash using DIO and QIO commands.
*
* @param	SpiPtr is a pointer to the instance of the Spi device.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int SpiFlashEnableHPM(XSpi *SpiPtr)
{
	int Status;

	/*
	 * Perform the Write Enable operation.
	 */
	Status = SpiFlashWriteEnable(SpiPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait while the Flash is busy.
	 */
	Status = SpiFlashWaitForFlashReady();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the WriteBuffer.
	 */
	WriteBuffer[BYTE1] = 0xA3;

	/*
	 * Initiate the Transfer.
	 */
	TransferInProgress = TRUE;
	Status = XSpi_Transfer(SpiPtr, WriteBuffer, NULL, 4);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the Transfer is complete and check if there are any errors
	 * in the transaction..
	 */
	while (TransferInProgress);
	if (ErrorCount != 0) {
		ErrorCount = 0;
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function waits till the Winbond serial Flash is ready to accept next
* command.
*
* @param	None
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		This function reads the status register of the Buffer and waits
*.		till the WIP bit of the status register becomes 0.
*
******************************************************************************/
int SpiFlashWaitForFlashReady(void)
{
	int Status;
	u8 StatusReg;

	while (1) {

		/*
		 * Get the Status Register.
		 */
		Status = SpiFlashGetStatus(&Spi);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		/*
		 * Check if the flash is ready to accept the next command.
		 * If so break.
		 */
		StatusReg = ReadBuffer[1];
		if ((StatusReg & FLASH_SR_IS_READY_MASK) == 0) {
			break;
		}
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function is the handler which performs processing for the SPI driver.
* It is called from an interrupt context such that the amount of processing
* performed should be minimized. It is called when a transfer of SPI data
* completes or an error occurs.
*
* This handler provides an example of how to handle SPI interrupts and
* is application specific.
*
* @param	CallBackRef is the upper layer callback reference passed back
*		when the callback function is invoked.
* @param	StatusEvent is the event that just occurred.
* @param	ByteCount is the number of bytes transferred up until the event
*		occurred.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount)
{
	/*
	 * Indicate the transfer on the SPI bus is no longer in progress
	 * regardless of the status event.
	 */
	TransferInProgress = FALSE;

	/*
	 * If the event was not transfer done, then track it as an error.
	 */
	if (StatusEvent != XST_SPI_TRANSFER_DONE) {
		ErrorCount++;
	}
}


// 定义线程函数
void* monitor_device(void* InstancePtr) {
	XSpi *SpiPtr = (XSpi *)InstancePtr;
    struct pollfd fds[1];
    int fd = open("/dev/xdma0_events_0", O_RDONLY);
    if (fd < 0) {
        perror("open");
        return NULL;
    }

    fds[0].fd = fd;
    fds[0].events = POLLIN;
	uint32_t events_user;
	int ret;

    while (1) {
        ret = poll(fds, 1, 0);
        if (ret < 0) {
            perror("poll");
            close(fd);
            return NULL;
        } else if(fds[0].revents & POLLIN) {
			pread(fd, &events_user, sizeof(events_user), 0);
            XSpi_InterruptHandler(SpiPtr);
        }
    }

    close(fd);
    return NULL;
}
