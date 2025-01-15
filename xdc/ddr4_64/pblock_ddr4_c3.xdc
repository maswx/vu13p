create_pblock pblock_ddr4_3
resize_pblock pblock_ddr4_3 -add CLOCKREGION_X4Y5:CLOCKREGION_X4Y7
add_cells_to_pblock pblock_ddr4_3 [get_cells -hier ddr4_3] -clear_locs
