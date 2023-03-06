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

set_property PACKAGE_PIN BF5 [get_ports {pcie_lane_txp[0]}]
set_property PACKAGE_PIN BD5 [get_ports {pcie_lane_txp[1]}]
set_property PACKAGE_PIN BB5 [get_ports {pcie_lane_txp[2]}]
set_property PACKAGE_PIN AV7 [get_ports {pcie_lane_txp[3]}]
set_property PACKAGE_PIN AU9 [get_ports {pcie_lane_txp[4]}]
set_property PACKAGE_PIN AT7 [get_ports {pcie_lane_txp[5]}]
set_property PACKAGE_PIN AR9 [get_ports {pcie_lane_txp[6]}]
set_property PACKAGE_PIN AP7 [get_ports {pcie_lane_txp[7]}]
set_property PACKAGE_PIN AN9 [get_ports {pcie_lane_txp[8]}]
set_property PACKAGE_PIN AM7 [get_ports {pcie_lane_txp[9]}]
set_property PACKAGE_PIN AL9 [get_ports {pcie_lane_txp[10]}]
set_property PACKAGE_PIN AK7 [get_ports {pcie_lane_txp[11]}]
set_property PACKAGE_PIN AJ9 [get_ports {pcie_lane_txp[12]}]
set_property PACKAGE_PIN AH7 [get_ports {pcie_lane_txp[13]}]
set_property PACKAGE_PIN AG9 [get_ports {pcie_lane_txp[14]}]
set_property PACKAGE_PIN AF7 [get_ports {pcie_lane_txp[15]}]


