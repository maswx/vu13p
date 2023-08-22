###set_property PACKAGE_PIN  BD9       [get_ports {main_iic_sda}]
###set_property PACKAGE_PIN  BD12       [get_ports {main_iic_scl}]
#### log by xiongyw@20230822：bug here: iic main 的引脚绑定没有逆正确，应该是拖原理图模块时没有选对bank,暂时使用光纤接口的IIC，以保证正确的上拉电平
#### set_property PACKAGE_PIN  AR28       [get_ports {main_iic_sda}]
#### set_property PACKAGE_PIN  AP26       [get_ports {main_iic_scl}]
###set_property PULLUP true             [get_ports {main_iic_sda}]
###set_property PULLUP true             [get_ports {main_iic_scl}]
###set_property IOSTANDARD LVCMOS12     [get_ports {main_iic_sda}]
###set_property IOSTANDARD LVCMOS12     [get_ports {main_iic_scl}]
