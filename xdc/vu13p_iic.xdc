set_property  -dict {LOC BD8   IOSTANDARD  LVCMOS12 PULLUP true  SLEW SLOW DRIVE 8 }     [get_ports {main_iic_sda}  ] ; # inout
set_property  -dict {LOC BC12  IOSTANDARD  LVCMOS12 PULLUP true  SLEW SLOW DRIVE 8 }     [get_ports {main_iic_scl}  ] ; # inout
# log by xiongyw@20230822：bug here: iic main 的引脚绑定没有逆正确，应该是拖原理图模块时没有选对bank,暂时使用光纤接口的IIC，以保证正确的上拉电平
#
