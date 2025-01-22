VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := alivu13p_top
PART     := xcvu13p-fhgb2104-2L-e
OUTDIR   := ~/alivu13p/01_basebd_gm/
PRJTAG   := base

DEPS_TCL := ./tcl/add_prjfiles.tcl
DEPS_BD  := ./tcl/basebd.tcl
PRJTCL   := ../common/processing.tcl 



TARGET_NAME := $(TOP_NAME)
GBIT_FNAME  := ../01_basebd/alivu13p_top_base.bit
MBIT_FNAME  := $(OUTDIR)/$(TOP_NAME)/$(TOP_NAME).runs/impl_1/$(TOP_NAME)_tandem1.bit
MBADDR      := 0x04000000



include ../common/processing.mk
