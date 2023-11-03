# bank 64; 100M
set_property -dict {LOC AY23 IOSTANDARD DIFF_SSTL12} [get_ports {clk_100M_p[0]}] ; # input [0:0]clk_100M_p,
set_property -dict {LOC BA23 IOSTANDARD DIFF_SSTL12} [get_ports {clk_100M_n[0]}] ; # input [0:0]clk_100M_n,

# bank 64; 400M
set_property -dict {LOC AY22 IOSTANDARD DIFF_SSTL12} [get_ports clk_400M_p]
set_property -dict {LOC BA22 IOSTANDARD DIFF_SSTL12} [get_ports clk_400M_n]

