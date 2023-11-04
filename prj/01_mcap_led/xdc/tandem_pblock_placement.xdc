set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]




# 1. 第一步与Flash还没关系，纯粹地定义 自设计逻辑 放置于 FPGA内部那一块区域
# 1.1. 把整个xdma_mcap_qspi 放到一个块中, 这一个块在所有逻辑中是几乎不变的
create_pblock pblock_xdma_mcap_qspi
add_cells_to_pblock [get_pblocks pblock_xdma_mcap_qspi] [get_cells -quiet "xdma_mcap_qspi_inst"]
resize_pblock [get_pblocks pblock_xdma_mcap_qspi] -add {CLOCKREGION_X6Y4:CLOCKREGION_X7Y7}

# 1.2 把用户逻辑放在一个块中
create_pblock pblock_tandem_app
add_cells_to_pblock [get_pblocks pblock_tandem_app] [get_cells -quiet "tandem_app_inst"] ; #这里是用户逻辑
add_cells_to_pblock [get_pblocks pblock_tandem_app] [get_cells -quiet "axi_ram_inst"]   ; # 这里是RAM逻辑



# 2. 将上面划分好的区域编译成bit文件，但是bit文件又希望分区，即
# 将boot启动分为两大部分，第一大部分放 xdma_mcap_qspi ; 第二大部分放其他逻辑
set_property HD.TANDEM 1 [get_pblocks pblock_xdma_mcap_qspi]
set_property HD.TANDEM 2 [get_pblocks pblock_tandem_app]
#set_property HD.TANDEM_IP_PBLOCK  Stage1_Main      [get_pblocks pblock_xdma_mcap_qspi]
#set_property HD.TANDEM_IP_PBLOCK  Stage1_Config_IO [get_pblocks pblock_tandem_app]
set_property HD.TANDEM_BITSTREAMS Separate         [current_design]            




# 3. 上面会生成2bit文件，其中 tandem 1可以烧写到qspi中，tandem 2 通过pcie更新，也可以一次性将两个文件写入flash

#write_cfgmem -format bin -file "xxxxxxxxxx_tandem1.bin" -size 256 -interface SPIx4 -loadbit \
#                {up 0x00000000 "xxxxxx_tandem1.bit" \
#                 up 0x02000000 "xxxxxx_tandem2.bit" } 




