if {[get_ips debug_bridge_0] eq ""} {
	create_ip -name debug_bridge -vendor xilinx.com -library ip -module_name debug_bridge_0
	set_property -dict [list \
		CONFIG.C_DEBUG_MODE  {2} \
		CONFIG.C_DESIGN_TYPE {1} \
	] [get_ips debug_bridge_0]
}
# log by masw@masw.tech
# CONFIG.C_DEBUG_MODE  {2}  意思是 使用DFX的可重配区域， debug bridge 不允许放在 tandem的主区域
# CONFIG.C_DESIGN_TYPE {1}  意思是 From AXI to BSCAN

