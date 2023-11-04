create_ip -name xdma -vendor xilinx.com -library ip -module_name xdma_0    

set_property -dict [list \
    CONFIG.axilite_master_en               true        \
    CONFIG.cfg_mgmt_if                     false       \
    CONFIG.mcap_enablement                 Tandem_PCIe \
    CONFIG.mode_selection                  Advanced    \
    CONFIG.pl_link_cap_max_link_speed      8.0_GT/s    \
    CONFIG.pl_link_cap_max_link_width      X16         \
    CONFIG.xdma_num_usr_irq                8           \
    CONFIG.xdma_rnum_chnl                  4           \
    CONFIG.xdma_wnum_chnl                  4           \
] [get_ips xdma_0]



