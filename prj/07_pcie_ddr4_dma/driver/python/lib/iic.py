# 用Python 写一个简单的IIC通信程序
# 首先定义一个类，这个类包含了IIC通信的所有操作
# 类的初始化需要传入 open pcie设备的文件描述符
# 以及IIC的地址

import os
import struct
import time
import mmap

# 定义IIC 类
class pcie_dev:
    def __init__(self,fd) -> None:
        self.fd = fd
        """
        vivado 设计中的IIC的地址空间
        "SEG_axi_iic_0_Reg": {
          "address_block": "/axi_iic_0/S_AXI/Reg",
          "offset": "0x00800000",                                                                                                                  
          "range": "64K"
        }, 
        """
        self.mapped_dma_w = mmap.mmap(self.fd, length=0x10000, flags=mmap.MAP_SHARED, prot=mmap.PROT_READ | mmap.PROT_WRITE, offset=0xff820000)
        self.mapped_dma_r = mmap.mmap(self.fd, length=0x10000, flags=mmap.MAP_SHARED, prot=mmap.PROT_READ | mmap.PROT_WRITE, offset=0xff810000)
        self.mapped_iic   = mmap.mmap(self.fd, length=0x10000, flags=mmap.MAP_SHARED, prot=mmap.PROT_READ | mmap.PROT_WRITE, offset=0xff800000)
        self.mapped_clk   = mmap.mmap(self.fd, length=0x10000, flags=mmap.MAP_SHARED, prot=mmap.PROT_READ | mmap.PROT_WRITE, offset=0xff830000)
    """
    #define GIE            0x1C  /**< Global Interrupt Enable Register */
    #define ISR            0x20  /**< Interrupt Status Register */
    #define IER            0x28  /**< Interrupt Enable Register */
    #define SOFTR          0x40  /**< Reset Register */
    #define CR             0x100 /**< Control Register */
    #define SR             0x104 /**< Status Register */
    #define TX_FIFO        0x108 /**< Data Tx Register */
    #define RX_FIFO        0x10C /**< Data Rx Register */
    #define ADR            0x110 /**< Address Register */
    #define TX_FIFO_OCY    0x114 /**< Tx FIFO Occupancy */
    #define RX_FIFO_OCY    0x118 /**< Rx FIFO Occupancy */
    #define TEN_ADR        0x11C /**< 10 Bit Address reg */
    #define RX_FIFO_PIRQ   0x120 /**< Rx FIFO Depth reg */
    #define GPO            0x124 /**< Output Register */ 
    """
    def iic_initial(self, devaddr):
        # 复位掉整个IIC
        self.mapped_iic.seek(0x40)
        self.mapped_iic.write(struct.pack('B',0xa))
        # 复位掉 IIC  FIFO
        self.mapped_iic.seek(0x100)
        self.mapped_iic.write(struct.pack('B',0x2))  # 复位FIFO 
        self.mapped_iic.seek(0x100)#执行完 write后，数据指针会自动偏移到下一个地址
        self.mapped_iic.write(struct.pack('B',0x0))  # 复位FIFO 
        # 0x110 IIC 设备地址
        self.mapped_iic.seek(0x110)
        self.mapped_iic.write(devaddr.to_bytes(4, 'big'))


    def iic_write(self,addr,data):## 这里的地址是 verilog-iic内部的寄存器地址和数据， 不是IIC设备的地址和数据, addr=0x11 data=0x2222;
        """
        IIC Master Transmitter with a Repeated Start 
        1. Write the IIC device address to the TX_FIFO. 
        2. Write data to TX_FIFO. 
        3. Write to CR to set MSMS = 1 and TX = 1. 
        4. Continue writing data to TX_FIFO. 
        5. Wait for transmit FIFO empty interrupt. This implies the IIC has throttled the bus. 
        6. Write to CR to set RSTA = 1. 
        7. Write IIC device address to TX_FIFO. 
        8. Write all data except last byte to TX_FIFO. 
        9. Wait for transmit FIFO empty interrupt. This implies the IIC has throttled the bus. 
        10. Write to CR to set MSMS = 0. The IIC generates a STOP condition at the end of the last byte. 
        11. Write last byte of data to TX_FIFO
        """
        """
        Write
        _   _ _ _ _ _ _ _ _   _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _   _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _     _
         |_|_|_|_|_|_|_|_| |_|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_|___|
        ST  Device Addr   W A   Address MSB   A         Address LSB   A   Data byte 0   A         Data byte N   A  SP 
        """
        #2. Write data to TX_FIFO. 
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(struct.pack('B',(addr | 0x100).to_bytes(2, 'big'))) # 使能start
        #3. Write to CR to set MSMS = 1 and TX = 1. 
        self.mapped_iic.seek(0x100)
        self.mapped_iic.write(struct.pack('B',0xc))
        #4. Continue writing data to TX_FIFO. 
        # 取出 data 的低 8 位（7:0）
        low_8_bits = data & 0xFF
        # 将整数值转换为一个字节对象
        low_8_bits_bytes = low_8_bits.to_bytes(1, 'big')
        # 取出 data 的接下来的 8 位（15:8）
        mid_8_bits = (data >> 8) & 0xFF
        # 将整数值转换为一个字节对象
        mid_8_bits_bytes = (mid_8_bits | 0x200).to_bytes(2, 'big')
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(low_8_bits_bytes)
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(mid_8_bits_bytes)

        #5. Wait for transmit FIFO empty interrupt. This implies the IIC has throttled the bus.
        while True: # 等待发送完成
            self.mapped_iic.seek(0x104)
            sta = self.mapped_iic.read(1)
            if sta & 0x80 == 0:
                break

        self.mapped_iic.seek(0x100)
        self.mapped_iic.write(struct.pack('B',0x0))


    def iic_read(self,addr):## 这里的地址是 verilog-iic内部的寄存器地址和数据， 不是IIC设备的地址和数据, addr=0x11 data=0x2222;
        """
        IIC Master Receiver with a Repeated Start 
        1. Write the IIC peripheral device addresses for the first slave device to the TX_FIFO. Write the RX_FIFO_PIRQ to the total message length (call it M) minus two. It is assumed that the message < the maximum FIFO depth of 16 bytes. 
        2. Set CR MSMS = 1 and CR TX = 0. 
        3. Wait for the receive FIFO interrupt indicating M – 1 bytes have been received.
        4. Set CR TXAK = 1. TXAK causes the AXI IIC core to not-acknowledge the next byte received indicating to the slave transmitter that the master receiver accepts no further data. TXAK is set before reading data from the RX_FIFO, because as soon as a read from the RX_FIFO has occurred, the throttle condition is removed and the opportunity to set the bit is lost
        5. Read all M – 1 data bytes from the RX_FIFO. Set the RX_FIFO_PIRQ to 0 so that the last byte, soon to be received, causes the receive FIFO full interrupt to be raised. 
        6. Clear the receive FIFO full interrupt now because after a single byte is retrieved from the RX_FIFO the throttle condition is removed by the controller and the interrupt flag can be lowered (cleared). 
        7. Wait for the receive FIFO full interrupt. 
        8. The controller is throttled again with a full RX_FIFO. Set CR RSTA = 1. Write the peripheral IIC device address for a new (or same) IIC slave to the TX_FIFO. 
        9. Read the final byte of data (of the first message) from the RX_FIFO. This terminates the throttle condition so the receive FIFO full interrupt can be cleared at this time. It also permits the controller to issue the IIC restart and transmit the new slave address available in the TX_FIFO. Also set the Receive FIFO Programmable Depth Interrupt register to be 2 less than the total second message length (call it N) in anticipation of receiving the message of N – 1 bytes from the second slave device. 
        10. Wait for the receive FIFO full interrupt. 
        11. Set TXAK = 1. Write the RX_FIFO_PIRQ to 0, read the message from the RX_FIFO and clear the receive FIFO full interrupt. 
        12. Wait for the receive FIFO full interrupt (signaling the last byte is received). 
        13. Set MSMS = 0 in anticipation of giving up the bus through generation of an IIC Stop. 14. Read the final data byte of the second message from the RX_FIFO. This clears the throttle condition and makes way for the controller to issue the IIC Stop
        1. 将第一个从设备的IIC外围设备地址写入TX_FIFO。将RX_FIFO_PIRQ写入总消息长度（称为M）减二。假定消息 < 最大FIFO深度16字节。
        2. 设置CR MSMS = 1和CR TX = 0。
        3. 等待接收FIFO中断，表示已接收M-1个字节。
        4. 设置CR TXAK = 1。TXAK导致AXI IIC核心不确认接收到的下一个字节，表示主接收器不接受进一步的数据。因为一旦从RX_FIFO读取数据，节流条件就会被解除，机会将会丢失，所以必须在从RX_FIFO读取数据之前设置TXAK。
        5. 从RX_FIFO中读取所有M-1个数据字节。将RX_FIFO_PIRQ设置为0，这样即将接收的最后一个字节将引发接收FIFO满中断。
        6. 现在清除接收FIFO满中断，因为从RX_FIFO中检索单个字节后，控制器将解除节流条件，并且可以降低（清除）中断标志。
        7. 等待接收FIFO满中断。
        8. 控制器又因为满的RX_FIFO而被节流。设置CR RSTA = 1。将新（或相同）IIC从设备的外围设备地址写入TX_FIFO。
        9. 从RX_FIFO中读取第一条消息的最后一个数据字节。这将终止节流条件，因此现在可以清除接收FIFO满中断。这还允许控制器发出IIC重启，并传输TX_FIFO中可用的新从设备地址。还需将接收FIFO可编程深度中断寄存器设置为第二个消息的总长度（称为N）减去2，以期望从第二个从设备接收N-1字节的消息。
        10. 等待接收FIFO满中断。
        11. 设置TXAK = 1。将RX_FIFO_PIRQ设置为0，从RX_FIFO中读取消息，并清除接收FIFO满中断。
        12. 等待接收FIFO满中断（表示最后一个字节已接收）。
        13. 在生成IIC停止信号之前，将MSMS = 0。
        14. 从RX_FIFO中读取第二个消息的最后一个数据字节。这将清除节流条件，为控制器发出IIC停止信号铺平道路。
        Read
        _   _ _ _ _ _ _ _ _   _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _   _   _ _ _ _ _ _ _     _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _ _   _
         |_|_|_|_|_|_|_|_| |_|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_|_| |_|_|_|_|_|_|_|_|___|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_| |_|
        ST  Device Addr   W A   Address MSB   A         Address LSB   A  RS Device Addr   R A   Data byte 0   A         Data byte N   N  SP
        """ 
        data


        return data


    def read_from_address(self, address=0xff800000):
        offset = address - 0xff800000
        self.mapped_memory.seek(offset)
        data = self.mapped_memory.read(4)  # Assuming 4 bytes (32-bit) read
        return int.from_bytes(data, 'little')

    def write_to_address(self, value, address=0xff800000):
        offset = address - 0xff800000
        self.mapped_memory.seek(offset)
        self.mapped_memory.write(value.to_bytes(4, 'little'))  # Assuming 4 bytes (32-bit) write

    def close(self):
        self.mapped_memory.close()
        os.close(self.fd)

# 使用示例
pcie_device = PCIeDevice()

# 向地址0xff800000写入一个整数值
pcie_device.write_to_address(42)

# 从地址0xff800000读取一个整数值
value = pcie_device.read_from_address()
print(f"Value read from address 0xff800000: {value}")

# 关闭设备
pcie_device.close()
