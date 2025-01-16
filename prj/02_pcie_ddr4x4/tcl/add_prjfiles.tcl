

read_verilog {
	./src/xdma_ddr4x4_top.v
}


read_xdc {
	../../xdc/vu13p_pcie.xdc
	../../xdc/bitstream.xdc
	../../xdc/ddr4_64/ddr4_c0.xdc
	../../xdc/ddr4_64/ddr4_c1.xdc
	../../xdc/ddr4_64/ddr4_c2.xdc
	../../xdc/ddr4_64/ddr4_c3.xdc
}
