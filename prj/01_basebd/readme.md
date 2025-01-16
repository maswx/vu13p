
## basebd

这里提供一个基础的 bd文件用于提供给用户二次开发。


## 编译 

使用 `make` 编译工程，编译结束后 使用`make genmcs` 生成 mcs固件


## 烧录

第一次使用jtag 将 mcs固件 写入 QSPI Flash ,后续就可以不使用jtag了

## 启动

烧录OK后重启操作系统

## 测试



1. 测试 bram :  `cd driver/test_bram`
2. 测试 LED  :  `cd driver/test_led/`
3. 测试 XVC  :  DDDD 
