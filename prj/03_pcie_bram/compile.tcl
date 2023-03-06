


                                                                                                                                                              
# 1. 创建工程
source [lindex $argv 0]

## 添加 Verilog 文件
#source [lindex $argv 1]
## 添加 FPGA IP 
#source [lindex $argv 2]
## 添加 XDC约束文件
#source [lindex $argv 3]


incremental on

# 开始编译
launch_runs synth_1 -jobs 8
wait_on_run synth_1


# 生成bin/bit文件
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# 布局布线
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# write_cfgmem -format bin -size 256 -interface SPIx4 -loadbit {up 0x00000000 "xxxxxx.bit" } -file "xxxxxxxxxx.bin"
