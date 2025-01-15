create_pblock pblock_ddr4_1
resize_pblock pblock_ddr4_1 -add CLOCKREGION_X4Y9:CLOCKREGION_X4Y11
add_cells_to_pblock pblock_ddr4_1 [get_cells -hier ddr4_1] -clear_locs
