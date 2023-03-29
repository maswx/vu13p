# add_files ./fpga_define.v


add_files "
    [glob ../src/iic/i2c_slave.v]
    [glob ../src/iic/i2c_slave_wbm.v]
    [glob ../src/iic/axis_fifo.v]
    [glob ../src/fir/*.v]
    [glob ../src/lib/*.v]
    [glob ../src/top/extn2_top.v]
"


add_files "
	[glob ../../base2/project.srcs/sources_1/bd/base/ip/base*/*.xci]
	[glob ../../base2/project.srcs/sources_1/bd/base/base.bd]
"
