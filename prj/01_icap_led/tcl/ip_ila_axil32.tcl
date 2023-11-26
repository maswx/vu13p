create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_axil32 
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {2048} \
  CONFIG.C_MONITOR_TYPE {AXI} \
  CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4LITE} \
  CONFIG.Component_Name {ila_axil32} \
] [get_ips ila_axil32]
