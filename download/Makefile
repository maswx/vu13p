
bitname=/home/dbg/work/pciex16_ddr4_x4.bit
ltxname=''
binname=''

run:
	vivado -mode batch -source ./downloadbit.tcl -tclargs $(bitname)  $(ltxname)

bin:
	vivado -mode batch -source ./downloadbin.tcl -tclargs $(binname)

bit2bin:
	vivado -mode batch -source ./convert_bit2bin.tcl -tclargs $(bitname)

