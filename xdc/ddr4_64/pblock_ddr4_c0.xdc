create_pblock pblock_ddr4_0
resize_pblock pblock_ddr4_0 -add CLOCKREGION_X4Y12:CLOCKREGION_X4Y14
add_cells_to_pblock pblock_ddr4_0 [get_cells -hier ddr4_0] -clear_locs
