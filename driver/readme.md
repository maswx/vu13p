**注意**
xdma 对linux内有有版本要求，不得高于 5.15 ,使用命令 `uname -a` 查看linux 内核版本。
2023年3月实测，xdma不支持 Ubuntu 22.04。 


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

```bash
echo $USER
echo $GROUP
sudo chown $USER:$GROUP /dev/xdma* 
```

4. 开机自动加载驱动

查看是不是已经正确加载了xdma.ko驱动:

```zsh
ll /usr/lib/modules/$(uname -r)/extra # 看一下是不是已经加载
vim /etc/modules-load.d/xdma.conf
```
要在Linux系统开机时自动加载驱动，您可以通过以下步骤实现自动加载 `/usr/lib/modules/$(uname -r)/extra/xdma.ko` 驱动：

**创建模块配置文件：** 在 `/etc/modules-load.d/` 目录下，创建一个新的文件，例如 `xdma.conf`，以指示系统在启动时加载所需的模块。

   ```
   sudo vim /etc/modules-load.d/xdma.conf
   ```

**添加驱动模块名：** 在文件中添加驱动模块的名字，即 `xdma`，每行一个模块名。

   ```
   xdma
   ```

   这将告诉系统在启动时加载 `xdma.ko` 驱动。

**保存文件：** 保存文件并关闭文本编辑器。 将新添加的xdma驱动更新到 `.dep` 文件中。

```
sudo depmod
```

**重启系统：** 重启您的系统，系统会根据配置文件中的内容自动加载驱动模块。

注意事项：
- 确保驱动文件 `xdma.ko` 确实位于 `/usr/lib/modules/$(uname -r)/extra/` 目录下。确保驱动文件路径正确。
- 此方法适用于大多数Linux发行版，但在某些特定的发行版中可能有些差异。如果遇到问题，请查阅您使用的Linux发行版的文档。
- 对于某些情况，还可能需要配置udev规则或其他设置，以确保驱动在加载后拥有正确的权限和访问控制。
- log by masw@20230821: 踩坑了，最近系统自动升级了linux内核，从5.15.0-78-generic 升级到了 5.15.0-79-generic， xdma怎么都加载不上，无奈只能将系统回退到5.15.0-78, 秒OK！谨此记录！

请务必小心操作，确保备份重要数据，并在操作前充分了解您的系统和驱动的配置。

4. 修改开机默认启动后的所有者

```
sudo vim /etc/udev/rules.d/99-xilinx_xdma.rules
```

```
KERNEL=="xdma*", MODE="0777", OWNER="masw", GROUP="masw" # 注意修改所有者
```

```
udevadm control --reload-rules
```


