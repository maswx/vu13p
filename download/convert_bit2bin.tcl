# creat by masw@masw.tech using ChatGPT-4

# 获取命令行参数中的bit文件名
set bitname [lindex $argv 0]

# 获取绝对路径
set abs_bitname [file normalize $bitname]

# 提取文件名（不包括路径和扩展名）
set file_name [file rootname [file tail $abs_bitname]]

# 生成对应的bin文件名
set binname "${file_name}.bin"

# 打印生成的bin文件名
puts "Generated bin file name: $binname from $bitname"

# 使用新变量进行转换
set load_command "up 0x00000000 \"$abs_bitname\""
set write_cfgmem_command "write_cfgmem -format bin -size 256 -interface SPIx4 -loadbit {$load_command} -file \"$binname\""

# 执行转换命令
eval $write_cfgmem_command

