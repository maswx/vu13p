VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := alivu13p_top
PART     := xcvu13p-fhgb2104-2L-e
OUTDIR   := ~/alivu13p/01_basebd
PRJTAG   := base

DEPS_TCL := ./tcl/add_prjfiles.tcl
DEPS_BD  := ./tcl/system.tcl
PRJTCL := ../common/processing.tcl 



TARGET_NAME := $(TOP_NAME)
GBIT_FNAME  := $(TOP_NAME)_$(PRJTAG).bit
MBIT_FNAME  := $(GBIT_FNAME)
MBADDR      := 0x04000000


include ../common/processing.mk
