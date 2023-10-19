

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

IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_B11_inst (.I(bank233_B11_clk_p), .IB(bank233_B10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank233_B11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_D11_inst (.I(bank233_D11_clk_p), .IB(bank233_D10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank233_D11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_F11_inst (.I(bank232_F11_clk_p), .IB(bank232_F10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank232_F11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_H11_inst (.I(bank232_H11_clk_p), .IB(bank232_H10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank232_H11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_K11_inst (.I(bank231_K11_clk_p), .IB(bank231_K10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank231_K11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_M11_inst (.I(bank231_M11_clk_p), .IB(bank231_M10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank231_M11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_P11_inst (.I(bank230_P11_clk_p), .IB(bank230_P10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank230_P11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_T11_inst (.I(bank230_T11_clk_p), .IB(bank230_T10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank230_T11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_V11_inst (.I(bank229_V11_clk_p), .IB(bank229_V10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank229_V11_clk));
IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b01)) IBUFDS_GTE4_Y11_inst (.I(bank229_Y11_clk_p), .IB(bank229_Y10_clk_n), .ODIV2(ODIV2), .CEB(CEB), .O(bank229_Y11_clk));


wire bank233_B11_clk_div8; 
wire bank233_D11_clk_div8;
wire bank232_F11_clk_div8;
wire bank232_H11_clk_div8;
wire bank231_K11_clk_div8;
wire bank231_M11_clk_div8;
wire bank230_P11_clk_div8;
wire bank230_T11_clk_div8;
wire bank229_V11_clk_div8;
wire bank229_Y11_clk_div8;
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_B11_8_inst (.I(bank233_B11_clk), .CE(1'b1), .CLR(1'b0), .O(bank233_B11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_D11_8_inst (.I(bank233_D11_clk), .CE(1'b1), .CLR(1'b0), .O(bank233_D11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_F11_8_inst (.I(bank232_F11_clk), .CE(1'b1), .CLR(1'b0), .O(bank232_F11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_H11_8_inst (.I(bank232_H11_clk), .CE(1'b1), .CLR(1'b0), .O(bank232_H11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_K11_8_inst (.I(bank231_K11_clk), .CE(1'b1), .CLR(1'b0), .O(bank231_K11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_M11_8_inst (.I(bank231_M11_clk), .CE(1'b1), .CLR(1'b0), .O(bank231_M11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_P11_8_inst (.I(bank230_P11_clk), .CE(1'b1), .CLR(1'b0), .O(bank230_P11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_T11_8_inst (.I(bank230_T11_clk), .CE(1'b1), .CLR(1'b0), .O(bank230_T11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_V11_8_inst (.I(bank229_V11_clk), .CE(1'b1), .CLR(1'b0), .O(bank229_V11_clk_div8));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_Y11_8_inst (.I(bank229_Y11_clk), .CE(1'b1), .CLR(1'b0), .O(bank229_Y11_clk_div8));

wire bank233_B11_clk_div64; 
wire bank233_D11_clk_div64;
wire bank232_F11_clk_div64;
wire bank232_H11_clk_div64;
wire bank231_K11_clk_div64;
wire bank231_M11_clk_div64;
wire bank230_P11_clk_div64;
wire bank230_T11_clk_div64;
wire bank229_V11_clk_div64;
wire bank229_Y11_clk_div64;
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_B11_64_inst (.I(bank233_B11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank233_B11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_D11_64_inst (.I(bank233_D11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank233_D11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_F11_64_inst (.I(bank232_F11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank232_F11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_H11_64_inst (.I(bank232_H11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank232_H11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_K11_64_inst (.I(bank231_K11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank231_K11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_M11_64_inst (.I(bank231_M11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank231_M11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_P11_64_inst (.I(bank230_P11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank230_P11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_T11_64_inst (.I(bank230_T11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank230_T11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_V11_64_inst (.I(bank229_V11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank229_V11_clk_div64));
BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) BUFGCE_DIV_Y11_64_inst (.I(bank229_Y11_clk_div8), .CE(1'b1), .CLR(1'b0), .O(bank229_Y11_clk_div64));


wire bank233_B11_clk_div256; 
wire bank233_D11_clk_div256;
wire bank232_F11_clk_div256;
wire bank232_H11_clk_div256;
wire bank231_K11_clk_div256;
wire bank231_M11_clk_div256;
wire bank230_P11_clk_div256;
wire bank230_T11_clk_div256;
wire bank229_V11_clk_div256;
wire bank229_Y11_clk_div256;
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_B11_256_inst (.I(bank233_B11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank233_B11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_D11_256_inst (.I(bank233_D11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank233_D11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_F11_256_inst (.I(bank232_F11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank232_F11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_H11_256_inst (.I(bank232_H11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank232_H11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_K11_256_inst (.I(bank231_K11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank231_K11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_M11_256_inst (.I(bank231_M11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank231_M11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_P11_256_inst (.I(bank230_P11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank230_P11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_T11_256_inst (.I(bank230_T11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank230_T11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_V11_256_inst (.I(bank229_V11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank229_V11_clk_div256));
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) BUFGCE_DIV_Y11_256_inst (.I(bank229_Y11_clk_div64), .CE(1'b1), .CLR(1'b0), .O(bank229_Y11_clk_div256));

wire [9:0] clkx = {
bank233_B11_clk_div256, 
bank233_D11_clk_div256,
bank232_F11_clk_div256,
bank232_H11_clk_div256,
bank231_K11_clk_div256,
bank231_M11_clk_div256,
bank230_P11_clk_div256,
bank230_T11_clk_div256,
bank229_V11_clk_div256,
bank229_Y11_clk_div256 
};
assign led = | clkx;
ila_clk_test(
	.clk(ref_clk_100M),
	.probe0(clkx)
);




endmodule 



