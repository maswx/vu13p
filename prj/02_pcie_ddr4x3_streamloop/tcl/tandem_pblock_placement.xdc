#set pblock_xdma_axil [get_pblock xdma_mcap_top_inst_xdma_0_inst_inst_pcie4_ip_i_inst_xdma_0_pcie4_ip_Stage1_main]
#resize_pblock ${pblock_xdma_axil} -add CLOCKREGION_X7Y4:CLOCKREGION_X7Y7

set_property HD.TANDEM_IP_PBLOCK Stage1_Main      [get_cells dbg_hub]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main      [get_cells -hier -filter {(ORIG_REF_NAME == ICAPE3    || REF_NAME == ICAPE3   )}]
set_property HD.TANDEM_IP_PBLOCK Stage1_Main      [get_cells -hier -filter {(ORIG_REF_NAME == STARTUPE3 || REF_NAME == STARTUPE3)}] 
set_property HD.TANDEM_IP_PBLOCK Stage1_Main      [get_cells -hier ibufds_gte4_pcie_mgt_refclk_inst];# U+系列都需要这句话
set_property HD.TANDEM_IP_PBLOCK Stage1_IO        [get_cells -hier pcie_perst_n_IBUF_inst/INBUF_INST];# U+系列都需要这句话
#set_property HD.TANDEM_IP_PBLOCK Stage1_IO        [get_cells -hier pcie_link_up_OBUF_inst/ONBUF_INST];# 这个可要可不要


