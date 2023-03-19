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
    $finish;
end



always # 5 clk = ~clk;

reg [15:0] cnt;

always @ (posedge clk or posedge rst)
if(rst)
	cnt <= 16'd0;
else 
	cnt <= cnt + 16'd1;

always @ (posedge clk or posedge rst)
if(&cnt)
	$finish;

fir_top fir_top_inst(
    .clk        (clk     ),
    .rst        (rst     ),
    .data_in    (cnt     ),
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


