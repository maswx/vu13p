
* 编译工程

目前只支持 prj/02_pcie_ddr4x4 . 有空再全部做成 tcl 脚本。

```shell
cd prj/02_pcie_ddr4x4
vivado -mode batch -source project.tcl
```

```tcl

# 开始编译 
launch_runs synth_1 -jobs 8
wait_on_run synth_1


# 生成bin/bit文件
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# 布局布线
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# 开启GUI
start_gui

```

### 02_pcie_ddr4x4

* 总体结构
![](./prj/02_pcie_ddr4x4/images/pciex16_4xddr4_bram.png)

* 地址分配
![](./prj/02_pcie_ddr4x4/images/pciex16_4xddr4_bram_addr.png)
	
* MIG OK
![](./prj/02_pcie_ddr4x4/images/pciex16_4xddr4_bram_ok.png)

* C OK
![](./prj/02_pcie_ddr4x4/images/pciex16_4xddr4_bram_testOK.png)


