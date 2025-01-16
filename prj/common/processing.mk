PRJTCL ?= ./tcl/processing.tcl

PART     ?= xcvu13p-fhgb2104-2L-e
OUTDIR                     ?= ./output
USE_OOC_SYNTHESIS          ?= 0
USE_INCR_COMP              ?= 1
LINT_TOP                   ?= $(TOP_NAME)
SIM_DIR                    ?= ./sim
SIMULATOR                  ?= xsim
MAX_OOC_JOBS               ?= 16
NO_BITSTREAM_COMPRESSION   ?= 1
POWER_OPTIMIZATION         ?= 0
PRJTAG                     ?= notag


HWTARGET    ?= xcvu13p_0
TARGET_NAME ?= alivu13p
FLASH_SIZE  ?= 256
MBADDR      ?= 0x800000

export MKENV_OUTDIR                   = $(OUTDIR) 
export MKENV_TOP_NAME                 = $(TOP_NAME) 
export MKENV_PART                     = $(PART) 
export MKENV_BOARD                    = $(BOARD) 
export MKENV_RTL_FILES                = $(RTL_FILES) 
export MKENV_RTL_PATHS                = $(RTL_PATHS) 
export MKENV_FILES_DEF                = $(DEPS_DEFINE) 
export MKENV_FILES_BD                 = $(DEPS_BD) 
export MKENV_FILES_TCL                = $(DEPS_TCL) 
export MKENV_FILES_XDC                = $(DEPS_XDC) 
export MKENV_FILES_SIM                = $(DEPS_SIM) 
export MKENV_DEPS_LIB                 = $(DEPS_LIB) 
export MKENV_USE_OOC_SYNTHESIS        = $(USE_OOC_SYNTHESIS) 
export MKENV_USE_INCR_COMP            = $(USE_INCR_COMP) 
export MKENV_LINT_TOP                 = $(LINT_TOP) 
export MKENV_LINT_OFILE               = $(LINT_TOP)_CHECK_ME.txt
export MKENV_SIM_LIB_MAP_PATH         = $(SIM_LIB_MAP_PATH) 
export MKENV_SIM_DIR                  = $(SIM_DIR) 
export MKENV_SIMULATOR                = $(SIMULATOR) 
export MKENV_MAX_OOC_JOBS             = $(MAX_OOC_JOBS) 
export MKENV_NO_BITSTREAM_COMPRESSION = $(NO_BITSTREAM_COMPRESSION) 
export MKENV_POWER_OPTIMIZATION       = $(POWER_OPTIMIZATION) 
export MKENV_PRJTAG                   = $(PRJTAG)

export MKENV_HWTARGET                 = $(HWTARGET)
export MKENV_TARGET_NAME              = $(TARGET_NAME)
export MKENV_FLASH_SIZE               = $(FLASH_SIZE)
export MKENV_GBIT_FNAME               = $(GBIT_FNAME)
export MKENV_MBIT_FNAME               = $(MBIT_FNAME)
export MKENV_MBADDR                   = $(MBADDR)



# 6. 定义仅仅导出bit文件
bit:
	$(VIVADO) -nojournal -nolog -mode batch -source $(PRJTCL) -notrace -tclargs runall &

vivado: gui

gui:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs openprj &

# 2. 导出lint报告
lint:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs export_lint

# 3. 定义仅仅导出仿真平台
sim:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs export_sim 

implonly:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs implonly

genmcs:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs genmcs

multibootbin:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs multibootbin

genbitonly:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs genbitonly

downloadbit:
	$(VIVADO) -nojournal -nolog  -mode batch -source $(PRJTCL) -notrace -tclargs $@ $(GBIT_FNAME)
