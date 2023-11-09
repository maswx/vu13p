create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip  -module_name axi_bram_ctrl_1
set_property -dict [list \
  CONFIG.BMG_INSTANCE {INTERNAL} \
  CONFIG.MEM_DEPTH {1024} \
  CONFIG.PROTOCOL {AXI4LITE} \
  CONFIG.SINGLE_PORT_BRAM {1} \
] [get_ips axi_bram_ctrl_1]
