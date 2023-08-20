# add_files ./fpga_define.v


add_files "
    [glob ../src/verilog-i2c/rtl/*.v]
    [glob ../src/fir/*.v]
    [glob ../src/lib/*.v]
    [glob ../src/top/extn_top.v]
"


add_files "
	[glob ../../base/project/project.srcs/sources_1/bd/base/ip/base*/*.xci]
	[glob ../../base/project/project.srcs/sources_1/bd/base/base.bd]
"
