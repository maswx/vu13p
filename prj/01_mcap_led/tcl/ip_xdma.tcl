create_ip -name xdma -vendor xilinx.com -library ip -module_name xdma_0    

set_property -dict [list \
    CONFIG.axilite_master_en               true        \
	CONFIG.axilite_master_size             1           \
    CONFIG.cfg_mgmt_if                     false       \
    CONFIG.mcap_enablement                 None \
	CONFIG.pcie_extended_tag               false       \
    CONFIG.mode_selection                  Advanced    \
    CONFIG.pl_link_cap_max_link_speed      8.0_GT/s    \
    CONFIG.pl_link_cap_max_link_width      X16         \
    CONFIG.xdma_num_usr_irq                2           \
    CONFIG.xdma_rnum_chnl                  1           \
    CONFIG.xdma_wnum_chnl                  1           \
] [get_ips xdma_0]

#CONFIG.axilite_master_size             1       这个是配AXI Lite的地址空间大小的，单位是1MByte

    #CONFIG.mcap_enablement                 Tandem_PCIe \
    #CONFIG.mcap_enablement                 None \
    #CONFIG.mcap_enablement                 Tandem_PCIe \
    #CONFIG.mcap_enablement                 DFX_over_PCIe\
