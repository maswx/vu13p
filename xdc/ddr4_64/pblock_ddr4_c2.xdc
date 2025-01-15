create_pblock pblock_ddr4_2
resize_pblock pblock_ddr4_2 -add CLOCKREGION_X4Y1:CLOCKREGION_X4Y3
add_cells_to_pblock pblock_ddr4_2 [get_cells -hier ddr4_2] -clear_locs
