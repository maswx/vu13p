set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set pblock_xdma_axil [get_pblock xdma_mcap_qspi_inst_xdma_0_inst_inst_pcie4_ip_i_inst_xdma_0_pcie4_ip_Stage1_main]

set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -quiet "xdma_mcap_qspi_inst"]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells pcie_perst_n_IBUF_inst]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -hier -filter {(ORIG_REF_NAME == ICAPE3    || REF_NAME == ICAPE3   )}]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -hier -filter {(ORIG_REF_NAME == STARTUPE3 || REF_NAME == STARTUPE3)}]

resize_pblock ${pblock_xdma_axil} -add {CLOCKREGION_X6Y4:CLOCKREGION_X7Y7} ; #约束时钟的区域范围
resize_pblock ${pblock_xdma_axil} -add {SLICE_X176Y240:SLICE_X232Y479 }    ; #约束LUT 的区域范围
resize_pblock ${pblock_xdma_axil} -add {RAMB36_X11Y48:RAMB36_X13Y95}       ; #约束RAM 的区域范围
resize_pblock ${pblock_xdma_axil} -add {LAGUNA_X24Y240:LAGUNA_X31Y479 }    ; #约束REG 的区域范围

