
bitname=$1

script_dir=$(dirname "$(readlink -f "$0")")


echo "using ${script_dir}/downloadbit.tcl" 
echo "download bitfile : ${bitname}"  
vivado -mode batch -source ${script_dir}/downloadbit.tcl -tclargs ${bitname}



