file_to_check=combined_signal.txt

run:
	iverilog -o simv -f tb.f
	./simv
	gtkwave simv.vcd                                                                                                                                      

clean:
	rm simv
	rm simv.vcd

check_src:
	ifeq ($(shell test -e $(file_to_check) && echo -n yes),yes)
	@echo "文件存在: $(file_to_check)"
	else
	@echo "文件不存在: $(file_to_check)"
	endif
