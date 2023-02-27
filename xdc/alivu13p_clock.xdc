#---# 差分输入,bank64 ,100M
#---AY23 clk0_p
#---BA23 clk0_n
#---
#---# 单端输入N端，H26, bank71  , 400M
#---J26  clk1_p
#---H26  clk1_n
#---
#---# 短短输入N端，G24, bank74  , 400M
#---G25  clk2_p
#---G24  clk2_n
#---
#---# 单端输入P端，AW14, bank67  ,400.000M
#---AW14 clk3_p
#---AW13 clk3_n
#---
#---# 差分输入 ,bank63 400M 
#---AE31 clk4_p
#---AE32 clk4_n


#- AY23  IO_L12P_T1U_N10_GC_64               1U                 64    HP        1                  
#- BA23  IO_L12N_T1U_N11_GC_64               1U                 64    HP        1                  
#- J26   IO_L13P_T2L_N0_GC_QBC_71            2L                 71    HP        2                  
#- H26   IO_L13N_T2L_N1_GC_QBC_71            2L                 71    HP        2                  
#- G25   IO_L13P_T2L_N0_GC_QBC_74            2L                 74    HP        3                  
#- G24   IO_L13N_T2L_N1_GC_QBC_74            2L                 74    HP        3                  
#- AW14  IO_L13P_T2L_N0_GC_QBC_67            2L                 67    HP        1                  
#- AW13  IO_L13N_T2L_N1_GC_QBC_67            2L                 67    HP        1                  
#- AE31  IO_L13P_T2L_N0_GC_QBC_63            2L                 63    HP        0                  
#- AE32  IO_L13N_T2L_N1_GC_QBC_63            2L                 63    HP        0                  

set_property PACKAGE_PIN AY23 [get_ports clk0_p]
set_property PACKAGE_PIN BA23 [get_ports clk0_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk0_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk0_n]


set_property PACKAGE_PIN J26  [get_ports clk1]
set_property PACKAGE_PIN G25  [get_ports clk2]
set_property PACKAGE_PIN AW14 [get_ports clk3]

set_property IOSTANDARD LVCMOS12 [get_ports clk1]
set_property IOSTANDARD LVCMOS12 [get_ports clk2]
set_property IOSTANDARD LVCMOS12 [get_ports clk3]

set_property PACKAGE_PIN AE31 [get_ports clk4_p]
set_property PACKAGE_PIN AE32 [get_ports clk4_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk4_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk4_n]


set_property PACKAGE_PIN AY22 [get_ports clk5_p]
set_property PACKAGE_PIN BA22 [get_ports clk5_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk5_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk5_n]

