#!/bin/bash
# -*- coding: utf-8 -*-
#========================================================================
#        author   : masw
#        email    : masw@masw.tech     
#        creattime: 2023年11月03日 星期五 19时53分25秒
#========================================================================
if [ "$#" -ne 1 ]; then
    echo "警告：强烈要求提供一个外部输入参数 'tag' 用于说明本次编译的目的, 编译次数多了之后会忘"
    echo "例如："
    echo "./runme.sh  test_mcap_led"
	tag=empty
else
	tag=$1

fi



fpga_top_name=mcap_led_top
output_path=~/alivu13p/prjs/$fpga_top_name
echo $output_path
core_jobs=20



# 以下语句可以单独执行
vivado -nojournal -nolog -mode batch -source ./tcl/prj_create.tcl -tclargs  $fpga_top_name $output_path 
vivado -nojournal -nolog -mode batch -source ./tcl/prj_synth.tcl  -tclargs $fpga_top_name $output_path $core_jobs
vivado -nojournal -nolog -mode batch -source ./tcl/prj_impl.tcl   -tclargs $fpga_top_name $output_path $core_jobs
vivado -nojournal -nolog -mode batch -source ./tcl/prj_genbit.tcl -tclargs $fpga_top_name $output_path $tag
