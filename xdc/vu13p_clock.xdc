
# bank 64; 100M
set_property PACKAGE_PIN AY23 [get_ports {clk_100M_p[0]}]
set_property PACKAGE_PIN BA23 [get_ports {clk_100M_n[0]}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {clk_100M_p[0]}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {clk_100M_n[0]}]


# bank 64; 400M
set_property PACKAGE_PIN AY22 [get_ports clk_400M_p]
set_property PACKAGE_PIN BA22 [get_ports clk_400M_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_400M_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_400M_n]

