# 获取环境变量并返回的函数, 需要判断这个量有没有()，如果没有则报错推出
proc get_env {name} {
    # 增加允许 环境变量为空的情况 
    if {[info exists ::env($name)]} {
		set retx $::env($name)
		regsub {\s+$} $retx "" retx;# 删除变量中的最后几个空格
        return $retx
    } else {
        puts "Error: Environment variable $name not found. VIVADO 要退出了"
        exit 1
    }
}
proc get_abspath {name} {
	set absolutePath [file normalize $name]
	return $absolutePath 
}

proc load_project {} {
    # 从makefile的 export 出来的环境变量中获取参数。需要判断这个量有没有，如果没有则报错推出
    # 需要获取的参数有 outdir top_name part ,注意环境变量统一带 MKENV_ 前缀
    # 使用get_env函数获取环境变量
    set outdir   [get_env MKENV_OUTDIR]
    set top_name [get_env MKENV_TOP_NAME]
    set part     [get_env MKENV_PART]
    set board    [get_env MKENV_BOARD]
	set absolutePath [file normalize $outdir/$top_name/$top_name.xpr]
    if {[file exists $absolutePath]} {
        open_project $absolutePath
    } else {
        create_project -force -part ${part} $top_name $outdir/$top_name 
    }
	set_property source_mgmt_mode None [current_project]
    if {$board ne ""} {
        set_property board_part $board [current_project]
    }
	set project_dir      [file normalize ${outdir}/${top_name}/${top_name}.data]
    if {[file isdirectory ${project_dir}] == 0} {
		file mkdir ${project_dir}
		puts "create file : $absolutePath "
	}
}


# 添加文件到工程， 并更新
proc add_filex {} {
    # 添加文件
    set outdir    [get_env MKENV_OUTDIR]
    set top_name  [get_env MKENV_TOP_NAME]
    set part      [get_env MKENV_PART]
    set board     [get_env MKENV_BOARD]
    set FILES_RTL [get_env MKENV_RTL_FILES]
    set PATHS_RTL [get_env MKENV_RTL_PATHS]
    set FILES_DEF [get_env MKENV_FILES_DEF]
    set FILES_BD  [get_env MKENV_FILES_BD]
    set FILES_TCL [get_env MKENV_FILES_TCL]
    set FILES_XDC [get_env MKENV_FILES_XDC]
    set FILES_SIM [get_env MKENV_FILES_SIM]
    set DEPS_LIB  [get_env MKENV_DEPS_LIB]
    set USE_OOC_SYNTHESIS [get_env MKENV_USE_OOC_SYNTHESIS]
    set USE_INCR_COMP     [get_env MKENV_USE_INCR_COMP]

    # 添加仓库 DEPS_LIB 
    if {$DEPS_LIB ne ""} {
		set liblist {}
		foreach filex $DEPS_LIB {
			set absolutefile [file normalize $filex]
			lappend liblist $absolutefile 
		}
		puts "$liblist"
        set_property ip_repo_paths $liblist [current_fileset]
        update_ip_catalog
    }

	# 遍历每个路径
    if {$PATHS_RTL ne ""} {
		foreach path $PATHS_RTL {
			# 获取路径中的所有 .v, .sv, .vhdl 文件
			set absolutePath [file normalize $path]
			#set rtl_files [glob -nocomplain -directory $absolutePath *.{v,sv,vhdl}]
			#add_files -norecurse -fileset sources_1 $rtl_files
			set rtl_files [glob -nocomplain -directory $absolutePath *.{v}]
			if {$rtl_files ne "" } {read_verilog     $rtl_files}
			set rtl_files [glob -nocomplain -directory $absolutePath *.{sv}]
			if {$rtl_files ne "" } {read_verilog -sv $rtl_files}
			set rtl_files [glob -nocomplain -directory $absolutePath *.{vhdl}]
			if {$rtl_files ne "" } {read_vhdl        $rtl_files}
		}
	}
    # 添加RTL文件
    if {$FILES_RTL ne ""} {
        # 这里需要写一个for循环逐个添加文件， 判断工程中是否已经存在这个文件，如果存在则不添加
		foreach filex $FILES_RTL {
			set absolutefile [file normalize $filex]
        	add_files -norecurse -fileset sources_1 $absolutefile 
		}
    }


    # 添加宏定义文件 FILE_DEF  并指定为globel define verilg header 首先需要判断 DEF 是否为空
    if {$FILES_DEF ne ""} {
		foreach filex $FILES_DEF {
			set absolutefile [file normalize $filex]
			puts "add file $absolutefile "
            add_files -norecurse -fileset sources_1 $absolutefile 
            set_property file_type "Verilog Header" [get_files $absolutefile ]
            set_property is_global_include true     [get_files $absolutefile ]
        }
    }
    # 添加TCL文件
    if {$FILES_TCL ne ""} {
		foreach filex $FILES_TCL {
			set absolutefile [file normalize $filex]
			puts "source FILES_TCL file $absolutefile "
        	source $absolutefile 
		}
    }
    # 添加约束文件
    if {$FILES_XDC ne ""} {
		foreach filex $FILES_XDC {
			set absolutefile [file normalize $filex]
			puts "add FILES_XDC file $absolutefile "
        	read_xdc $absolutefile 
		}
    }
    # 添加BD文件
    set project_bd_dir "$outdir/$top_name/$top_name.srcs/sources_1/bd/system"
    if {$FILES_BD ne ""} {
        # 如果 get_bd_define base 为空，则创建，否则加载
		#set tmp [get_bd_designs base]
        #if {$tmp eq ""} {
        #    create_bd_design -name base
        #}
        source $FILES_BD
        #create_root_design base
        # 保存BD文件 和 校验 
        #save_bd_design
        #validate_bd_design
    }
	#puts "=====================debug 2=============="
    # 添加仿真文件
    if {$FILES_SIM ne ""} {
		foreach filex $FILES_SIM {
			set absolutefile [file normalize $filex]
			puts "add file $absolutefile "
        	add_files -norecurse -fileset sim_1 $absolutefile 
		}
        # 如果 files_sim里 有 tb.v 则设置为仿真的 top
        if {[regexp {tb.v} $FILES_SIM]} {
            set_property top tb [get_fileset sim_1]
        }
    }
	#puts "=====================debug 4=============="
    update_compile_order -fileset sources_1
    set_property top $top_name [current_fileset];# 配置top
    update_compile_order -fileset sources_1
    update_compile_order -fileset constrs_1
    update_compile_order -fileset sim_1
    # 添加BD文件，如果有的话
}
# 

