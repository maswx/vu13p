
bitname=$1

script_dir=$(dirname "$(readlink -f "$0")")


echo "using ${script_dir}/downloadbin.tcl" 
echo "download bitfile : ${bitname}"  
vivado -mode batch -source ${script_dir}/downloadbin.tcl -tclargs ${bitname}



