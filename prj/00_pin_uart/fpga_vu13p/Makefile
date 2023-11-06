
# FPGA settings
FPGA_PART = xcvu13p-fhgb2104-2L-e
FPGA_TOP = fpga
FPGA_ARCH = vertexuplus

# Files for synthesis
SYN_FILES = ./fpga.v
SYN_FILES += rtl/pin_uart.v

# XDC files
XDC_FILES = ./fpga.xdc

# IP
#IP_TCL_FILES = 

# Configuration
CONFIG_TCL_FILES = ./config.tcl
CONFIG_TCL_FILES += generate.tcl

include ../common/vivado.mk

fpga.v fpga.xdc:
	touch $@

clean::
	-rm -rf fpga.v fpga.xdc

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl

