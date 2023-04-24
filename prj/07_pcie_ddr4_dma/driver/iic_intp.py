
'''
动态读取操作：此操作的最终目的是从从设备中读取单一寄存器，以证明主从设备的功能是否正常。
    1. 使用写入操作将 START + 从设备地址一起写入 TX FIFO
    2. 将从设备的子寄存器地址写入 TX FIFO
    3. 使用读取操作将 RE-START + 从设备地址一起写入 TX FIFO
    4. 将 STOP + 要从从设备读取的字节数一起写入 TX FIFO
    5. 使用控制寄存器来启用控制器
    6. 轮询 RX_FIFO_EMPTY 的状态寄存器，以查看数据接收状态（如果 RX_FIFO = 0，则数据已进入接收 FIFO 内）
    7. 如果 RX FIFO 中无数据，且 RX_FIFO_EMPTY 为 1，则可遵循以下步骤来了解问题：
    8. 如果由于从设备不响应而导致无法接收数据，那么原因可能是指定地址不存在任何从设备。请复查从设备地址是否正确。
    9. 如果您确认从设备地址正确无误，请探测 SCL/SDA 以了解是否正在从从设备生成 ACK。
    10. 如果有来自从设备的 ACK，请以相同方式检查子寄存器，以对通信进行调试。
    11. 检查 TX_FIFO_Empty 标记，确认是否所有数据都已完成发射。
    12. 如果步骤 6 中未发现任何问题，则表示您可从从设备接收数据，请检查是否已建立通信。

动态写入操作：
    1. 使用写入操作将 START + 从设备地址一起写入 TX FIFO
    2. 将从设备的子寄存器地址写入 TX FIFO
    3. 将除最后一个字节外的所有数据字节都写入 TX FIFO
    4. 将 STOP + 最后一个数据字节写入 TX FIFO
    5. 使用控制寄存器来启用控制器
    6. 轮询 TX_FIFO_EMPTY 的状态寄存器，以判定数据发射状态（TX_FIFO_Empty = 1 表示数据发射已完成）。
    7. 如果用户想要检查写入操作是否正确，可通过以下步骤来进行调试：
    8. 请检查发射占用寄存器，确认是否已发射所有数据。
    9. 用户还可以执行上述读取操作以便通过读取和验证数据来交叉验证写入操作。
    10.如果有来自从设备的 ACK，还请以相同方式检查子寄存器，以对通信进行调试。
    11.检查 TX_FIFO_Empty 标记，确认是否所有数据都已完成发射。
    12.如果步骤 6 中未发现任何问题，则表示您可将数据写入从设备，请检查是否已建立通信。


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

| 寄存器（0x1C 0x1c）全局中断使能（GIE）| 字段名称   | 默认值 | 访问类型 | 描述                                                         |
| --------------------------------- | ---------- | ------ | -------- | ------------------------------------------------------------ |
|  bit31                            | GIE        | 0      | 读/写    | 全局中断使能。0 = 禁止所有中断; 即使在IER中未屏蔽，AXI IIC核心也无法产生中断。1 = 未屏蔽的AXI IIC核心中断传递给处理器。 |

该寄存器控制AXI IIC核心产生中断的传递给处理器的全局中断使能。当GIE位为1时，未屏蔽的AXI IIC核心中断将被传递给处理器。当GIE位为0时，AXI IIC核心不会产生中断。

表格 2-6：中断状态寄存器（0x20）
| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| --- | --- | --- | --- | --- |
| 31:8 | 保留 | N/A | N/A | 保留 |
| 7 | int(7) | 1 | 读/写取反 | 中断（7）- 发送FIFO半空 |
| 6 | int(6) | 1 | 读/写取反 | 中断（6）- 未作为从设备寻址 |
| 5 | int(5) | 0 | 读/写取反 | 中断（5）- 作为从设备寻址 |
| 4 | int(4) | 1 | 读/写取反 | 中断（4）- IIC总线未忙 |
| 3 | int(3) | 0 | 读/写取反 | 中断（3）- 接收FIFO满 |
| 2 | int(2) | 0 | 读/写取反 | 中断（2）- 发送FIFO空 |
| 1 | int(1) | 0 | 读/写取反 | 中断（1）- 发送错误/从设备传输完成 |
| 0 | int(0) | 0 | 读/写取反 | 中断（0）- 仲裁丢失 |




表格2-7：中断使能寄存器（1）（0x28）

| 位字段 | 名称   | 默认值 | 访问类型 | 描述 |
| ------ | ----   | ------ | -------- | ---- |
| 31:8   | 保留   | N/A | N/A | 保留 |
| 7      | int(7) | 0 | 读/写 | 中断（7）——发送FIFO半空。 |
| 6      | int(6) | 0 | 读/写 | 中断（6）——未作为从设备地址。 |
| 5      | int(5) | 0 | 读/写 | 中断（5）——作为从设备地址。 |
| 4      | int(4) | 0 | 读/写 | 中断（4）——IIC总线空闲。 |
| 3      | int(3) | 0 | 读/写 | 中断（3）——接收FIFO满。 |
| 2      | int(2) | 0 | 读/写 | 中断（2）——发送FIFO空。 |
| 1      | int(1) | 0 | 读/写 | 中断（1）——发送错误/从设备传输完成。 |
| 0      | int(0) | 0 | 读/写 | 中断（0）——仲裁丢失。 |


表格2-8：软复位寄存器（0x40）

| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| ------ | ---- | ------ | -------- | ---- |
| 3:0 | RKEY | N/A | 写 | 复位键。固件必须在此字段写入0xA的值，以导致AXI IIC控制器中断寄存器的软复位。写入任何其他值会导致AXI事务确认出现SLVERR，且不会发生复位。 |



以下是中文翻译：

控制寄存器（0x100）

| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| ------ | ---- | ------ | -------- | ---- |
| 6 | GC_EN | 0 | 读/写 | 通用调用使能。设置此位为高将允许AXI IIC响应通用调用地址。0 = 禁用通用调用 1 = 启用通用调用 |
| 5 | RSTA | 0 | 读/写 | 重复起始。将此位写入1会在总线上生成一个重复的START条件，如果AXI IIC总线接口是当前总线主机。如果在错误的时间尝试重复启动（如果总线被另一个主机拥有），将导致仲裁丢失。此位在重复启动发生时复位。在将新地址写入TX_FIFO或DTR之前必须设置此位。 |
| 4 | TXAK | 0 | 读/写 | 发送响应使能。此位指定在主机和从机接收器的确认周期中驱动到sda线上的值。0 = ACK位= 0 – 确认 1 = ACK位= 1 – 非确认由于主机接收器通过不确认传输的最后一个字节来指示数据接收的结束，因此该位用于结束主机接收器传输。作为从机，必须在接收字节之前设置此位，以发出非确认信号。 |
| 3 | TX | 0 | 读/写 | 发送/接收模式选择。此位选择主/从传输的方向。0 = 选择AXI IIC接收；1 = 选择AXI IIC传输。此位不控制带地址的读/写位，带地址的读/写位必须是写入TX_FIFO的地址的最低位。|
| 2 | MSMS0 | 0 | 读/写 | 主/从模式选择。当此位从0更改为1时，AXI IIC总线接口在主模式下生成START条件。当此位清除时，生成STOP条件，AXI IIC总线接口切换到从模式。当硬件清除此位时，因为总线的仲裁已经丢失，不会生成STOP条件（参见中断(0): 仲裁丢失）。|
| 1 | TX_FIFO Reset | 0 | 读/写 | 发送FIFO重置。如果发生(a)仲裁丢失或(b)传输错误，则必须设置此位以刷新FIFO。0 = 发送FIFO正常操作；1 = 重置发送FIFO。|
| 0 | EN | 0 | 读/写 | AXI IIC使能。在任何其他CR位产生任何影响之前，必须设置此位。0 = 重置并禁用AXI IIC控制器；1 = 启用AXI IIC控制器。|

表格 2-10：状态寄存器（0x104）

| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| --- | --- | --- | --- | --- |
| 7 | TX_FIFO_EMPTY | 1 | R | 发送 FIFO 空。当发送 FIFO 为空时，此位被设置为高。注意：此位在 TX FIFO 变为空时立即变为高电平。此时，最后一个字节的数据可能仍在输出管道中或部分传输。 |
| 6 | RX_FIFO_EMPTY | 1 | R | 接收 FIFO 空。当接收 FIFO 为空时，此位被设置为高。 |
| 5 | RX_FIFO_Full | 0 | R | 接收 FIFO 满。当接收 FIFO 充满时，此位被设置为高。无论 RX_FIFO_PIRQ 寄存器的比较值字段如何，此位只有当 FIFO 中的所有 16 个位置都被占满时才会被设置。 |
| 4 | TX_FIFO_Full | 0 | R | 发送 FIFO 满。当发送 FIFO 充满时，此位被设置为高。 |
| 3 | SRW | 0 | R | 从机读/写。当 IIC 总线接口被作为从机寻址时（AAS 被设置），此位指示主机发送的读/写位的值。当完成一次传输且未启动其他传输时，此位才有效。0 = 指示主机写入从机，1 = 指示主机从从机读取。 |
| 2 | BB | 0 | R | 总线忙。此位指示 IIC 总线的状态。当检测到起始条件时，此位被设置，当检测到停止条件时，此位被清除。0 = 指示总线空闲，1 = 指示总线忙。 |
| 1 | AAS | 0 | R | 作为从机寻址。当 IIC 总线上的地址与地址寄存器（ADR）中的从机地址匹配时，IIC 总线接口被寻址为从机并切换到从机模式。如果选择了 10 位寻址，该设备仅在启用的情况下响应 10 位地址或广播地址。当检测到停止条件或重复起始条件时，此位被清除。0 = 指示没有被寻址为从机，1 = 指示被寻址为从机。 |
| 0 | ABGC | 0 | R | 被广播寻址。当另一个主机发出广播寻址并且广播寻址使能位已被设置为 1（CR(6) = 1）时，此位被设置为 1。 |



表格2-11：AXI IIC发送FIFO（0x108）

| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| --- | --- | --- | --- | --- |
| 31:10 | 保留 | N/A | N/A | 保留 |
| 9 | Stop | 0 | W | 停止。动态停止位可用于在传输或接收最后一个字节后在IIC总线上发送IIC停止序列。（2） |
| 8 | Start | (1) | W | 启动。动态启动位可用于在IIC总线上发送启动或重复启动序列。如果MSMS = 0，则生成启动序列，如果MSMS = 1，则生成重复启动序列。（2） |
| 7:0 | D7至D0 | 不确定（1） | W | AXI IIC传输数据。如果使用动态停止位且AXI IIC是主接收器，则该值为要接收的字节数。（3）|

其中，W表示可写，N/A表示不适用，MSMS代表主从选择。
注释：1. 重置发生前可用的值仍会出现在FIFO输出上。2. 动态停止和启动位的使用详细说明包含在动态控制器逻辑流程部分中。这些位是不可读的。3. 只有Bits [7:0]可以读回。



表格 2-12：接收FIFO（0x10c 0x10C）
| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| --- | --- | --- | --- | --- |
| 7:0 | D7到D0 | 不确定（1）| R | IIC接收数据 |

注释：该表格显示了接收FIFO寄存器（地址为0x10）的位字段及其描述。FIFO是一种用于缓存数据的存储器，用于存储通过IIC总线接收的数据。在此表格中，位字段名称为D7到D0，表示接收到的8位数据。默认值为不确定，访问类型为只读（R）。

Table 2‐17: Receive FIFO Programmable Depth Interrupt Register (0x120)RX_FIFO_PIRQ 

| 位字段 | 名称 | 默认值 | 访问类型 | 描述 |
| --- | --- | --- | --- | --- |
| 3:0|  Compare Va l u e|  0 | R/W|  Bit[3] is the MSB. A binary value of 1001 implies that when 10 locations in the receive FIFO are filled, the receive FIFO interrupt is set.| 


'''
import threading
import select


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

        self.iic_init()

    def iic_init(self):
        # 复位掉整个IIC
        self.mapped_iic.seek(0x40)
        self.mapped_iic.write(struct.pack('B',0xa))
        # 复位掉 IIC  FIFO
        self.mapped_iic.seek(0x100)
        self.mapped_iic.write(struct.pack('B',0x2))  # 复位FIFO 
        self.mapped_iic.seek(0x100)#执行完 write后，数据指针会自动偏移到下一个地址
        self.mapped_iic.write(struct.pack('B',0x0))  # 复位FIFO 
        # 配置中断条件1:RX FIFO收到2个数据
        self.mapped_iic.seek(0x120)
        self.mapped_iic.write(struct.pack('B',0x1))  
        # 配置中断条件2 TX FIFO发空
        #self.mapped_iic.seek(0x28)
        #self.mapped_iic.write(struct.pack('B',0xc))  
        #self.mapped_iic.seek(0x1c) #使能全局中断
        #self.mapped_iic.write(struct.pack('B',0x80000000))  

    def iic_read(self, devaddr, addr):
        '''
        1. 使用写入操作将 START + 从设备地址一起写入 TX FIFO
        2. 将从设备的子寄存器地址写入 TX FIFO
        3. 使用读取操作将 RE-START + 从设备地址一起写入 TX FIFO
        4. 将 STOP + 要从从设备读取的字节数一起写入 TX FIFO
        5. 使用控制寄存器来启用控制器
        6. 轮询 RX_FIFO_EMPTY 的状态寄存器，以查看数据接收状态（如果 RX_FIFO = 0，则数据已进入接收 FIFO 内）
        7. 如果 RX FIFO 中无数据，且 RX_FIFO_EMPTY 为 1，则可遵循以下步骤来了解问题：
        8. 如果由于从设备不响应而导致无法接收数据，那么原因可能是指定地址不存在任何从设备。请复查从设备地址是否正确。
        9. 如果您确认从设备地址正确无误，请探测 SCL/SDA 以了解是否正在从从设备生成 ACK。
        10. 如果有来自从设备的 ACK，请以相同方式检查子寄存器，以对通信进行调试。
        11. 检查 TX_FIFO_Empty 标记，确认是否所有数据都已完成发射。
        12. 如果步骤 6 中未发现任何问题，则表示您可从从设备接收数据，请检查是否已建立通信 
Read
_   _ _ _ _ _ _ _ _   _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _   _   _ _ _ _ _ _ _     _ _ _ _ _ _ _ _         _ _ _ _ _ _ _ _ _   _
 |_|_|_|_|_|_|_|_| |_|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_|_| |_|_|_|_|_|_|_|_|___|_|_|_|_|_|_|_|_|_ ... _|_|_|_|_|_|_|_|_| |_|
ST  Device Addr   W A   Address MSB   A         Address LSB   A  RS Device Addr   R A   Data byte 0   A         Data byte N   N  SP
        '''
        # 1. 使用写入操作将 START + 从设备地址一起写入 TX_FIFO
        tmp = (devaddr & 0xfe | 0x100 | 0x01).to_bytes(2, 'big')
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(tmp)
        # 2. 将从设备的子寄存器地址写入 TX FIFO
        tmp = (addr>>8 & 0xFF).to_bytes(1, 'big')
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(tmp)
        tmp = (addr    & 0xFF).to_bytes(1, 'big')
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(tmp)
        #3. 使用读取操作将 RE-START + 从设备地址一起写入 TX FIFO
        tmp = (devaddr & 0xfe | 0x100      ).to_bytes(2, 'big')
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(tmp)
        # 4. 将 STOP + 要从从设备读取的字节数一起写入 TX FIFO
        self.mapped_iic.seek(0x108)
        self.mapped_iic.write(struct.pack('B',0x2))  

        while True: # 等待接收完成
            # | 3 | int(3) | 0 | 读/写取反 | 中断（3）- 接收FIFO满 |
            self.mapped_iic.seek(0x28)
            sta = self.mapped_iic.read(1)
            if sta & 0x04 == 0:
                break
         
        self.mapped_iic.seek(0x28)
        lsb = self.mapped_iic.read(1)
        self.mapped_iic.seek(0x28)
        msb = self.mapped_iic.read(1)

        print(lsb)
        print(msb)






