set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]

# PCIe 请选择 tandem Pcie
#
#set bscan_cells [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ CONFIGURATION.BSCAN.*}]
#set_property HD.TANDEM_IP_PBLOCK Stage1_Main $bscan_cells
#set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ CONFIGURATION.BSCAN.*}]
set_property HD.OVERRIDE_PERSIST false [current_design]
set_property HD.TANDEM_BITSTREAMS Separate [current_design]
#set_property HD.TANDEM_IP_PBLOCK Stage1_Config_IO [get_cells sys_reset_n_ibuf]  
#set_property HD.TANDEM_IP_PBLOCK Stage1_Main [get_cells util_ds_buf_0]

# write_cfgmem -format bin -size 256 -interface SPIx4 -loadbit {up 0x00000000 "xxxxxx.bit" } -file "xxxxxxxxxx.bin"



