create_ip -name axi_gpio -vendor xilinx.com -library ip -version 2.0 -module_name axi_gpio_0 
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_GPIO_WIDTH {8} \
] [get_ips axi_gpio_0]
