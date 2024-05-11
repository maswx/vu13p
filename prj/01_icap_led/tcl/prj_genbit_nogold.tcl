set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]
set tag           [lindex $argv 2]
set current_time  [clock format [clock seconds] -format "%Y%m%d_%H%M"]

open_project ${output_path}/${fpga_top_name}.xpr
open_run impl_1


set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES    [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE        [current_design]
set_property CFGBVS GND                             [current_design]
set_property CONFIG_VOLTAGE 1.8                     [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0       [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes     [current_design]


set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design] ;# multiboot块需要配置这个


write_bitstream    -force ${fpga_top_name}_${current_time}_${tag}.bit
write_debug_probes -force ${fpga_top_name}_${current_time}_${tag}.ltx

