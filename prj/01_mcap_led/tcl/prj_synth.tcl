set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]
set core_jobs     [lindex $argv 2]

puts "${output_path}/${fpga_top_name}"

open_project ${output_path}/${fpga_top_name}.xpr
reset_run synth_1
launch_runs -jobs ${core_jobs} synth_1
wait_on_run synth_1

