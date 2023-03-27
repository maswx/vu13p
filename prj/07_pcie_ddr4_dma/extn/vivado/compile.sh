DATE=$(date +%m%d_%H%M)
GIT_REVISION=$(git show -s --pretty=fornat:%h --abbrev=8)
git_hone_path=$(git rev-parse --show-toplevel)
log=logs
outdir=output
top_module=extn_top

increme=off


vivado -journal ${log}/project_${DATE}_jou \
	   -log ${log}/project_${DATE}_log \
	   -mode batch -source ./prj.tcl \
	   -tclargs ./tcl/src.tcl   \
                ./tcl/xdc.tcl   \
	            ${outdir}_${DATE} \
                ${top_module}       \
                ${increme}



