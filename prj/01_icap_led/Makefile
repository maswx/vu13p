

core_jobs  := 8
outputpath :=~/alivu13p/prjs/golden_images
tag        ?= emptytag



#=========================================================================================
# 3个工程一起编译 make -j3
.PHONY:  all  example1_led_top example2_bram_top example3_xvc_top golden_image_top
all: example1_led_top example2_bram_top example3_xvc_top golden_image_top



example1_led_top:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl        -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl         -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl          -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit_nogold.tcl -tclargs $@ ${outputpath}_$@ ${tag}


example2_bram_top:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl        -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl         -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl          -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit_nogold.tcl -tclargs $@ ${outputpath}_$@ ${tag}

example3_xvc_top:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl        -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl         -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl          -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit_nogold.tcl -tclargs $@ ${outputpath}_$@ ${tag}


golden_image_top:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl -tclargs $@ ${outputpath}_$@ 
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl  -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl   -tclargs $@ ${outputpath}_$@ ${core_jobs}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit.tcl -tclargs $@ ${outputpath}_$@ ${tag}



#=========================================================================================