# 创建工作流
# 在创建好工程并且加载了必须的文件之后，分别编写以下几个函数来创建工作流
# 1. 创建lint检查工作流，检查RTL代码的规范性。如果代码结构有问题，则不再继续后续的工作流
# 2. 创建仿真工作流，默认使用Vivado自带的仿真工具进行仿真
# 3. 创建综合工作流，综合工作流需要指定综合的目标设备
# 4. 创建实现工作流，实现工作流需要指定实现的目标设备
# 5. 创建打包工作流，打包工作流需要指定打包的目标设备
# 6. 创建生成bit文件工作流，生成bit文件工作流需要指定生成的目标设备
# 7. 创建生成boot文件工作流，生成boot文件工作流需要指定生成的目标设备

proc lint_flow {} {
    set part       [get_env MKENV_PART]
    set LINT_TOP   [get_env MKENV_LINT_TOP]
    set lint_ofile [get_env MKENV_LINT_OFILE]
	puts "synth_design -lint -mode default -top $LINT_TOP -part $part > $lint_ofile"
	synth_design -lint -mode default -top $LINT_TOP -part $part > $lint_ofile
}

proc export_siml {} {
    set sim_lib_map_path [get_env MKENV_SIM_LIB_MAP_PATH]
    set sim_dir          [get_env MKENV_SIM_DIR]
    set simulator        [get_env MKENV_SIMULATOR]
    set outdir           [get_env MKENV_OUTDIR]
    set top_name         [get_env MKENV_TOP_NAME]
    set ip_user_files_dir ${outdir}/${top_name}.ip_user_files
    export_simulation -lib_map_path ${sim_lib_map_path} \
                        -directory ${sim_dir} \
                        -simulator ${simulator} \
                        -ip_user_files_dir ${ip_user_files_dir} \
                        -ipstatic_source_dir ${ip_user_files_dir}/ipstatic \
                        -force -user_ip_compiled_libs 
}
proc synth_flow {} {
    set USE_OOC_SYNTHESIS [get_env MKENV_USE_OOC_SYNTHESIS]
    set MAX_OOC_JOBS      [get_env MKENV_MAX_OOC_JOBS]
    set outdir           [get_env MKENV_OUTDIR]
    set top_name         [get_env MKENV_TOP_NAME]
	set project_dir      [file normalize ${outdir}/${top_name}/${top_name}.data]
	reset_run   synth_1
    launch_runs -jobs $MAX_OOC_JOBS synth_1
    #launch_runs -jobs 20 synth_1
    wait_on_run synth_1
    open_run synth_1
	 
    report_timing_summary -file ${project_dir}/timing_synth.log
    #生成 dcp文件，用于后续的实现
    write_checkpoint -force ${project_dir}/${top_name}_synth.dcp
}

