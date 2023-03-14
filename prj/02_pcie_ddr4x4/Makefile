
run:
	#sed -i '/^create_project/s/.*/create_project $$\{_xil_proj_name_\} . -part xcvu13p-fhgb2104-2-i /' project.tcl
	rm project.tcl
	git co project.tcl
	sed -i '/^create_project/s/$$/ -force/' project.tcl
	vivado -mode batch -source compile.tcl
