script_dir=$(dirname "$(readlink -f "$0")")


echo "using ${script_dir}/bit2bin.tcl" 

#vivado                   -mode batch -source ${script_dir}/downloadbit.tcl -tclargs ${bitname}
vivado -nojournal -nolog -mode batch -source ${script_dir}/bit2bin.tcl   -tclargs `pwd`/$1
