set fpga_top_name [lindex $argv 0]
set output_path   [lindex $argv 1]

file mkdir -p ${output_path}

#1. 创建工程
create_project -force -part xcvu13p-fhgb2104-2L-e ${output_path}/${fpga_top_name}

#2. 添加rtl文件 和约束文件
source ./tcl/add_sources.tcl
source ./tcl/add_constrs.tcl

#3. 配置top
set_property top ${fpga_top_name} [current_fileset]

#4. 添加IP
source ./tcl/ip_xdma.tcl
source ./tcl/ip_qspi.tcl

#5. 修改全局配置
source ./tcl/config.tcl
