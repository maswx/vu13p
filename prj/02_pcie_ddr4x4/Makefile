fpga_top_name=xdma_ddr4x4_top 
output_path=~/alivu13p/prjs/${fpga_top_name}
core_jobs=8

bit:
	vivado -mode batch -source ./tcl/createprj.tcl -tclargs ${fpga_top_name} ${output_path} 
	vivado -mode batch -source ./tcl/run.tcl       -tclargs ${fpga_top_name} ${output_path}  ${core_jobs}



run:
	#sed -i '/^create_project/s/.*/create_project $$\{_xil_proj_name_\} . -part xcvu13p-fhgb2104-2-i /' project.tcl
	rm project.tcl
	git co project.tcl
	sed -i '/^create_project/s/$$/ -force/' project.tcl
	vivado -mode batch -source compile.tcl
