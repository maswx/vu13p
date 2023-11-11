set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]
set core_jobs     [lindex $argv 2]

open_project ${output_path}/${fpga_top_name}.xpr
reset_run impl_1
launch_runs -jobs ${core_jobs} impl_1
wait_on_run impl_1
open_run impl_1
#report_utilization -file fpga_utilization.rpt
#report_utilization -hierarchical -file fpga_utilization_hierarchical.rpt

