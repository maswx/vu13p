set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]

# MCAP 不使用multipleStage2
set_param bitstream.enableMultipleStage2 false

# write_cfgmem -format bin -size 256 -interface SPIx4 -loadbit {up 0x00000000 "xxxxxx.bit" } -file "xxxxxxxxxx.bin"


