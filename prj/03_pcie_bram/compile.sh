



mkdir log 

ln -sf log/project_${DATE}_log log

vivado -journal ${log}/project_${DATE}_jou \
       -log     ${log}/project_${DATE}_log \
       -mode    batch              \
       -source  ./compile.tcl \
	   -tclargs ./project.tcl 

#	   ./compile.tcl      \
#       -tclargs ./tcl/src.tcl      \
#                ./tcl/ips.tcl      \
#                ./tcl/xdc.tcl      \
#                ./dcp/xdc.tcl      \

