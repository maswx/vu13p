cmake_minimum_required(VERSION 3.5)
project(MyProject)


# 添加头文件搜索路径


include_directories(./include)
include_directories(./src)

aux_source_directory(./src/     LIB_SRC)
#aux_source_directory(./xqspips_g128_flash_example.c     LIB_EXP)
aux_source_directory(./include/  LIB_COM)



# 添加可执行文件
add_executable(xspi_winbond_flash_quad_example
	           xspi_winbond_flash_quad_example.c
			   ${LIB_SRC}
			   ${LIB_EXP}
			   ${LIB_COM}
	           )


