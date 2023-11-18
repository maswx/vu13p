set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]
set core_jobs     [lindex $argv 2]


# 综合
open_project ${output_path}/${fpga_top_name}.xpr
reset_run synth_1
launch_runs -jobs ${core_jobs} synth_1
wait_on_run synth_1

# 布局布线
launch_runs -jobs ${core_jobs} impl_1
wait_on_run impl_1

#  生成bit
set current_time  [clock format [clock seconds] -format "%Y%m%d_%H%M"]

open_run impl_1
write_bitstream    -force ${fpga_top_name}_${current_time}.bit
#write_debug_probes -force ${fpga_top_name}_${current_time}.ltx
#write_hw_platform -fixed -force -file ${fpga_top_name}_${current_time}_${tag}.xsa
