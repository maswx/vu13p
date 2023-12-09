
add_files -fileset sources_1 {
	./src/xdma_mcap_top.v
	./src/example1_app_bram.v
	./src/example2_app_led.v
}

add_files "
	[glob ../01_icap_led/src/*.v                   ]
	[glob ../../submodule/verilog-axi/rtl/*.v      ]
	[glob ../../submodule/verilog-axis/rtl/*.v     ]
	[glob ../../submodule/verilog-ethernet/rtl/*.v ]
	[glob ../../submodule/verilog-i2c/rtl/*.v      ]
"
