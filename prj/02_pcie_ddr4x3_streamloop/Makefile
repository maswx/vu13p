VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := alivu13p_top
PART     := xcvu13p-fhgb2104-2L-e
OUTDIR   := ~/alivu13p/02_pcie_ddr4x3_streamloop

DEPS_TCL := ./tcl/add_prjfiles.tcl
DEPS_BD  := ./tcl/system.tcl
PRJTCL := ../common/processing.tcl 

TARGET_NAME := $(TOP_NAME)
GBIT_FNAME  := $(OUTDIR)/$(TOP_NAME)/$(TOP_NAME).runs/impl_1/$(TOP_NAME)_tandem1.bit


include ../common/processing.mk
