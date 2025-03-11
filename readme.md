
### 国产vu13p 资料

* 有任何问题，请在[issue](https://github.com/maswx/vu13p/issues)中编写，记录。
* 有引用第三方仓库, 请使用命令` git clone --recurse-submodules https://github.com/maswx/vu13p.git ` 拉取全部仓库


### 如何使用

#### [00 pin uart](./prj/00_pin_uart/README.md)

* 会自己说话, 作自我介绍的引脚！
* 逆向工程，懂的都懂 DDDD
* 已验证 ✔

#### [01_basebd](./prj/01_basebd/readme.md)

* 基础的BD和工程脚本的example
  * Makefile脚本和公共的工程tcl文件
  * GPIO 驱动LED灯

#### [01_basebd_golden](./prj/01_basebd_golden/readme.md)

* 板卡的基础golden镜像，可以固化到QSPI中
  * GPIO 驱动LED
  * BRAM 测试程序
  * QSPI 驱动程序
  * AXI XVC example

#### [01_basebd_multiboot](./prj/01_basebd_mb/readme.md)

* 板卡的基础 multiboot 镜像，可以固化到QSPI的multiboot中
  * 仅仅包含QSPI 驱动程序


#### [01 mcap_goldmb](./prj/01_mcap_goldmb/docs/readme.md)

* 介绍如何通过PCIE走mcap下载固件
* 从QSPI启动Tandem PCIE main stage, 从PCIE更新其他bit
  * 使用tcl划分多个编译区(已验证 ✔)
  * pcie-mcap下载bit(已验证 ✔)

#### [02 pcie ddr4x4](./prj/02_pcie_ddr4x4/readme.md)

* 测试板载4组DDR4内存
* 介绍PCIE相关驱动
  * 支持16GB DDR4 读写/测速度[例程](./prj/02_pcie_ddr4x4/driver/ddr4test/src/main.c) (已验证 ✔)
  * 一个简单的上位机中断[example](./prj/02_pcie_ddr4x4/driver/intptest/src/xdma0_events_0_example.c) (已验证 ✔)

#### [03 10G/25G UDP](./prj/03_10g25g_udp/README.md)

* `make`编译工程!
* 基于Alex的工作,  Alex YYDS!
* UDP已通！
* 项目已验证 ✔

#### [04 100G Corundum](./prj/04_100G_corundum/readme.md)

* 起飞
* 项目已验证 ✔

#### [05 UDP + Gnuradio]

* 开发中

#### [06 PCIe + MATLAB]

* TODO

#### [07 QDMA + DPDK]

* TODO

#### [08 PCIe + DSLogic]

* 长期计划
* 不定期更新



### 致谢

* 感谢  章鱼哥  提供部分 DDR4 约束
* 感谢 冻结旋律 提供部分逆向资料
