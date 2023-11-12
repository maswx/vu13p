add_files -fileset sources_1                       ./src/define.v
set_property file_type "Verilog Header" [get_files ./src/define.v]
set_property is_global_include true     [get_files ./src/define.v]

add_files -fileset sources_1 {
	./src/data_mover_ctrl.v
	./src/data_mover_top.v
	./src/define.v
	./src/udp64_sfp_top.v
}

add_files -fileset sources_1 {
	./ip/base.bd
}
add_files -fileset sources_1 {
	../03_10g25g_udp/rtl/debounce_switch.v
	../03_10g25g_udp/rtl/eth_xcvr_phy_quad_wrapper.v
	../03_10g25g_udp/rtl/eth_xcvr_phy_wrapper.v
	../03_10g25g_udp/rtl/sync_signal.v
}       

add_files "
	[glob ../../submodule/verilog-axi/rtl/*.v      ]
	[glob ../../submodule/verilog-axis/rtl/*.v     ]
	[glob ../../submodule/verilog-ethernet/rtl/*.v ]
	[glob ../../submodule/verilog-i2c/rtl/*.v      ]
"
