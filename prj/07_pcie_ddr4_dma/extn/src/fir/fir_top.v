//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 04:40:32 PM CST
//========================================================================

module fir_top(
    input         clk        ,
    input         rst        ,
           
    input  [15:0] data_in    ,
    output [15:0] data_out   ,

    input         i2c_scl_i  ,
    output        i2c_scl_o  ,
    output        i2c_scl_t  ,
    input         i2c_sda_i  ,
    output        i2c_sda_o  ,
    output        i2c_sda_t  ,

	output [63:0] testvec  //送到逻辑分析仪的测试矢量
);






wire [ 8-1:0]         wb_adr   ;   // ADR_O() address
wire [16-1:0]         wb_rd_dat;   // DAT_I() data in
wire [16-1:0]         wb_wr_dat;   // DAT_O() data out
wire                  wb_we    ;   // 写使能信号，代表主设备对从设备当前进行的操作，1为写，0为读
wire [ 2-1:0]         wb_sel   ;   // SEL_O() select output,数据总线选择信号，也是字节选择信号，以Byte为单位，SEL(4’b 1001)代表最高和最低字节有效
wire                  wb_stb   ;   // STB_O strobe output,选通信号，选通信号有效代表主设备发起一次总线操作
wire                  wb_ack   ;   // ACK_I acknowledge input 主从设备间的操作成功结束信号
wire                  wb_err   ;   // ERR_I error input
wire                  wb_cyc   ;   // CYC_O cycle output
wire  [15:0]          coeff_00 ;
wire  [15:0]          coeff_01 ;
wire  [15:0]          coeff_02 ;
wire  [15:0]          coeff_03 ;
wire  [15:0]          coeff_04 ;
wire  [15:0]          coeff_05 ;
wire  [15:0]          coeff_06 ;
wire  [15:0]          coeff_07 ;
wire  [15:0]          coeff_08 ;
wire  [15:0]          coeff_09 ;
wire  [15:0]          coeff_10 ;
wire  [15:0]          coeff_11 ;
wire  [15:0]          coeff_12 ;
wire  [15:0]          coeff_13 ;
wire  [15:0]          coeff_14 ;
wire  [15:0]          coeff_15 ;
wire  [15:0]          coeff_16 ;
wire  [15:0]          coeff_17 ;
wire  [15:0]          coeff_18 ;
wire  [15:0]          coeff_19 ;
wire  [15:0]          coeff_20 ;
wire  [15:0]          coeff_21 ;
wire  [15:0]          coeff_22 ;
wire  [15:0]          coeff_23 ;
wire  [15:0]          coeff_24 ;
wire  [15:0]          coeff_25 ;
wire  [15:0]          coeff_26 ;
wire  [15:0]          coeff_27 ;
wire  [15:0]          coeff_28 ;
wire  [15:0]          coeff_29 ;
wire  [15:0]          coeff_30 ;
wire  [15:0]          coeff_31 ;
wire  [15:0]          coeff_32 ;
wire  [15:0]          testvec_sel;
wire  [63:0]          testvec_fir;
wire  [63:0]          testvec_wbx;

fir_core fir_filter_inst(
    .clk      (clk      ), 
    .rst      (rst      ), 
    .data_in  (data_in  ),
	.coeff_00 (coeff_00 ),
	.coeff_01 (coeff_01 ),
	.coeff_02 (coeff_02 ),
	.coeff_03 (coeff_03 ),
	.coeff_04 (coeff_04 ),
	.coeff_05 (coeff_05 ),
	.coeff_06 (coeff_06 ),
	.coeff_07 (coeff_07 ),
	.coeff_08 (coeff_08 ),
	.coeff_09 (coeff_09 ),
	.coeff_10 (coeff_10 ),
	.coeff_11 (coeff_11 ),
	.coeff_12 (coeff_12 ),
	.coeff_13 (coeff_13 ),
	.coeff_14 (coeff_14 ),
	.coeff_15 (coeff_15 ),
	.coeff_16 (coeff_16 ),
	.coeff_17 (coeff_17 ),
	.coeff_18 (coeff_18 ),
	.coeff_19 (coeff_19 ),
	.coeff_20 (coeff_20 ),
	.coeff_21 (coeff_21 ),
	.coeff_22 (coeff_22 ),
	.coeff_23 (coeff_23 ),
	.coeff_24 (coeff_24 ),
	.coeff_25 (coeff_25 ),
	.coeff_26 (coeff_26 ),
	.coeff_27 (coeff_27 ),
	.coeff_28 (coeff_28 ),
	.coeff_29 (coeff_29 ),
	.coeff_30 (coeff_30 ),
	.coeff_31 (coeff_31 ),
	.coeff_32 (coeff_32 ),
    .data_out (data_out ),
	.testvec  (testvec_fir  ) //送到逻辑分析仪的测试矢量
);

