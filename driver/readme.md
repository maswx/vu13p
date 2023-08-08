
## DMA驱动安装

1. 先将xilinx官方仓库拉下来

```bash
git submodule update --init --recursive
```

2. make 

```bash
cd ./dma_ip_drivers/XDMA/linux-kernel/xdma
make
sudo make install 
```

3.  加载驱动

```bash
cd ./dma_ip_drivers/XDMA/linux-kernel/tests
sudo ./load_driver.sh
```

如果出现以下提示，才能说明已经正常加载驱动

```bash
➜  tests git:(master) ✗ sudo ./load_driver.sh
interrupt_selection .
Loading driver...insmod xdma.ko interrupt_mode=1 ...

The Kernel module installed correctly and the xmda devices were recognized.
DONE
```

此时查看 `ls /dev/xdma*` 可以看到已经正常加载了驱动

```bash
➜  tests git:(master) ✗ ll /dev/xdma*
crw-rw-rw- 1 root root 511, 36 8月   8 23:51 /dev/xdma0_c2h_0
crw-rw-rw- 1 root root 511, 37 8月   8 23:51 /dev/xdma0_c2h_1
crw-rw-rw- 1 root root 511, 38 8月   8 23:51 /dev/xdma0_c2h_2
crw-rw-rw- 1 root root 511, 39 8月   8 23:51 /dev/xdma0_c2h_3
crw-rw-rw- 1 root root 511,  1 8月   8 23:51 /dev/xdma0_control
crw-rw-rw- 1 root root 511, 10 8月   8 23:51 /dev/xdma0_events_0
crw-rw-rw- 1 root root 511, 11 8月   8 23:51 /dev/xdma0_events_1
crw-rw-rw- 1 root root 511, 20 8月   8 23:51 /dev/xdma0_events_10
crw-rw-rw- 1 root root 511, 21 8月   8 23:51 /dev/xdma0_events_11
crw-rw-rw- 1 root root 511, 22 8月   8 23:51 /dev/xdma0_events_12
crw-rw-rw- 1 root root 511, 23 8月   8 23:51 /dev/xdma0_events_13
crw-rw-rw- 1 root root 511, 24 8月   8 23:51 /dev/xdma0_events_14
crw-rw-rw- 1 root root 511, 25 8月   8 23:51 /dev/xdma0_events_15
crw-rw-rw- 1 root root 511, 12 8月   8 23:51 /dev/xdma0_events_2
crw-rw-rw- 1 root root 511, 13 8月   8 23:51 /dev/xdma0_events_3
crw-rw-rw- 1 root root 511, 14 8月   8 23:51 /dev/xdma0_events_4
crw-rw-rw- 1 root root 511, 15 8月   8 23:51 /dev/xdma0_events_5
crw-rw-rw- 1 root root 511, 16 8月   8 23:51 /dev/xdma0_events_6
crw-rw-rw- 1 root root 511, 17 8月   8 23:51 /dev/xdma0_events_7
crw-rw-rw- 1 root root 511, 18 8月   8 23:51 /dev/xdma0_events_8
crw-rw-rw- 1 root root 511, 19 8月   8 23:51 /dev/xdma0_events_9
crw-rw-rw- 1 root root 511, 32 8月   8 23:51 /dev/xdma0_h2c_0
crw-rw-rw- 1 root root 511, 33 8月   8 23:51 /dev/xdma0_h2c_1
crw-rw-rw- 1 root root 511, 34 8月   8 23:51 /dev/xdma0_h2c_2
crw-rw-rw- 1 root root 511, 35 8月   8 23:51 /dev/xdma0_h2c_3
crw-rw-rw- 1 root root 511,  0 8月   8 23:51 /dev/xdma0_user
crw-rw-rw- 1 root root 511,  2 8月   8 23:51 /dev/xdma0_xvc
```

不过权限为root，每次执行程序往PCIE读写数据时总是要sudo， 建议修改字符设备的权限为自己, 以避免使用sudo执行程序。

```
sudo chown masw:masw /dev/xdma* # 注意将masw修改为你的用户名
```

4. enjoy!
