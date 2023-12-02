add_files -fileset sources_1                       ./src/define.v
set_property file_type "Verilog Header" [get_files ./src/define.v]
set_property is_global_include true     [get_files ./src/define.v]

add_files -fileset sources_1 {
	./src/example1_led_top.v
	./src/example2_bram_top.v
	./src/golden_image_top.v
}

add_files "
	[glob ./src/*.v      ]
	[glob ../../submodule/verilog-axi/rtl/*.v      ]
	[glob ../../submodule/verilog-axis/rtl/*.v     ]
	[glob ../../submodule/verilog-ethernet/rtl/*.v ]
	[glob ../../submodule/verilog-i2c/rtl/*.v      ]
"
