
### 国产vu13p 资料

* 有任何问题，请在[issue](https://github.com/maswx/vu13p/issues)中编写，记录。
* 有引用第三方仓库, 请使用命令` git clone --recurse-submodules https://github.com/maswx/vu13p.git ` 拉取全部仓库


### 如何使用

#### [00_pin_uart](./prj/00_pin_uart/README.md)

* 逆向工程，懂的都懂 DDDD

#### [01 tandem PCIe](./prj/01_mcap_led/docs/readme.md)

* 介绍如何通过PCIE下载固件
* 支持远程更新QSPI，更新QSPI后，支持从QSPI暖重启FPGA而无需重启PC
* 支持PCIe-XVC

#### [02 pcie ddr4x4](./prj/02_pcie_ddr4x4/readme.md)

* 测试板载4组DDR4内存
* 介绍PCIE相关驱动

#### [03 100G CMAC]

* 100G 以太网 + UDP

#### [04_10G/25G eth]

* 10G/25G eth

#### [05 UDP + Gnuradio]

* TODO

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
