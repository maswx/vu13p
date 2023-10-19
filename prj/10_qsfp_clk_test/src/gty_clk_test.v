

module gty_clk_test(
	input        ref_clk_100M_p    ,
	input        ref_clk_100M_n    ,
	input        bank233_B11_clk_p ,
	input        bank233_B10_clk_n ,
	input        bank233_D11_clk_p ,
	input        bank233_D10_clk_n ,
	input        bank232_F11_clk_p ,
	input        bank232_F10_clk_n ,
	input        bank232_H11_clk_p ,
	input        bank232_H10_clk_n ,
	input        bank231_K11_clk_p ,
	input        bank231_K10_clk_n ,
	input        bank231_M11_clk_p ,
	input        bank231_M10_clk_n ,
	input        bank230_P11_clk_p ,
	input        bank230_P10_clk_n ,
	input        bank230_T11_clk_p ,
	input        bank230_T10_clk_n ,
	input        bank229_V11_clk_p ,
	input        bank229_V10_clk_n ,
	input        bank229_Y11_clk_p ,
	input        bank229_Y10_clk_n ,
	output [7:0] led                //防止编译优化
);
// 除以2以后大约是80M，再除以8，大约是10M，再除以8，大约是2M，再除以4， 用100M的周期采
// 样，大约可以采到200个点，
//
//
wire ref_clk_100M;
IBUFDS                                     IBUFDS_ref_inst (.I(ref_clk_100M_p), .IB(ref_clk_100M_n),  .O(ref_clk_100M));
//
//
wire bank233_B11_clk; 
wire bank233_D11_clk;
wire bank232_F11_clk;
wire bank232_H11_clk;
wire bank231_K11_clk;
wire bank231_M11_clk;
wire bank230_P11_clk;
wire bank230_T11_clk;
wire bank229_V11_clk;
wire bank229_Y11_clk;

IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_B11_inst (.I(bank233_B11_clk_p), .IB(bank233_B10_clk_n), .ODIV2(bank233_B11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_D11_inst (.I(bank233_D11_clk_p), .IB(bank233_D10_clk_n), .ODIV2(bank233_D11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_F11_inst (.I(bank232_F11_clk_p), .IB(bank232_F10_clk_n), .ODIV2(bank232_F11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_H11_inst (.I(bank232_H11_clk_p), .IB(bank232_H10_clk_n), .ODIV2(bank232_H11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_K11_inst (.I(bank231_K11_clk_p), .IB(bank231_K10_clk_n), .ODIV2(bank231_K11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_M11_inst (.I(bank231_M11_clk_p), .IB(bank231_M10_clk_n), .ODIV2(bank231_M11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_P11_inst (.I(bank230_P11_clk_p), .IB(bank230_P10_clk_n), .ODIV2(bank230_P11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_T11_inst (.I(bank230_T11_clk_p), .IB(bank230_T10_clk_n), .ODIV2(bank230_T11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_V11_inst (.I(bank229_V11_clk_p), .IB(bank229_V10_clk_n), .ODIV2(bank229_V11_clk), .CEB(1'b0), .O());
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_Y11_inst (.I(bank229_Y11_clk_p), .IB(bank229_Y10_clk_n), .ODIV2(bank229_Y11_clk), .CEB(1'b0), .O());

(* keep *)wire bank233_B11_clk_div8; 
(* keep *)wire bank233_D11_clk_div8;
(* keep *)wire bank232_F11_clk_div8;
(* keep *)wire bank232_H11_clk_div8;
(* keep *)wire bank231_K11_clk_div8;
(* keep *)wire bank231_M11_clk_div8;
(* keep *)wire bank230_P11_clk_div8;
(* keep *)wire bank230_T11_clk_div8;
(* keep *)wire bank229_V11_clk_div8;
(* keep *)wire bank229_Y11_clk_div8;
BUFG_GT BUFGCE_DIV_B11_8_inst (.I(bank233_B11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank233_B11_clk_div8));
BUFG_GT BUFGCE_DIV_D11_8_inst (.I(bank233_D11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank233_D11_clk_div8));
BUFG_GT BUFGCE_DIV_F11_8_inst (.I(bank232_F11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank232_F11_clk_div8));
BUFG_GT BUFGCE_DIV_H11_8_inst (.I(bank232_H11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank232_H11_clk_div8));
BUFG_GT BUFGCE_DIV_K11_8_inst (.I(bank231_K11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank231_K11_clk_div8));
BUFG_GT BUFGCE_DIV_M11_8_inst (.I(bank231_M11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank231_M11_clk_div8));
BUFG_GT BUFGCE_DIV_P11_8_inst (.I(bank230_P11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank230_P11_clk_div8));
BUFG_GT BUFGCE_DIV_T11_8_inst (.I(bank230_T11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank230_T11_clk_div8));
BUFG_GT BUFGCE_DIV_V11_8_inst (.I(bank229_V11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank229_V11_clk_div8));
BUFG_GT BUFGCE_DIV_Y11_8_inst (.I(bank229_Y11_clk), .DIV(3'd0), .CLRMASK(1'b0),  .CEMASK(1'b0), .CE(1'b1), .CLR(1'b0), .O(bank229_Y11_clk_div8));

(* keep *)reg [7:0] bank233_B11_reg; 
(* keep *)reg [7:0] bank233_D11_reg;
(* keep *)reg [7:0] bank232_F11_reg;
(* keep *)reg [7:0] bank232_H11_reg;
(* keep *)reg [7:0] bank231_K11_reg;
(* keep *)reg [7:0] bank231_M11_reg;
(* keep *)reg [7:0] bank230_P11_reg;
(* keep *)reg [7:0] bank230_T11_reg;
(* keep *)reg [7:0] bank229_V11_reg;
(* keep *)reg [7:0] bank229_Y11_reg;

always @ (posedge bank233_B11_clk_div8)  bank233_B11_reg <= bank233_B11_reg + 8'd1; 
always @ (posedge bank233_D11_clk_div8)  bank233_D11_reg <= bank233_D11_reg + 8'd1;
always @ (posedge bank232_F11_clk_div8)  bank232_F11_reg <= bank232_F11_reg + 8'd1;
always @ (posedge bank232_H11_clk_div8)  bank232_H11_reg <= bank232_H11_reg + 8'd1;
always @ (posedge bank231_K11_clk_div8)  bank231_K11_reg <= bank231_K11_reg + 8'd1;
always @ (posedge bank231_M11_clk_div8)  bank231_M11_reg <= bank231_M11_reg + 8'd1;
always @ (posedge bank230_P11_clk_div8)  bank230_P11_reg <= bank230_P11_reg + 8'd1;
always @ (posedge bank230_T11_clk_div8)  bank230_T11_reg <= bank230_T11_reg + 8'd1;
always @ (posedge bank229_V11_clk_div8)  bank229_V11_reg <= bank229_V11_reg + 8'd1;
always @ (posedge bank229_Y11_clk_div8)  bank229_Y11_reg <= bank229_Y11_reg + 8'd1;

(* keep *)reg [5:0] text_cnt;
always @ (posedge ref_clk_100M) 
	text_cnt <= text_cnt + 6'd1;


(* keep *)wire [15:0] clkx = {
text_cnt[5:0],
bank233_B11_reg[7],  //2*(638-178)*10ns = 9200ns, 2/(9200/256.0)=55.65217391304348
bank233_D11_reg[7],  //1*(374- 56)*10ns = 3180ns, 2/(3180/256.0)=161.006约为161.132=10.3125/64 ; 10.3125*64/66=10.000
bank232_F11_reg[7],  //这里没有时钟 
bank232_H11_reg[7],  //这里没有时钟
bank231_K11_reg[7],  //这里没有时钟
bank231_M11_reg[7],  //这里没有时钟
bank230_P11_reg[7],  //这里没有时钟
bank230_T11_reg[7],  //这里没有时钟
bank229_V11_reg[7],  //这里没有时钟
bank229_Y11_reg[7]   //这里有时钟，周期为 2*(982-823) * 10ns = 3180ns
};
assign led = | clkx;
ila_clk_test ila_clk_test(
	.clk   (ref_clk_100M),
	.probe0(clkx)
);




endmodule 



