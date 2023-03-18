


* 编译工程

请确保你已经正常安装了vivado, 查看vivado路径

```shell
which -a vivado 

```

如果没有，则需要source 一下

```shell
source /opt/Xilinx/Vivado/2022.2/settings64.sh
```

如果你像我一样使用zsh , 那只能添加路径到 ~/.zshrc
```shell
export  PATH=/opt/Xilinx/Vivado/2022.2/bin/:$PATH
```


编译工程。

```shell
make
```

如果你的机器支持多核CPU，诸如线程撕裂者，可以修改 `./compile.tcl`中 `launch_runs synth_1 -jobs 8` 的jobs的个数，比如我通常会修改为12以加快编译速度


### 02_pcie_ddr4x4

* 总体结构
![](./images/pciex16_4xddr4_bram.png)

* 地址分配
![](./images/pciex16_4xddr4_bram_addr.png)
	
* MIG OK
![](./images/pciex16_4xddr4_bram_ok.png)

* C OK
![](./images/pciex16_4xddr4_bram_testOK.png)


