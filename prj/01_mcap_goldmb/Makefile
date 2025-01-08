VIVADO   := /nasopt/Xilinx/Vivado/2024.1/bin/vivado
TOP_NAME := example1_app_bram
OUTDIR   := ~/alivu13p/new2025_1x

TARGET_NAME:=alivu13p_imcap_goldenmb.mcs
FLASH_SIZE :=256
GBIT_FNAME := ~/alivu13p/new2025_golden/$(TOP_NAME).data/$(TOP_NAME)_golden_tandem1.bit
MBIT_FNAME := ~/alivu13p/new2025_multiboot/$(TOP_NAME).data/$(TOP_NAME)_muboot_tandem1.bit

$(TARGET_NAME): $(GBIT_FNAME) $(MBIT_FNAME)
	make genmcs	


$(GBIT_FNAME):
	make -C . -f Makefile_gbit VIVADO=$(VIVADO) bit

$(MBIT_FNAME):
	make -C . -f Makefile_mbit VIVADO=$(VIVADO) bit





include ./tcl/processing.mk