fir_regcfg  fir_regcfg_inst (
    .clk         (clk        ),
    .rst         (rst        ),
    .wb_adr      (wb_adr     ),   // ADR_O() address
    .wb_rd_dat   (wb_rd_dat  ),   // DAT_I() data in
    .wb_wr_dat   (wb_wr_dat  ),   // DAT_O() data out
    .wb_we       (wb_we      ),   // 写使能信号，代表主设备对从设备当前进行的操作，1为写，0为读
    .wb_sel      (wb_sel     ),   // SEL_O() select output,数据总线选择信号，也是字节选择信号，以Byte为单位，SEL(4’b 1001)代表最高和最低字节有效
    .wb_stb      (wb_stb     ),   // STB_O strobe output,选通信号，选通信号有效代表主设备发起一次总线操作
    .wb_ack      (wb_ack     ),   // ACK_I acknowledge input 主从设备间的操作成功结束信号
    .wb_err      (wb_err     ),   // ERR_I error input
    .wb_cyc      (wb_cyc     ),   // CYC_O cycle output
	.coeff_00    (coeff_00   ),
	.coeff_01    (coeff_01   ),
	.coeff_02    (coeff_02   ),
	.coeff_03    (coeff_03   ),
	.coeff_04    (coeff_04   ),
	.coeff_05    (coeff_05   ),
	.coeff_06    (coeff_06   ),
	.coeff_07    (coeff_07   ),
	.coeff_08    (coeff_08   ),
	.coeff_09    (coeff_09   ),
	.coeff_10    (coeff_10   ),
	.coeff_11    (coeff_11   ),
	.coeff_12    (coeff_12   ),
	.coeff_13    (coeff_13   ),
	.coeff_14    (coeff_14   ),
	.coeff_15    (coeff_15   ),
	.coeff_16    (coeff_16   ),
	.coeff_17    (coeff_17   ),
	.coeff_18    (coeff_18   ),
	.coeff_19    (coeff_19   ),
	.coeff_20    (coeff_20   ),
	.coeff_21    (coeff_21   ),
	.coeff_22    (coeff_22   ),
	.coeff_23    (coeff_23   ),
	.coeff_24    (coeff_24   ),
	.coeff_25    (coeff_25   ),
	.coeff_26    (coeff_26   ),
	.coeff_27    (coeff_27   ),
	.coeff_28    (coeff_28   ),
	.coeff_29    (coeff_29   ),
	.coeff_30    (coeff_30   ),
	.coeff_31    (coeff_31   ),
	.coeff_32    (coeff_32   ),
	.testvec_sel (testvec_sel)
);

i2c_slave_wbm # (
    .FILTER_LEN    (4 ),
    .WB_DATA_WIDTH (16),                // width of data bus in bits (8, 16, 32, or 64)
    .WB_ADDR_WIDTH ( 8)                 // width of address bus in bits
)i2c_slave_wbm (
    .clk           (clk           ), //input wire                        
    .rst           (rst           ), //input wire                        
    .i2c_scl_i     (i2c_scl_i     ), //input  wire                       
    .i2c_scl_o     (i2c_scl_o     ), //output wire                       
    .i2c_scl_t     (i2c_scl_t     ), //output wire                       
    .i2c_sda_i     (i2c_sda_i     ), //input  wire                       
    .i2c_sda_o     (i2c_sda_o     ), //output wire                       
    .i2c_sda_t     (i2c_sda_t     ), //output wire                       
    // Wishbone interface
    .wb_adr_o      (wb_adr        ), //output wire [WB_ADDR_WIDTH-1:0]    ADR_O() address
    .wb_dat_i      (wb_rd_dat     ), //input  wire [WB_DATA_WIDTH-1:0]    DAT_I() data in
    .wb_dat_o      (wb_wr_dat     ), //output wire [WB_DATA_WIDTH-1:0]    DAT_O() data out
    .wb_we_o       (wb_we         ), //output wire                        WE_O write enable output
    .wb_sel_o      (wb_sel        ), //output wire [WB_SELECT_WIDTH-1:0]  SEL_O() select output
    .wb_stb_o      (wb_stb        ), //output wire                        STB_O strobe output
    .wb_ack_i      (wb_ack        ), //input  wire                        ACK_I acknowledge input
    .wb_err_i      (wb_err        ), //input  wire                        ERR_I error input
    .wb_cyc_o      (wb_cyc        ), //output wire                        CYC_O cycle output
	//---------------------------------
    .busy          (              ),
    .bus_addressed (              ),
    .bus_active    (              ),
    .enable        (1'b1          ),
    .device_address(7'd0          ) 
);


assign testvec_wbx = {
	10'd0             ,
    i2c_scl_i         ,
    i2c_scl_o         ,
    i2c_scl_t         ,
    i2c_sda_i         ,
    i2c_sda_o         ,
    i2c_sda_t         ,
	1'b0              ,
    wb_we             , //output wire                        WE_O write enable output
    wb_stb            , //output wire                        STB_O strobe output
    wb_ack            , //input  wire                        ACK_I acknowledge input
    wb_err            , //input  wire                        ERR_I error input
    wb_cyc            , //output wire                        CYC_O cycle output
    wb_sel     [ 1:0] , //output wire [WB_SELECT_WIDTH-1:0]  SEL_O() select output
    wb_adr     [ 7:0] , //output wire [WB_ADDR_WIDTH-1:0]    ADR_O() address
    wb_rd_dat  [15:0] , //input  wire [WB_DATA_WIDTH-1:0]    DAT_I() data in
    wb_wr_dat  [15:0]   //output wire [WB_DATA_WIDTH-1:0]    DAT_O() data out
};


assign testvec   = testvec_sel == 16'd0 ? testvec_fir : testvec_wbx;

endmodule
