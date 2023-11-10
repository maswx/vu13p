set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]





#set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells ibufds_gte4_pcie_mgt_refclk_inst]


##---no tandem--- set pblock_xdma_axil [get_pblock xdma_mcap_qspi_inst_xdma_0_inst_inst_pcie4_ip_i_inst_xdma_0_pcie4_ip_Stage1_main]
##---no tandem--- 
##---no tandem--- 
##---no tandem--- set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -quiet "xdma_mcap_qspi_inst"]
##---no tandem--- set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells pcie_perst_n_IBUF_inst]
##---no tandem--- set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -hier -filter {(ORIG_REF_NAME == ICAPE3|| REF_NAME == ICAPE3)}]
##---no tandem--- set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -hier -filter {(ORIG_REF_NAME == STARTUPE3 || REF_NAME == STARTUPE3)}]
##---no tandem--- 
##---no tandem--- 
##---no tandem--- resize_pblock ${pblock_xdma_axil} -add {CLOCKREGION_X6Y4:CLOCKREGION_X7Y7} ; #约束时钟的区域范围
##---no tandem--- resize_pblock ${pblock_xdma_axil} -add {SLICE_X176Y240:SLICE_X232Y479 }    ; #约束LUT 的区域范围
##---no tandem--- resize_pblock ${pblock_xdma_axil} -add {RAMB36_X11Y48:RAMB36_X13Y95}       ; #约束RAM 的区域范围
##---no tandem--- resize_pblock ${pblock_xdma_axil} -add {LAGUNA_X24Y240:LAGUNA_X31Y479 }    ; #约束REG 的区域范围



