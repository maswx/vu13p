set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]
set tag           [lindex $argv 2]
set current_time  [clock format [clock seconds] -format "%Y%m%d_%H%M"]

open_project ${output_path}/${fpga_top_name}.xpr
open_run impl_1

write_bitstream    -force ${fpga_top_name}_${current_time}_${tag}.bit
write_debug_probes -force ${fpga_top_name}_${current_time}_${tag}.ltx

write_cfgmem -format bin -file ${fpga_top_name}_${current_time}_${tag}.bin -size 256 -interface SPIx4 -loadbit \
                {up 0x00000000 ${fpga_top_name}_${current_time}_${tag}_tandem1.bit \
                 up 0x02000000 ${fpga_top_name}_${current_time}_${tag}_tandem2.bit } 
			 # 前32M留给tandem1 


