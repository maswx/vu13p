
################################################################
# This is a generated script based on design: xdma_ddr4x4
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source xdma_ddr4x4_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu13p-fhgb2104-2L-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name xdma_ddr4x4

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:xdma:4.1\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:debug_bridge:3.0\
xilinx.com:ip:axi_hwicap:3.0\
xilinx.com:ip:axi_quad_spi:3.2\
xilinx.com:ip:axi_crossbar:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlconcat:2.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: debug_bridge
proc create_hier_cell_debug_bridge { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_debug_bridge() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 PCIE_AXIL


  # Create pins
  create_bd_pin -dir I aclk
  create_bd_pin -dir I aresetn
  create_bd_pin -dir O -from 1 -to 0 irq

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property CONFIG.PROTOCOL {AXI4LITE} $axi_bram_ctrl_0


  # Create instance: debug_bridge_0, and set properties
  set debug_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 debug_bridge_0 ]
  set_property -dict [list \
    CONFIG.C_DEBUG_MODE {2} \
    CONFIG.C_DESIGN_TYPE {1} \
  ] $debug_bridge_0


  # Create instance: axi_hwicap_0, and set properties
  set axi_hwicap_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hwicap:3.0 axi_hwicap_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {0} \
    CONFIG.C_WRITE_FIFO_DEPTH {128} \
  ] $axi_hwicap_0


  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0 ]
  set_property -dict [list \
    CONFIG.Async_Clk {1} \
    CONFIG.C_FIFO_DEPTH {256} \
    CONFIG.C_SPI_MEMORY {2} \
    CONFIG.C_SPI_MODE {2} \
    CONFIG.C_USE_STARTUP {1} \
    CONFIG.C_USE_STARTUP_INT {1} \
    CONFIG.C_XIP_MODE {0} \
    CONFIG.C_XIP_PERF_MODE {0} \
  ] $axi_quad_spi_0


  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property CONFIG.NUM_MI {5} $axi_crossbar_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.PRIM_type_to_Implement {URAM} \
  ] $blk_mem_gen_0


  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf_0 ]
  set_property -dict [list \
    CONFIG.C_BUFGCE_DIV {5} \
    CONFIG.C_BUF_TYPE {BUFGCE_DIV} \
  ] $util_ds_buf_0


  # Create instance: cons_1, and set properties
  set cons_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 cons_1 ]
  set_property CONFIG.CONST_WIDTH {1} $cons_1


  # Create instance: cons_0, and set properties
  set cons_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 cons_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {1} \
  ] $cons_0


  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf_1 ]
  set_property -dict [list \
    CONFIG.C_BUFGCE_DIV {3} \
    CONFIG.C_BUF_TYPE {BUFGCE_DIV} \
  ] $util_ds_buf_1


  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_crossbar_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_pins axi_crossbar_0/M00_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
  connect_bd_intf_net -intf_net axi_crossbar_0_M01_AXI [get_bd_intf_pins axi_crossbar_0/M01_AXI] [get_bd_intf_pins axi_hwicap_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_crossbar_0_M02_AXI [get_bd_intf_pins axi_crossbar_0/M02_AXI] [get_bd_intf_pins debug_bridge_0/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M03_AXI [get_bd_intf_pins axi_crossbar_0/M03_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M04_AXI [get_bd_intf_pins PCIE_AXIL] [get_bd_intf_pins axi_crossbar_0/M04_AXI]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins axi_crossbar_0/aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_hwicap_0/s_axi_aclk] [get_bd_pins axi_quad_spi_0/s_axi_aclk] [get_bd_pins debug_bridge_0/s_axi_aclk] [get_bd_pins util_ds_buf_0/BUFGCE_I] [get_bd_pins util_ds_buf_1/BUFGCE_I]
  connect_bd_net -net aresetn_1 [get_bd_pins aresetn] [get_bd_pins axi_crossbar_0/aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_hwicap_0/s_axi_aresetn] [get_bd_pins axi_quad_spi_0/s_axi_aresetn] [get_bd_pins debug_bridge_0/s_axi_aresetn]
  connect_bd_net -net axi_hwicap_0_ip2intc_irpt [get_bd_pins axi_hwicap_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_quad_spi_0_eos [get_bd_pins axi_quad_spi_0/eos] [get_bd_pins axi_hwicap_0/eos_in]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins axi_quad_spi_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net cons_0_dout [get_bd_pins cons_0/dout] [get_bd_pins util_ds_buf_0/BUFGCE_CLR] [get_bd_pins util_ds_buf_1/BUFGCE_CLR]
  connect_bd_net -net cons_1_dout [get_bd_pins cons_1/dout] [get_bd_pins util_ds_buf_0/BUFGCE_CE] [get_bd_pins util_ds_buf_1/BUFGCE_CE]
  connect_bd_net -net util_ds_buf_0_BUFGCE_O [get_bd_pins util_ds_buf_0/BUFGCE_O] [get_bd_pins axi_quad_spi_0/ext_spi_clk]
  connect_bd_net -net util_ds_buf_1_BUFGCE_O [get_bd_pins util_ds_buf_1/BUFGCE_O] [get_bd_pins axi_hwicap_0/icap_clk]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins irq]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DDR4x4
proc create_hier_cell_DDR4x4 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DDR4x4() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c3_ddr4

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c2_ddr4

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c0_ddr4

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c1_ddr4

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c1_ddr4_clk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c2_ddr4_clk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c3_ddr4_clk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c0_ddr4_clk


  # Create pins
  create_bd_pin -dir I S00_ACLK
  create_bd_pin -dir I S00_ARESETN

  # Create instance: ddr4_1, and set properties
  set ddr4_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_1 ]
  set_property -dict [list \
    CONFIG.C0.BANK_GROUP_WIDTH {1} \
    CONFIG.C0.DDR4_AxiAddressWidth {32} \
    CONFIG.C0.DDR4_AxiArbitrationScheme {RD_PRI_REG} \
    CONFIG.C0.DDR4_AxiDataWidth {512} \
    CONFIG.C0.DDR4_AxiIDWidth {8} \
    CONFIG.C0.DDR4_CasLatency {16} \
    CONFIG.C0.DDR4_CasWriteLatency {12} \
    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
    CONFIG.C0.DDR4_DataWidth {64} \
    CONFIG.C0.DDR4_InputClockPeriod {2499} \
    CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK} \
    CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-083E} \
    CONFIG.C0.DDR4_MemoryType {Components} \
    CONFIG.C0.DDR4_MemoryVoltage {1.2V} \
    CONFIG.C0.DDR4_Ordering {Normal} \
    CONFIG.C0.DDR4_PhyClockRatio {4:1} \
    CONFIG.C0.DDR4_Slot {Single} \
    CONFIG.C0.DDR4_TimePeriod {833} \
  ] $ddr4_1


  # Create instance: ddr4_2, and set properties
  set ddr4_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_2 ]
  set_property -dict [list \
    CONFIG.C0.BANK_GROUP_WIDTH {1} \
    CONFIG.C0.DDR4_AxiAddressWidth {32} \
    CONFIG.C0.DDR4_AxiArbitrationScheme {RD_PRI_REG} \
    CONFIG.C0.DDR4_AxiDataWidth {512} \
    CONFIG.C0.DDR4_AxiIDWidth {8} \
    CONFIG.C0.DDR4_CasLatency {16} \
    CONFIG.C0.DDR4_CasWriteLatency {12} \
    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
    CONFIG.C0.DDR4_DataWidth {64} \
    CONFIG.C0.DDR4_InputClockPeriod {2499} \
    CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK} \
    CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-083E} \
    CONFIG.C0.DDR4_MemoryType {Components} \
    CONFIG.C0.DDR4_MemoryVoltage {1.2V} \
    CONFIG.C0.DDR4_Ordering {Normal} \
    CONFIG.C0.DDR4_PhyClockRatio {4:1} \
    CONFIG.C0.DDR4_Slot {Single} \
    CONFIG.C0.DDR4_TimePeriod {833} \
  ] $ddr4_2


  # Create instance: ddr4_3, and set properties
  set ddr4_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_3 ]
  set_property -dict [list \
    CONFIG.C0.BANK_GROUP_WIDTH {1} \
    CONFIG.C0.DDR4_AxiAddressWidth {32} \
    CONFIG.C0.DDR4_AxiArbitrationScheme {RD_PRI_REG} \
    CONFIG.C0.DDR4_AxiDataWidth {512} \
    CONFIG.C0.DDR4_AxiIDWidth {8} \
    CONFIG.C0.DDR4_CasLatency {16} \
    CONFIG.C0.DDR4_CasWriteLatency {12} \
    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
    CONFIG.C0.DDR4_DataWidth {64} \
    CONFIG.C0.DDR4_InputClockPeriod {2499} \
    CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK} \
    CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-083E} \
    CONFIG.C0.DDR4_MemoryType {Components} \
    CONFIG.C0.DDR4_MemoryVoltage {1.2V} \
    CONFIG.C0.DDR4_Ordering {Normal} \
    CONFIG.C0.DDR4_PhyClockRatio {4:1} \
    CONFIG.C0.DDR4_Slot {Single} \
    CONFIG.C0.DDR4_TimePeriod {833} \
  ] $ddr4_3


  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [list \
    CONFIG.C0.BANK_GROUP_WIDTH {1} \
    CONFIG.C0.DDR4_AxiAddressWidth {32} \
    CONFIG.C0.DDR4_AxiArbitrationScheme {RD_PRI_REG} \
    CONFIG.C0.DDR4_AxiDataWidth {512} \
    CONFIG.C0.DDR4_AxiIDWidth {8} \
    CONFIG.C0.DDR4_CasLatency {16} \
    CONFIG.C0.DDR4_CasWriteLatency {12} \
    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
    CONFIG.C0.DDR4_DataWidth {64} \
    CONFIG.C0.DDR4_InputClockPeriod {2499} \
    CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK} \
    CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-083E} \
    CONFIG.C0.DDR4_MemoryType {Components} \
    CONFIG.C0.DDR4_MemoryVoltage {1.2V} \
    CONFIG.C0.DDR4_Ordering {Normal} \
    CONFIG.C0.DDR4_PhyClockRatio {4:1} \
    CONFIG.C0.DDR4_Slot {Single} \
    CONFIG.C0.DDR4_TimePeriod {833} \
  ] $ddr4_0


  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property CONFIG.NUM_MI {4} $axi_interconnect_0


  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_1


  # Create instance: util_vector_logic_2, and set properties
  set util_vector_logic_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_2 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_2


  # Create instance: util_vector_logic_3, and set properties
  set util_vector_logic_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_3 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_3


  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_2 ]

  # Create instance: proc_sys_reset_3, and set properties
  set proc_sys_reset_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_3 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins ddr4_1/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins ddr4_2/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins ddr4_3/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net c0_ddr4_clk_1 [get_bd_intf_pins c0_ddr4_clk] [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net c1_ddr4_clk_1 [get_bd_intf_pins c1_ddr4_clk] [get_bd_intf_pins ddr4_1/C0_SYS_CLK]
  connect_bd_intf_net -intf_net c2_ddr4_clk_1 [get_bd_intf_pins c2_ddr4_clk] [get_bd_intf_pins ddr4_2/C0_SYS_CLK]
  connect_bd_intf_net -intf_net c3_ddr4_clk_1 [get_bd_intf_pins c3_ddr4_clk] [get_bd_intf_pins ddr4_3/C0_SYS_CLK]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_pins c0_ddr4] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net ddr4_1_C0_DDR4 [get_bd_intf_pins c1_ddr4] [get_bd_intf_pins ddr4_1/C0_DDR4]
  connect_bd_intf_net -intf_net ddr4_2_C0_DDR4 [get_bd_intf_pins c2_ddr4] [get_bd_intf_pins ddr4_2/C0_DDR4]
  connect_bd_intf_net -intf_net ddr4_3_C0_DDR4 [get_bd_intf_pins c3_ddr4] [get_bd_intf_pins ddr4_3/C0_DDR4]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_interconnect_0/S00_AXI]

  # Create port connections
  connect_bd_net -net S00_ACLK_1 [get_bd_pins S00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK]
  connect_bd_net -net S00_ARESETN_1 [get_bd_pins S00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins proc_sys_reset_2/ext_reset_in] [get_bd_pins proc_sys_reset_3/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net ddr4_1_c0_ddr4_ui_clk [get_bd_pins ddr4_1/c0_ddr4_ui_clk] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net ddr4_1_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_1/c0_ddr4_ui_clk_sync_rst] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net ddr4_2_c0_ddr4_ui_clk [get_bd_pins ddr4_2/c0_ddr4_ui_clk] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins proc_sys_reset_2/slowest_sync_clk]
  connect_bd_net -net ddr4_2_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_2/c0_ddr4_ui_clk_sync_rst] [get_bd_pins util_vector_logic_2/Op1]
  connect_bd_net -net ddr4_3_c0_ddr4_ui_clk [get_bd_pins ddr4_3/c0_ddr4_ui_clk] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins proc_sys_reset_3/slowest_sync_clk]
  connect_bd_net -net ddr4_3_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_3/c0_ddr4_ui_clk_sync_rst] [get_bd_pins util_vector_logic_3/Op1]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins ddr4_1/c0_ddr4_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins ddr4_1/sys_rst]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_reset [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins ddr4_0/sys_rst]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn [get_bd_pins proc_sys_reset_2/peripheral_aresetn] [get_bd_pins ddr4_2/c0_ddr4_aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_reset [get_bd_pins proc_sys_reset_2/peripheral_reset] [get_bd_pins ddr4_2/sys_rst]
  connect_bd_net -net proc_sys_reset_3_peripheral_aresetn [get_bd_pins proc_sys_reset_3/peripheral_aresetn] [get_bd_pins ddr4_3/c0_ddr4_aresetn]
  connect_bd_net -net proc_sys_reset_3_peripheral_reset [get_bd_pins proc_sys_reset_3/peripheral_reset] [get_bd_pins ddr4_3/sys_rst]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins util_vector_logic_0/Res] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins util_vector_logic_1/Res] [get_bd_pins axi_interconnect_0/M01_ARESETN]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins util_vector_logic_2/Res] [get_bd_pins axi_interconnect_0/M02_ARESETN]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins util_vector_logic_3/Res] [get_bd_pins axi_interconnect_0/M03_ARESETN]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set c3_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c3_ddr4 ]

  set c2_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c2_ddr4 ]

  set c0_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c0_ddr4 ]

  set c1_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c1_ddr4 ]

  set c1_ddr4_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c1_ddr4_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {400000000} \
   ] $c1_ddr4_clk

  set c2_ddr4_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c2_ddr4_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {400000000} \
   ] $c2_ddr4_clk

  set c3_ddr4_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c3_ddr4_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {400000000} \
   ] $c3_ddr4_clk

  set c0_ddr4_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c0_ddr4_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {400000000} \
   ] $c0_ddr4_clk

  set pcie_lane [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_lane ]

  set pcie_ref [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_ref ]


  # Create ports
  set pcie_link_up [ create_bd_port -dir O pcie_link_up ]
  set pcie_perst_n [ create_bd_port -dir I -type rst pcie_perst_n ]

  # Create instance: DDR4x4
  create_hier_cell_DDR4x4 [current_bd_instance .] DDR4x4

  # Create instance: debug_bridge
  create_hier_cell_debug_bridge [current_bd_instance .] debug_bridge

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf_0 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf_0


  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [list \
    CONFIG.axilite_master_en {true} \
    CONFIG.axilite_master_size {1} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.mcap_enablement {None} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_extended_tag {false} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X16} \
    CONFIG.xdma_num_usr_irq {2} \
    CONFIG.xdma_rnum_chnl {1} \
    CONFIG.xdma_wnum_chnl {1} \
  ] $xdma_0


  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property CONFIG.PROTOCOL {AXI4LITE} $axi_bram_ctrl_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property CONFIG.Memory_Type {True_Dual_Port_RAM} $blk_mem_gen_0


  # Create interface connections
  connect_bd_intf_net -intf_net DDR4x4_c0_ddr4 [get_bd_intf_pins DDR4x4/c0_ddr4] [get_bd_intf_ports c0_ddr4]
  connect_bd_intf_net -intf_net DDR4x4_c1_ddr4 [get_bd_intf_pins DDR4x4/c1_ddr4] [get_bd_intf_ports c1_ddr4]
  connect_bd_intf_net -intf_net DDR4x4_c2_ddr4 [get_bd_intf_pins DDR4x4/c2_ddr4] [get_bd_intf_ports c2_ddr4]
  connect_bd_intf_net -intf_net DDR4x4_c3_ddr4 [get_bd_intf_pins DDR4x4/c3_ddr4] [get_bd_intf_ports c3_ddr4]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net c0_ddr4_clk_1 [get_bd_intf_pins DDR4x4/c0_ddr4_clk] [get_bd_intf_ports c0_ddr4_clk]
  connect_bd_intf_net -intf_net c1_ddr4_clk_1 [get_bd_intf_pins DDR4x4/c1_ddr4_clk] [get_bd_intf_ports c1_ddr4_clk]
  connect_bd_intf_net -intf_net c2_ddr4_clk_1 [get_bd_intf_pins DDR4x4/c2_ddr4_clk] [get_bd_intf_ports c2_ddr4_clk]
  connect_bd_intf_net -intf_net c3_ddr4_clk_1 [get_bd_intf_pins DDR4x4/c3_ddr4_clk] [get_bd_intf_ports c3_ddr4_clk]
  connect_bd_intf_net -intf_net debug_bridge_PCIE_AXIL [get_bd_intf_pins debug_bridge/PCIE_AXIL] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net pcie_ref_1 [get_bd_intf_ports pcie_ref] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins DDR4x4/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins debug_bridge/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_lane] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net debug_bridge_irq [get_bd_pins debug_bridge/irq] [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net pcie_perst_n_1 [get_bd_ports pcie_perst_n] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net util_ds_buf_0_IBUF_DS_ODIV2 [get_bd_pins util_ds_buf_0/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins xdma_0/axi_aclk] [get_bd_pins debug_bridge/aclk] [get_bd_pins DDR4x4/S00_ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins debug_bridge/aresetn] [get_bd_pins DDR4x4/S00_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_pins xdma_0/user_lnk_up] [get_bd_ports pcie_link_up]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs DDR4x4/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x000100000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs DDR4x4/ddr4_1/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x000200000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs DDR4x4/ddr4_2/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x000300000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs DDR4x4/ddr4_3/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x00020000 -range 0x00002000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs debug_bridge/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00050000 -range 0x00002000 -with_name SEG_axi_bram_ctrl_0_Mem0_1 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs debug_bridge/axi_hwicap_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs debug_bridge/axi_quad_spi_0/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs debug_bridge/debug_bridge_0/S_AXI/Reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


