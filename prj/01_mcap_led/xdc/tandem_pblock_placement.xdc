set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]




set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells xdma_mcap_qspi_inst/axi_quad_spi_0_inst/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/QSPI_LEGACY_MD_GEN.QSPI_CORE_INTERFACE_I/LOGIC_FOR_MD_12_GEN.SCK_MISO_STARTUP_USED.QSPI_STARTUP_BLOCK_I/STARTUP_8SERIES_GEN.STARTUP3_8SERIES_inst]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells xdma_mcap_qspi_inst/fpga_reboot_inst/icape3_inst]
set_property HD.OVERRIDE_PERSIST false [current_design]
set_property HD.TANDEM_BITSTREAMS Separate         [current_design]            




# 3. 上面会生成2bit文件，其中 tandem 1可以烧写到qspi中，tandem 2 通过pcie更新，也可以一次性将两个文件写入flash

#write_cfgmem -format bin -file "xxxxxxxxxx_tandem1.bin" -size 256 -interface SPIx4 -loadbit \
#                {up 0x00000000 "xxxxxx_tandem1.bit" \
#                 up 0x02000000 "xxxxxx_tandem2.bit" } 




