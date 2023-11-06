create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip  -module_name axi_bram_ctrl_0 
set_property -dict [list \
  CONFIG.BMG_INSTANCE {INTERNAL} \
  CONFIG.DATA_WIDTH {512} \
  CONFIG.ID_WIDTH {4} \
  CONFIG.MEM_DEPTH {1024} \
  CONFIG.SINGLE_PORT_BRAM {1} \
] [get_ips axi_bram_ctrl_0]
