

# ../01_mcap_led/tcl/ 
#
#

read_verilog {
	../01_mcap_led/src/xdma_mcap_top.v
	../01_mcap_led/src/example1_app_bram.v
	../01_mcap_led/src/example2_app_led.v
}

read_verilog {
	../../submodule/verilog-axi/rtl/axil_ram.v
	../../submodule/verilog-axi/rtl/axi_ram.v
	../../submodule/verilog-axi/rtl/axil_interconnect.v
	../../submodule/verilog-axi/rtl/arbiter.v
	../../submodule/verilog-axi/rtl/priority_encoder.v
	../01_icap_led/src/axil_interconnect_wrap_1x3.v
	../01_icap_led/src/alex_axil_qspi.v
	../../submodule/verilog-axi/rtl/axil_reg_if.v
	../../submodule/verilog-axi/rtl/axil_reg_if_wr.v
	../../submodule/verilog-axi/rtl/axil_reg_if_rd.v
}

#add_files "
#	[glob ../01_icap_led/src/*.v                   ]
#	[glob ../../submodule/verilog-axi/rtl/*.v      ]
#	[glob ../../submodule/verilog-axis/rtl/*.v     ]
#	[glob ../../submodule/verilog-ethernet/rtl/*.v ]
#	[glob ../../submodule/verilog-i2c/rtl/*.v      ]
#"

read_xdc {
	../../xdc/vu13p_clock.xdc
	../../xdc/vu13p_led.xdc
	../../xdc/vu13p_pcie.xdc
	../../xdc/vu13p_iic.xdc 
	../01_mcap_led/xdc/tandem_pblock_placement.xdc
}             
