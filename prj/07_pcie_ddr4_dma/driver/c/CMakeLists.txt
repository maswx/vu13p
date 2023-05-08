cmake_minimum_required(VERSION 3.5)
project(MyProject)


# 添加头文件搜索路径
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/iic_v3_9/src)
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/intc_v3_15/src/ )
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/common_v1_2/src )
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/axidma_v9_15/src)
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/iic_v3_9/src    )
include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/clk_wiz_v1_5/src)
#include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/lib/bsp/standalone_v8_0/src/microblaze/)
#include_directories(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/lib/bsp/standalone_v8_0/src/common/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

aux_source_directory(/opt/Xilinx/Vitis/2022.2/data/embeddedsw/XilinxProcessorIPLib/drivers/iic_v3_9/src IIC_LIB_SRC)

# 添加可执行文件
add_executable(MyProject
	           main.c
			   ${IIC_LIB_SRC}
	           )


