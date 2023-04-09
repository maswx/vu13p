set bitname [lindex $argv 0] 
open_hw_manager
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices xcvu13p_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu13p_0] 0]
#program_hw_devices -file $bitname 
set_property PROBES.FILE {} [get_hw_devices xcvu13p_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xcvu13p_0]
set_property PROGRAM.FILE $bitname [get_hw_devices xcvu13p_0]
program_hw_devices [get_hw_devices xcvu13p_0]
refresh_hw_device [lindex [get_hw_devices xcvu13p_0] 0]

