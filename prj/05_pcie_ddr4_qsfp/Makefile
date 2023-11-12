tag=udp_gnuradio
fpga_top_name=data_mover_top
prjcnt=1
output_path=~/alivu13p/prjs/${fpga_top_name}_${prjcnt}
core_jobs=20



rebuild: syn impl genbit

# 以下语句可以单独执行
create_prj:
	echo ${output_path}
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl -tclargs ${fpga_top_name} ${output_path} 

syn:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl  -tclargs ${fpga_top_name} ${output_path} ${core_jobs}

impl:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl   -tclargs ${fpga_top_name} ${output_path} ${core_jobs}

genbit:
	vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit.tcl -tclargs ${fpga_top_name} ${output_path} ${tag}


all:create_prj syn	impl genbit

	
