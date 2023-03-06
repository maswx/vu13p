## PCIE 只需要约束时钟源以及 复位引脚，
## 其他无需约束，配置XDMA时，PCIe Block Location 选择 X0Y1 即可。
#  x1  所用通道为227
#  x4  所用通道为227
#  x8  所用通道为227 + 226
#  x16 所用通道为227 + 226/225/224

set_property PACKAGE_PIN AK10 [get_ports {pcie_ref_clk_n[0]}]
set_property PACKAGE_PIN AK11 [get_ports {pcie_ref_clk_p[0]}] 

set_property PACKAGE_PIN AR26 [get_ports pcie_perst]
set_property IOSTANDARD LVCMOS12 [get_ports pcie_perst]

set_property PACKAGE_PIN BD20 [get_ports pcie_lnk_up]
set_property IOSTANDARD LVCMOS12 [get_ports pcie_lnk_up]