proc impl_flow {} {
    set USE_OOC_SYNTHESIS [get_env MKENV_USE_OOC_SYNTHESIS]
    set MAX_OOC_JOBS      [get_env MKENV_MAX_OOC_JOBS]
    set outdir           [get_env MKENV_OUTDIR]
    set top_name         [get_env MKENV_TOP_NAME]
	set project_dir      [file normalize ${outdir}/${top_name}/${top_name}.data]

    # 如果有dcp文件，则使用增量编译
    reset_run impl_1
    launch_runs -jobs ${MAX_OOC_JOBS} impl_1 
    wait_on_run impl_1 
    open_run impl_1
    report_timing_summary -warn_on_violation -file ${project_dir}timing_impl.log
    # 生成加上时间戳和当前linux用户名的bit文件，预先set 时间和用户名变量, 时间精准到分钟
    set username  [exec whoami]
    set prjtag    [get_env MKENV_PRJTAG]
    write_bitstream -force ${project_dir}/${top_name}_${prjtag}.bit
    # 判断当前工程是否有内置ila, 如果有则生成ila的ltx文件
    #if {[get_property ILA_INSTANCES [get_runs impl_1]] ne ""} {
    #    write_debug_probes -force ${project_dir}/${top_name}_${username}_${prjtag}.ltx
    #}
    ## 导出xsa硬件平台
    #write_hw_platform -force ${project_dir}/${top_name}_${username}_${prjtag}.xsa
    # 导出 dcp
    write_checkpoint -force ${project_dir}/${top_name}_impl.dcp
}

proc runstep {} {
	launch_runs impl_1 -to_step write_bitstream -jobs 28
}
# runall
proc runall {} {
    load_project
    add_filex
    #export_siml
    synth_flow
    lint_flow
    impl_flow
}
proc openprj {} {
    load_project
	start_gui
}

proc export_lint {} {
    load_project
    add_filex
}

proc export_sim {} {
    load_project
    add_filex
    export_siml
}

proc export_synth {} {
    load_project
    add_filex
    synth_flow
    lint_flow
}

proc export_impl {} {
    load_project
    add_filex
    synth_flow
    lint_flow
    impl_flow
}

proc genmcs {} {
	set targetname [get_env MKENV_TARGET_NAME]
    set flashsize  [get_env MKENV_FLASH_SIZE]
    set goldenbit  [get_env MKENV_GBIT_FNAME]
    set mbootbit   [get_env MKENV_MBIT_FNAME]
	set gbit       [get_abspath ${goldenbit}]
	set mbit       [get_abspath ${mbootbit}]
	write_cfgmem -force -format MCS -size ${flashsize} -interface SPIx4 -loadbit "up 0x00000000 ${gbit} up 0x800000  ${mbit}" ${targetname}
}

proc implonly {} {
    load_project
	impl_flow 
}

set function_name [lindex $argv 0]
# 检查是否传入了两个参数 ?  必须为2个参数, 不能大不能小
if {[llength $argv] > 1} {
	set mode          [lindex $argv 1]
}
# 获取传递的参数

# 调用指定的函数
if {[info commands $function_name] != ""} {
    eval $function_name 
} else {
    puts "Function $function_name not found"
}



