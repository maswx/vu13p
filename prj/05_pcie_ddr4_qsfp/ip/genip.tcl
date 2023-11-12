## 32bit to 64bit 
create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_dwidth_converter_0 
set_property -dict [list \
  CONFIG.HAS_TKEEP {1} \
  CONFIG.HAS_TLAST {1} \
  CONFIG.M_TDATA_NUM_BYTES {8} \
  CONFIG.S_TDATA_NUM_BYTES {4} \
] [get_ips axis_dwidth_converter_0]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_0 
set_property -dict [list \
  CONFIG.FIFO_DEPTH {1024} \
  CONFIG.HAS_TKEEP {1} \
  CONFIG.HAS_TLAST {1} \
  CONFIG.IS_ACLK_ASYNC {1} \
  CONFIG.TDATA_NUM_BYTES {8} \
  CONFIG.TUSER_WIDTH {1} \
] [get_ips axis_data_fifo_0]


source ../03_10g25g_udp/ip/eth_xcvr_gt.tcl

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_udp 
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {4096} \
  CONFIG.C_MONITOR_TYPE {Native} \
  CONFIG.C_NUM_OF_PROBES {12} \
  CONFIG.C_PROBE0_WIDTH {64} \
  CONFIG.C_PROBE1_WIDTH {8} \
  CONFIG.C_PROBE6_WIDTH {64} \
  CONFIG.C_PROBE7_WIDTH {8} \
  CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH {64} \
  CONFIG.C_SLOT_0_AXIS_TDEST_WIDTH {0} \
  CONFIG.C_SLOT_0_AXIS_TID_WIDTH {0} \
  CONFIG.C_SLOT_0_AXIS_TUSER_WIDTH {0} \
  CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4S} \
  CONFIG.Component_Name {ila_udp} \
] [get_ips ila_udp]


#--## DDR4
#--create_ip -name ddr4 -vendor xilinx.com -library ip -module_name ddr4_0
#--
#--set_property -dict [list \
#--	CONFIG.C0.DDR4_AxiSelection {true}                   \
#--	CONFIG.C0.DDR4_AxiDataWidth {512}                    \
#--	CONFIG.C0.DDR4_AxiIDWidth {8}                        \
#--	CONFIG.C0.DDR4_AxiArbitrationScheme {RD_PRI_REG}     \
#--	CONFIG.C0.DDR4_TimePeriod {833}                      \
#--	CONFIG.C0.DDR4_PhyClockRatio	4:1                  \
#--	CONFIG.C0.DDR4_InputClockPeriod {2499}               \
#--	CONFIG.C0.DDR4_MemoryType	Components               \
#--	CONFIG.C0.DDR4_MemoryPart	MT40A512M16HA-083E       \
#--	CONFIG.C0.DDR4_Slot	Single                           \
#--	CONFIG.C0.DDR4_MemoryVoltage	1.2V                 \
#--	CONFIG.C0.DDR4_DataWidth	64                       \
#--	CONFIG.C0.DDR4_DataMask	DM_NO_DBI                    \
#--	CONFIG.C0.DDR4_Mem_Add_Map	ROW_COLUMN_BANK          \
#--	CONFIG.C0.DDR4_Ordering	Normal                       \
#--	CONFIG.C0.DDR4_BurstLength	8                        \
#--	CONFIG.C0.DDR4_CasLatency	16                       \
#--	CONFIG.C0.DDR4_CasWriteLatency	12                   \
#--] [get_ips ddr4_0]
