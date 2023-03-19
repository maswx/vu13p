//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 08:17:47 PM CST
//========================================================================
module tb();
reg clk;
reg rst;
initial begin
	clk = 1'b1;
	rst = 1'b1;
	# 1000 
	rst = 0;
end
initial begin
    $dumpfile("simv.vcd");
    $dumpvars(0, tb.fir_top_inst);
end
always # 5 clk = ~clk;

//==================================================
reg [15:0] progress_counter = 0;
reg [15:0] total_time = 30000;
//always @(posedge clk) begin
//    progress_counter = progress_counter + 1;
//    if (progress_counter <= total_time) begin
//        if (progress_counter % (total_time / 100) == 0) begin
//            $display("仿真进度: %d%% (%d / %d)", (progress_counter * 100) / total_time, progress_counter, total_time);
//        end
//    end else begin
//        // 完成进度条，终止仿真
//        $display("仿真进度: 100%% (%d / %d)", total_time, total_time);
//        $finish;
//    end
//end
integer i;
always @(posedge clk) begin
    progress_counter = progress_counter + 1;

    if (progress_counter <= total_time) begin
        if (progress_counter % (total_time / 100) == 0) begin
            // 打印进度条
            //$write("\033[2J\033[H");
            $write("仿真进度 |");
            for (i = 0; i < (progress_counter * 100) / total_time; i = i + 1) begin
                $write("#");
            end
            for (i=(progress_counter * 100) / total_time; i < 100; i = i + 1) begin
                $write(" ");
            end
            $write("| %d%% (%d / %d)\n", (progress_counter * 100) / total_time, progress_counter, total_time);
        end
    end else begin
        // 完成进度条，终止仿真
        $display("\r|##################################################| 100%% (%d / %d)", total_time, total_time);
        $finish;
    end
end


//==================================================












reg signed[15:0] signal_data;
integer file_pointer;
initial begin
    // 打开文件
    file_pointer = $fopen("combined_signal.txt", "r");
    // 检查文件是否打开成功
    if (file_pointer == 0) begin
        $display("Error: Unable to open the file.combined_signal.txt, run gensource.py first!\n");
        $finish;
    end 
end

always @(posedge clk) begin
    // 如果文件尚未结束且读取状态正常，则读取数据
    if (!$feof(file_pointer) ) begin
        //$fscanf(file_pointer, "%d\n", signal_data);
        if ($fscanf(file_pointer, "%d\n", signal_data) == 1) begin
            //$display("Read signal data at posedge clk: %d", signal_data);
        end
    end
end















fir_top fir_top_inst(
    .clk        (clk     ),
    .rst        (rst     ),
    .data_in    (signal_data),
    .data_out   (        ),
    .i2c_scl_i  (1'b0    ),
    .i2c_scl_o  (        ),
    .i2c_scl_t  (        ),
    .i2c_sda_i  (1'b0    ),
    .i2c_sda_o  (        ),
    .i2c_sda_t  (        ),
	.testvec    (        )
);

endmodule


