VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := alivu13p_top
PART     := xcvu13p-fhgb2104-2L-e
OUTDIR   := ~/alivu13p/01_mcap_gm
PRJTAG   := golden


DEPS_TCL := ./tcl/add_prjfiles.tcl
DEPS_BD  := ../01_basebd/tcl/system.tcl
PRJTCL   := ../common/processing.tcl 

TARGET_NAME := $(TOP_NAME)
GBIT_FNAME  := $(TOP_NAME)_$(PRJTAG).bit
MBIT_FNAME  := ../01_basebd/alivu13p_top_base.bit
MBADDR      := 0x08000000


	
include ../common/processing.mk
