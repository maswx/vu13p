# add_files ./fpga_define.v


add_files "
    [glob ../src/fir/*.v]
    [glob ../src/iic/*.v]
    [glob ../src/lib/*.v]
    [glob ../src/top/*.v]
"


add_files "
	[glob ../../base/project.srcs/sources_1/bd/base/ip/base_*/*.xci]
	[glob ../../base/project.srcs/sources_1/bd/base/base.bd]
"
