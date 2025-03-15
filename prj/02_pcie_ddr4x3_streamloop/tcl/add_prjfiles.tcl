




read_verilog {

	./src/pcie_ddr4x3_streamloop.v
}




read_xdc {
    ../../xdc/vu13p_pcie.xdc
    ../../xdc/bitstream.xdc
    ../../xdc/ddr4_64/ddr4_c0.xdc
    ../../xdc/ddr4_64/ddr4_c1.xdc
    ../../xdc/ddr4_64/ddr4_c2.xdc
    ../../xdc/ddr4_64/pblock_ddr4_c0.xdc
    ../../xdc/ddr4_64/pblock_ddr4_c1.xdc
    ../../xdc/ddr4_64/pblock_ddr4_c2.xdc
}
	#./tcl/tandem_pblock_placement.xdc

