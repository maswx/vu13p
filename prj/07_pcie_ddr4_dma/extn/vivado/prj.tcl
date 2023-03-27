set srcfiles   [lindex $argv 0]
set xdcfiles   [lindex $argv 1]
set outputDir  [lindex $argv 2]
set top_module [lindex $argv 3]
set increme    [lindex $argv 4]

file mkdir $outputDir
set projName "fir_prj"

set device     "xcvu13p-fhgb2104-2l-e"
create_project $top_module $outputDir -part $device -force
set_property target_language verilog [current_project]

# 添加 Verilog 文件
source $srcfiles
# 添加 XDC约束文件
source $xdcfiles

# set top module
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1

incremental $increme

