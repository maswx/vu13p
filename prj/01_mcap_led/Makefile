

core_jobs  := 8
outputpath :=~/alivu13p/prjs/mcap
tag        ?= emptytag



#=========================================================================================
# 2个工程一起编译 make -j2
.PHONY:  all  example1_app_bram example2_app_led
all:          example1_app_bram example2_app_led



example1_app_bram:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl        -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl         -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl          -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit.tcl        -tclargs $@ ${outputpath}_$@ ${tag}


example2_app_led:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl        -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl         -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl          -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit.tcl        -tclargs $@ ${outputpath}_$@ ${tag}

#=========================================================================================

