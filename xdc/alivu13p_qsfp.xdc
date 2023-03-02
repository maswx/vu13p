

## 无需约束。
# 离PCIE金手指较远的通道选择 233 即可, 对应位置 X1Y52~Y55
# 离PCIE金手指较近的通道选择 230 即可, 对应位置 X1Y40~Y43

set_property PACKAGE_PIN    BD21 [get_ports {qsfp_led_y[0]}]
set_property PACKAGE_PIN    BE21 [get_ports {qsfp_led_y[1]}]
set_property PACKAGE_PIN    BE22 [get_ports {qsfp_led_g[0]}]
set_property PACKAGE_PIN    BF22 [get_ports {qsfp_led_g[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_led_y[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_led_y[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_led_g[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_led_g[1]}]


set_property PACKAGE_PIN A9  [get_ports {up_qsfp3_tx_p}]
set_property PACKAGE_PIN A5  [get_ports {up_qsfp3_rx_p}]
set_property PACKAGE_PIN A4  [get_ports {up_qsfp3_rx_n}]
set_property PACKAGE_PIN A8  [get_ports {up_qsfp3_tx_n}]
set_property PACKAGE_PIN C9  [get_ports {up_qsfp2_tx_p}]
set_property PACKAGE_PIN C4  [get_ports {up_qsfp2_rx_p}]
set_property PACKAGE_PIN C3  [get_ports {up_qsfp2_rx_n}]
set_property PACKAGE_PIN C8  [get_ports {up_qsfp2_tx_n}]
set_property PACKAGE_PIN D7  [get_ports {up_qsfp1_tx_p}]
set_property PACKAGE_PIN D2  [get_ports {up_qsfp1_rx_p}]
set_property PACKAGE_PIN D1  [get_ports {up_qsfp1_rx_n}]
set_property PACKAGE_PIN D6  [get_ports {up_qsfp1_tx_n}]
set_property PACKAGE_PIN E9  [get_ports {up_qsfp0_tx_p}]
set_property PACKAGE_PIN E4  [get_ports {up_qsfp0_rx_p}]
set_property PACKAGE_PIN E3  [get_ports {up_qsfp0_rx_n}]
set_property PACKAGE_PIN E8  [get_ports {up_qsfp0_tx_n}]
set_property PACKAGE_PIN    B11     [get_ports up_qsfp161_clk_p]
set_property PACKAGE_PIN    B10     [get_ports up_qsfp161_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports up_qsfp161_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports up_qsfp161_clk_n]
set_property PACKAGE_PIN    D11     [get_ports up_qsfp_si570_clk_p]
set_property PACKAGE_PIN    D10     [get_ports up_qsfp_si570_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports up_qsfp_si570_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports up_qsfp_si570_clk_n]

set_property PACKAGE_PIN BB7  [get_ports {up_qsfp_lpmode}]
set_property PACKAGE_PIN BB11 [get_ports {up_qsfp_modprsl}]
set_property PACKAGE_PIN BB10 [get_ports {up_qsfp_resetl}]
set_property PACKAGE_PIN BC11 [get_ports {up_qsfp_intl}]
set_property PACKAGE_PIN BD9  [get_ports {up_qsfp_i2c_sda}]
set_property PACKAGE_PIN BF12 [get_ports {up_qsfp_i2c_scl}]



set_property PACKAGE_PIN P7 [get_ports {dn_qsfp3_tx_p}]
set_property PACKAGE_PIN P2 [get_ports {dn_qsfp3_rx_p}]
set_property PACKAGE_PIN P1 [get_ports {dn_qsfp3_rx_n}]
set_property PACKAGE_PIN P6 [get_ports {dn_qsfp3_tx_n}]
set_property PACKAGE_PIN R9 [get_ports {dn_qsfp2_tx_p}]
set_property PACKAGE_PIN R4 [get_ports {dn_qsfp2_rx_p}]
set_property PACKAGE_PIN R3 [get_ports {dn_qsfp2_rx_n}]
set_property PACKAGE_PIN R8 [get_ports {dn_qsfp2_tx_n}]
set_property PACKAGE_PIN T7 [get_ports {dn_qsfp1_tx_p}]
set_property PACKAGE_PIN T2 [get_ports {dn_qsfp1_rx_p}]
set_property PACKAGE_PIN T1 [get_ports {dn_qsfp1_rx_n}]
set_property PACKAGE_PIN T6 [get_ports {dn_qsfp1_tx_n}]
set_property PACKAGE_PIN U9 [get_ports {dn_qsfp0_tx_p}]
set_property PACKAGE_PIN U4 [get_ports {dn_qsfp0_rx_p}]
set_property PACKAGE_PIN U3 [get_ports {dn_qsfp0_rx_n}]
set_property PACKAGE_PIN U8 [get_ports {dn_qsfp0_tx_n}]
set_property PACKAGE_PIN    P11     [get_ports dn_qsfp161_clk_p]
set_property PACKAGE_PIN    P10     [get_ports dn_qsfp161_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports dn_qsfp161_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports dn_qsfp161_clk_n]
set_property PACKAGE_PIN    T11     [get_ports dn_qsfp_si570_clk_p]
set_property PACKAGE_PIN    T10     [get_ports dn_qsfp_si570_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports dn_qsfp_si570_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports dn_qsfp_si570_clk_n]

set_property PACKAGE_PIN BC8  [get_ports {dn_qsfp_lpmode}]
set_property PACKAGE_PIN BC7  [get_ports {dn_qsfp_resetl}]
set_property PACKAGE_PIN BD8  [get_ports {dn_qsfp_i2c_scL}]
set_property PACKAGE_PIN BC12 [get_ports {dn_qsfp_i2c_sdA}]
 
 
##-- A9    MGTYTXP3_233                        NA                 233   GTY       3                  
##-- A5    MGTYRXP3_233                        NA                 233   GTY       3                  
##-- A4    MGTYRXN3_233                        NA                 233   GTY       3                  
##-- A8    MGTYTXN3_233                        NA                 233   GTY       3                  
##-- B11   MGTREFCLK1P_233                     NA                 233   GTY       3                  
##-- B10   MGTREFCLK1N_233                     NA                 233   GTY       3                  
##-- C9    MGTYTXP2_233                        NA                 233   GTY       3                  
##-- C4    MGTYRXP2_233                        NA                 233   GTY       3                  
##-- C3    MGTYRXN2_233                        NA                 233   GTY       3                  
##-- C8    MGTYTXN2_233                        NA                 233   GTY       3                  
##-- D7    MGTYTXP1_233                        NA                 233   GTY       3                  
##-- D2    MGTYRXP1_233                        NA                 233   GTY       3                  
##-- D1    MGTYRXN1_233                        NA                 233   GTY       3                  
##-- D6    MGTYTXN1_233                        NA                 233   GTY       3                  
##-- D11   MGTREFCLK0P_233                     NA                 233   GTY       3                  
##-- D10   MGTREFCLK0N_233                     NA                 233   GTY       3                  
##-- E9    MGTYTXP0_233                        NA                 233   GTY       3                  
##-- E4    MGTYRXP0_233                        NA                 233   GTY       3                  
##-- E3    MGTYRXN0_233                        NA                 233   GTY       3                  
##-- E8    MGTYTXN0_233                        NA                 233   GTY       3                  

##-- P7    MGTYTXP3_230                        NA                 230   GTY       2                  
##-- P2    MGTYRXP3_230                        NA                 230   GTY       2                  
##-- P1    MGTYRXN3_230                        NA                 230   GTY       2                  
##-- P6    MGTYTXN3_230                        NA                 230   GTY       2                  
##-- P11   MGTREFCLK1P_230                     NA                 230   GTY       2                  
##-- P10   MGTREFCLK1N_230                     NA                 230   GTY       2                  
##-- R9    MGTYTXP2_230                        NA                 230   GTY       2                  
##-- R4    MGTYRXP2_230                        NA                 230   GTY       2                  
##-- R3    MGTYRXN2_230                        NA                 230   GTY       2                  
##-- R8    MGTYTXN2_230                        NA                 230   GTY       2                  
##-- T7    MGTYTXP1_230                        NA                 230   GTY       2                  
##-- T2    MGTYRXP1_230                        NA                 230   GTY       2                  
##-- T1    MGTYRXN1_230                        NA                 230   GTY       2                  
##-- T6    MGTYTXN1_230                        NA                 230   GTY       2                  
##-- T11   MGTREFCLK0P_230                     NA                 230   GTY       2                  
##-- T10   MGTREFCLK0N_230                     NA                 230   GTY       2                  
##-- U9    MGTYTXP0_230                        NA                 230   GTY       2                  
##-- U4    MGTYRXP0_230                        NA                 230   GTY       2                  
##-- U3    MGTYRXN0_230                        NA                 230   GTY       2                  
##-- U8    MGTYTXN0_230                        NA                 230   GTY       2                  
