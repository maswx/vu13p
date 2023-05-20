cmake_minimum_required(VERSION 3.5)
project(MyProject)


# 添加头文件搜索路径

include_directories(./include)
include_directories(/usr/include)

#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/iic_v3_9/src)
#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/intc_v3_15/src/ )
#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/common_v1_2/src )
#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/axidma_v9_15/src)
#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/iic_v3_9/src    )
#---include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/clk_wiz_v1_5/src)
#---#include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/lib/bsp/standalone_v8_0/src/common/)

include_directories(../lib/iic)
include_directories(../lib/common)
include_directories(../lib/dma)
include_directories(../lib/clock)

aux_source_directory(../lib/iic/    IIC_LIB_SRC)
aux_source_directory(../lib/common/ IIC_LIB_COM)

# 添加可执行文件
add_executable(iic_test
	           main.c
			   ${IIC_LIB_SRC}
			   ${IIC_LIB_COM}
	           )


