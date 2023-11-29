
set bitname [lindex $argv 0]
set binname [file rootname $bitname]

puts "${bitname}"

write_cfgmem -format bin -file ${binname}.bin -size 256 -interface SPIx4 -loadbit {up 0x00000000 /home/masw/work_local/alivu13p/prj/01_icap_led/mcap_led_top_20231118_1443_interp.bit}
