VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := alivu13p_top
PART     := xcvu13p-fhgb2104-2L-e
OUTDIR   := ~/alivu13p/01_basebd
PRJTAG   := base

DEPS_TCL := ./tcl/add_prjfiles.tcl
DEPS_BD  := ./tcl/system.tcl
PRJTCL := ../common/processing.tcl 



#TARGET_NAME := $(TOP_NAME)
#GBIT_FNAME  := $(TOP_NAME)_$(PRJTAG).bit
##MBIT_FNAME  := $(GBIT_FNAME)
#MBIT_FNAME  := ~/alivu13p/02_pcie_ddr4x4_streamloop2/alivu13p_top/alivu13p_top.data/alivu13p_top_empty.bit
#MBADDR      := 0x08000000

all: bit


include ../common/processing.mk
