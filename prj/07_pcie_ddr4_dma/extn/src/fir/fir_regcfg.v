//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 04:40:25 PM CST
//========================================================================
module fir_regcfg
(
    input wire                        clk,
    input wire                        rst,

    // Wishbone interface
    input  wire [ 8-1:0]         wb_adr   ,   // ADR_O() address
    output wire [16-1:0]         wb_rd_dat,   // DAT_I() data in
    input  wire [16-1:0]         wb_wr_dat,   // DAT_O() data out
    input  wire                  wb_we    ,   // 写使能信号，代表主设备对从设备当前进行的操作，1为写，0为读
    input  wire [ 2-1:0]         wb_sel   ,   // SEL_O() select output,数据总线选择信号，也是字节选择信号，以Byte为单位，SEL(4’b 1001)代表最高和最低字节有效
    input  wire                  wb_stb   ,   // STB_O strobe output,选通信号，选通信号有效代表主设备发起一次总线操作
    output wire                  wb_ack   ,   // ACK_I acknowledge input 主从设备间的操作成功结束信号
    output wire                  wb_err   ,   // ERR_I error input
    input  wire                  wb_cyc   ,   // CYC_O cycle output

	output reg   [15:0]          coeff_00,
	output reg   [15:0]          coeff_01,
	output reg   [15:0]          coeff_02,
	output reg   [15:0]          coeff_03,
	output reg   [15:0]          coeff_04,
	output reg   [15:0]          coeff_05,
	output reg   [15:0]          coeff_06,
	output reg   [15:0]          coeff_07,
	output reg   [15:0]          coeff_08,
	output reg   [15:0]          coeff_09,
	output reg   [15:0]          coeff_10,
	output reg   [15:0]          coeff_11,
	output reg   [15:0]          coeff_12,
	output reg   [15:0]          coeff_13,
	output reg   [15:0]          coeff_14,
	output reg   [15:0]          coeff_15,
	output reg   [15:0]          coeff_16,
	output reg   [15:0]          coeff_17,
	output reg   [15:0]          coeff_18,
	output reg   [15:0]          coeff_19,
	output reg   [15:0]          coeff_20,
	output reg   [15:0]          coeff_21,
	output reg   [15:0]          coeff_22,
	output reg   [15:0]          coeff_23,
	output reg   [15:0]          coeff_24,
	output reg   [15:0]          coeff_25,
	output reg   [15:0]          coeff_26,
	output reg   [15:0]          coeff_27,
	output reg   [15:0]          coeff_28,
	output reg   [15:0]          coeff_29,
	output reg   [15:0]          coeff_30,
	output reg   [15:0]          coeff_31,
	output reg   [15:0]          coeff_32,
	output reg   [15:0]          testvec_sel
);

always @(posedge clk or posedge rst) 
if(rst)
	begin
	coeff_00 <= 16'd0; 
	coeff_01 <= 16'd0;
	coeff_02 <= 16'd0;
	coeff_03 <= 16'd0;
	coeff_04 <= 16'd0;
	coeff_05 <= 16'd0;
	coeff_06 <= 16'd0;
	coeff_07 <= 16'd0;
	coeff_08 <= 16'd0;
	coeff_09 <= 16'd0;
	coeff_10 <= 16'd0;
	coeff_11 <= 16'd0;
	coeff_12 <= 16'd0;
	coeff_13 <= 16'd0;
	coeff_14 <= 16'd0;
	coeff_15 <= 16'd0;
	coeff_16 <= 16'hffff;
	coeff_17 <= 16'd0;
	coeff_18 <= 16'd0;
	coeff_19 <= 16'd0;
	coeff_20 <= 16'd0;
	coeff_21 <= 16'd0;
	coeff_22 <= 16'd0;
	coeff_23 <= 16'd0;
	coeff_24 <= 16'd0;
	coeff_25 <= 16'd0;
	coeff_26 <= 16'd0;
	coeff_27 <= 16'd0;
	coeff_28 <= 16'd0;
	coeff_29 <= 16'd0;
	coeff_30 <= 16'd0;
	coeff_31 <= 16'd0;
	coeff_32 <= 16'd0;
	testvec_sel <= 16'd0;
	end
else if(wb_we && wb_stb && wb_cyc && wb_adr[7:6] == 2'b00)
	begin
	if(wb_sel[0])
		case(wb_adr[5:0])
			6'h00  : coeff_00[7:0] <= wb_wr_dat[7:0]; 
			6'h01  : coeff_01[7:0] <= wb_wr_dat[7:0];
			6'h02  : coeff_02[7:0] <= wb_wr_dat[7:0];
			6'h03  : coeff_03[7:0] <= wb_wr_dat[7:0];
			6'h04  : coeff_04[7:0] <= wb_wr_dat[7:0];
			6'h05  : coeff_05[7:0] <= wb_wr_dat[7:0];
			6'h05  : coeff_06[7:0] <= wb_wr_dat[7:0];
			6'h07  : coeff_07[7:0] <= wb_wr_dat[7:0];
			6'h08  : coeff_08[7:0] <= wb_wr_dat[7:0];
			6'h09  : coeff_09[7:0] <= wb_wr_dat[7:0];
			6'h0a  : coeff_10[7:0] <= wb_wr_dat[7:0];
			6'h0b  : coeff_11[7:0] <= wb_wr_dat[7:0];
			6'h0c  : coeff_12[7:0] <= wb_wr_dat[7:0];
			6'h0d  : coeff_13[7:0] <= wb_wr_dat[7:0];
			6'h0e  : coeff_14[7:0] <= wb_wr_dat[7:0];
			6'h0f  : coeff_15[7:0] <= wb_wr_dat[7:0];
			6'h10  : coeff_16[7:0] <= wb_wr_dat[7:0];
			6'h11  : coeff_17[7:0] <= wb_wr_dat[7:0];
			6'h12  : coeff_18[7:0] <= wb_wr_dat[7:0];
			6'h13  : coeff_19[7:0] <= wb_wr_dat[7:0];
			6'h14  : coeff_20[7:0] <= wb_wr_dat[7:0];
			6'h15  : coeff_21[7:0] <= wb_wr_dat[7:0];
			6'h15  : coeff_22[7:0] <= wb_wr_dat[7:0];
			6'h17  : coeff_23[7:0] <= wb_wr_dat[7:0];
			6'h18  : coeff_24[7:0] <= wb_wr_dat[7:0];
			6'h19  : coeff_25[7:0] <= wb_wr_dat[7:0];
			6'h1a  : coeff_26[7:0] <= wb_wr_dat[7:0];
			6'h1b  : coeff_27[7:0] <= wb_wr_dat[7:0];
			6'h1c  : coeff_28[7:0] <= wb_wr_dat[7:0];
			6'h1d  : coeff_29[7:0] <= wb_wr_dat[7:0];
			6'h1e  : coeff_30[7:0] <= wb_wr_dat[7:0];
			6'h1f  : coeff_31[7:0] <= wb_wr_dat[7:0];
			6'h20  : coeff_32[7:0] <= wb_wr_dat[7:0];
			6'd30  : testvec_sel[7:0]   <= wb_wr_dat[7:0];
			default:;
		endcase
	if(wb_sel[1])
		case(wb_adr[5:0])
			6'h00  : coeff_00[15:8] <= wb_wr_dat[15:8]; 
			6'h01  : coeff_01[15:8] <= wb_wr_dat[15:8];
			6'h02  : coeff_02[15:8] <= wb_wr_dat[15:8];
			6'h03  : coeff_03[15:8] <= wb_wr_dat[15:8];
			6'h04  : coeff_04[15:8] <= wb_wr_dat[15:8];
			6'h05  : coeff_05[15:8] <= wb_wr_dat[15:8];
			6'h05  : coeff_06[15:8] <= wb_wr_dat[15:8];
			6'h07  : coeff_07[15:8] <= wb_wr_dat[15:8];
			6'h08  : coeff_08[15:8] <= wb_wr_dat[15:8];
			6'h09  : coeff_09[15:8] <= wb_wr_dat[15:8];
			6'h0a  : coeff_10[15:8] <= wb_wr_dat[15:8];
			6'h0b  : coeff_11[15:8] <= wb_wr_dat[15:8];
			6'h0c  : coeff_12[15:8] <= wb_wr_dat[15:8];
			6'h0d  : coeff_13[15:8] <= wb_wr_dat[15:8];
			6'h0e  : coeff_14[15:8] <= wb_wr_dat[15:8];
			6'h0f  : coeff_15[15:8] <= wb_wr_dat[15:8];
			6'h10  : coeff_16[15:8] <= wb_wr_dat[15:8];
			6'h11  : coeff_17[15:8] <= wb_wr_dat[15:8];
			6'h12  : coeff_18[15:8] <= wb_wr_dat[15:8];
			6'h13  : coeff_19[15:8] <= wb_wr_dat[15:8];
			6'h14  : coeff_20[15:8] <= wb_wr_dat[15:8];
			6'h15  : coeff_21[15:8] <= wb_wr_dat[15:8];
			6'h15  : coeff_22[15:8] <= wb_wr_dat[15:8];
			6'h17  : coeff_23[15:8] <= wb_wr_dat[15:8];
			6'h18  : coeff_24[15:8] <= wb_wr_dat[15:8];
			6'h19  : coeff_25[15:8] <= wb_wr_dat[15:8];
			6'h1a  : coeff_26[15:8] <= wb_wr_dat[15:8];
			6'h1b  : coeff_27[15:8] <= wb_wr_dat[15:8];
			6'h1c  : coeff_28[15:8] <= wb_wr_dat[15:8];
			6'h1d  : coeff_29[15:8] <= wb_wr_dat[15:8];
			6'h1e  : coeff_30[15:8] <= wb_wr_dat[15:8];
			6'h1f  : coeff_31[15:8] <= wb_wr_dat[15:8];
			6'h20  : coeff_32[15:8] <= wb_wr_dat[15:8];
			6'd30  : testvec_sel[15:8]   <= wb_wr_dat[15:8];
			default:;
		endcase
	end
reg [15:0] readbak_dat;
reg        readbak_ack;
always @(posedge clk or posedge rst) 
if(rst)
	begin
    readbak_dat <= 16'd0;
    readbak_ack <=  1'd0;
	end
else if(wb_we == 1'b0 && wb_stb && wb_cyc && wb_adr[7:6] == 2'b00)
	begin
		case(wb_adr[5:0])
			6'h00  : {readbak_ack, readbak_dat} <= {1'b1, coeff_00[15:0]}; 
			6'h01  : {readbak_ack, readbak_dat} <= {1'b1, coeff_01[15:0]};
			6'h02  : {readbak_ack, readbak_dat} <= {1'b1, coeff_02[15:0]};
			6'h03  : {readbak_ack, readbak_dat} <= {1'b1, coeff_03[15:0]};
			6'h04  : {readbak_ack, readbak_dat} <= {1'b1, coeff_04[15:0]};
			6'h05  : {readbak_ack, readbak_dat} <= {1'b1, coeff_05[15:0]};
			6'h05  : {readbak_ack, readbak_dat} <= {1'b1, coeff_06[15:0]};
			6'h07  : {readbak_ack, readbak_dat} <= {1'b1, coeff_07[15:0]};
			6'h08  : {readbak_ack, readbak_dat} <= {1'b1, coeff_08[15:0]};
			6'h09  : {readbak_ack, readbak_dat} <= {1'b1, coeff_09[15:0]};
			6'h0a  : {readbak_ack, readbak_dat} <= {1'b1, coeff_10[15:0]};
			6'h0b  : {readbak_ack, readbak_dat} <= {1'b1, coeff_11[15:0]};
			6'h0c  : {readbak_ack, readbak_dat} <= {1'b1, coeff_12[15:0]};
			6'h0d  : {readbak_ack, readbak_dat} <= {1'b1, coeff_13[15:0]};
			6'h0e  : {readbak_ack, readbak_dat} <= {1'b1, coeff_14[15:0]};
			6'h0f  : {readbak_ack, readbak_dat} <= {1'b1, coeff_15[15:0]};
			6'h10  : {readbak_ack, readbak_dat} <= {1'b1, coeff_16[15:0]};
			6'h11  : {readbak_ack, readbak_dat} <= {1'b1, coeff_17[15:0]};
			6'h12  : {readbak_ack, readbak_dat} <= {1'b1, coeff_18[15:0]};
			6'h13  : {readbak_ack, readbak_dat} <= {1'b1, coeff_19[15:0]};
			6'h14  : {readbak_ack, readbak_dat} <= {1'b1, coeff_20[15:0]};
			6'h15  : {readbak_ack, readbak_dat} <= {1'b1, coeff_21[15:0]};
			6'h15  : {readbak_ack, readbak_dat} <= {1'b1, coeff_22[15:0]};
			6'h17  : {readbak_ack, readbak_dat} <= {1'b1, coeff_23[15:0]};
			6'h18  : {readbak_ack, readbak_dat} <= {1'b1, coeff_24[15:0]};
			6'h19  : {readbak_ack, readbak_dat} <= {1'b1, coeff_25[15:0]};
			6'h1a  : {readbak_ack, readbak_dat} <= {1'b1, coeff_26[15:0]};
			6'h1b  : {readbak_ack, readbak_dat} <= {1'b1, coeff_27[15:0]};
			6'h1c  : {readbak_ack, readbak_dat} <= {1'b1, coeff_28[15:0]};
			6'h1d  : {readbak_ack, readbak_dat} <= {1'b1, coeff_29[15:0]};
			6'h1e  : {readbak_ack, readbak_dat} <= {1'b1, coeff_30[15:0]};
			6'h1f  : {readbak_ack, readbak_dat} <= {1'b1, coeff_31[15:0]};
			6'h20  : {readbak_ack, readbak_dat} <= {1'b1, coeff_32[15:0]};
			6'd30  : {readbak_ack, readbak_dat} <= {1'b1, testvec_sel[15:0]};
			default: {readbak_ack, readbak_dat} <= 17'd0;
		endcase
	end
else 
	{readbak_ack, readbak_dat} <= 17'd0;


assign wb_rd_dat =  readbak_dat;   // DAT_I() data in
assign wb_ack    =  readbak_ack;   // ACK_I acknowledge input
assign wb_err    =  1'b0;    // ERR_I error input

endmodule
