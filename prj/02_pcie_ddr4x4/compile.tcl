
set orig_proj_dir  ./project
set origin_dir     ./
source project.tcl

# 开始编译 
launch_runs synth_1 -jobs 8
wait_on_run synth_1


# 生成bin/bit文件
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# 布局布线
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# 开启GUI
# start_gui
