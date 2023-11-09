add_files -fileset sources_1                       ./src/define.v
set_property file_type "Verilog Header" [get_files ./src/define.v]
set_property is_global_include true     [get_files ./src/define.v]

add_files -fileset sources_1 {
	./src/fpga_reboot.v 
	./src/mcap_led_top.v
	./src/tandem_app_bram.v
	./src/tandem_app_axixvc.v
	./src/tandem_app_led.v
	./src/xdma_mcap_qspi.v
	./src/axil_interconnect_wrap_1x5.v
}

add_files "
	[glob ../../submodule/verilog-axi/rtl/*.v      ]
	[glob ../../submodule/verilog-axis/rtl/*.v     ]
	[glob ../../submodule/verilog-ethernet/rtl/*.v ]
	[glob ../../submodule/verilog-i2c/rtl/*.v      ]
"
