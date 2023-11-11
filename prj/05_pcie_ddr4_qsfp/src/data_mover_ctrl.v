//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月11日 星期六 22时55分33秒
//========================================================================


/*
思路：
	1. 小包传输，一次传输 1024个byte
  
*/

module data_mover_ctrl (
    input              axi_aclk                      ,
    input              axi_aresetn                   ,
	input  wire  [ 7:0]S_AXIS_MM2S_STS_tdata         ,
	input  wire  [ 0:0]S_AXIS_MM2S_STS_tkeep         ,
	input  wire        S_AXIS_MM2S_STS_tlast         ,
	output wire        S_AXIS_MM2S_STS_tready        ,
	input  wire        S_AXIS_MM2S_STS_tvalid        ,
	input  wire  [ 7:0]S_AXIS_S2MM_STS_tdata         ,
	input  wire  [ 0:0]S_AXIS_S2MM_STS_tkeep         ,
	input  wire        S_AXIS_S2MM_STS_tlast         ,
	output wire        S_AXIS_S2MM_STS_tready        ,
	input  wire        S_AXIS_S2MM_STS_tvalid        ,
	output wire  [71:0]M_AXIS_MM2S_CMD_tdata         ,
	input  wire        M_AXIS_MM2S_CMD_tready        ,
	output wire        M_AXIS_MM2S_CMD_tvalid        ,
	output wire  [71:0]M_AXIS_S2MM_CMD_tdata         ,
	input  wire        M_AXIS_S2MM_CMD_tready        ,
	output wire        M_AXIS_S2MM_CMD_tvalid        ,
	input  wire  [31:0]S_AXI_LITE_awaddr             , //wire [ADDR_WIDTH-1:0]    s00_axil_awaddr,
	input  wire  [ 2:0]S_AXI_LITE_awprot             , //wire [2:0]               s00_axil_awprot,
	input  wire        S_AXI_LITE_awvalid            , //wire                     s00_axil_awvalid,
	output wire        S_AXI_LITE_awready            , //wire                     s00_axil_awready,
	input  wire  [31:0]S_AXI_LITE_wdata              , //wire [DATA_WIDTH-1:0]    s00_axil_wdata,
	input  wire  [ 3:0]S_AXI_LITE_wstrb              , //wire [STRB_WIDTH-1:0]    s00_axil_wstrb,
	input  wire        S_AXI_LITE_wvalid             , //wire                     s00_axil_wvalid,
	output wire        S_AXI_LITE_wready             , //wire                     s00_axil_wready,
	output wire  [ 1:0]S_AXI_LITE_bresp              , //wire [1:0]               s00_axil_bresp,
	output wire        S_AXI_LITE_bvalid             , //wire                     s00_axil_bvalid,
	input  wire        S_AXI_LITE_bready             , //wire                     s00_axil_bready,
	input  wire  [31:0]S_AXI_LITE_araddr             , //wire [ADDR_WIDTH-1:0]    s00_axil_araddr,
	input  wire  [ 2:0]S_AXI_LITE_arprot             , //wire [2:0]               s00_axil_arprot,
	input  wire        S_AXI_LITE_arvalid            , //wire                     s00_axil_arvalid,
	output wire        S_AXI_LITE_arready            , //wire                     s00_axil_arready,
	output wire  [31:0]S_AXI_LITE_rdata              , //wire [DATA_WIDTH-1:0]    s00_axil_rdata,
	output wire  [ 1:0]S_AXI_LITE_rresp              , //wire [1:0]               s00_axil_rresp,
	output wire        S_AXI_LITE_rvalid             , //wire                     s00_axil_rvalid,
	input  wire        S_AXI_LITE_rready               //wire                     s00_axil_rready,
);

assign S_AXIS_MM2S_STS_tready = 1'b1; 
assign S_AXIS_S2MM_STS_tready = 1'b1; 


reg  [71:0]MM2S_CMD_tdata      ;
reg        MM2S_CMD_tvalid     ;
reg  [71:0]S2MM_CMD_tdata      ;
reg        S2MM_CMD_tvalid     ;

assign M_AXIS_MM2S_CMD_tdata   = MM2S_CMD_tdata    ;
assign M_AXIS_MM2S_CMD_tready  = MM2S_CMD_tvalid   ;
assign M_AXIS_S2MM_CMD_tdata   = S2MM_CMD_tdata    ;
assign M_AXIS_S2MM_CMD_tvalid  = S2MM_CMD_tvalid   ;

reg [31:0]mm2s_saddr;
reg       mm2s_eof  ;
reg       mm2s_incr ;
reg [22:0]mm2s_lenx ;

reg [31:0]s2mm_saddr;
reg       s2mm_eof  ;
reg       s2mm_incr ;
reg [22:0]s2mm_lenx ;
wire [71:0] MM2S_CMD = {
	4'd0        ,//没啥用
	4'd0        ,//TAG, 最终会流传到STS上，不用
	mm2s_saddr  ,//SADDR, 起始地址
	1'b0        ,//DRE重新对齐请求。	
	mm2s_eof    ,//EOF标志, 永不停歇
	6'd0        ,//DRE 流对齐
	mm2s_incr   ,//传完后不做地址递增
	mm2s_lenx    //一次传输65536个byte
};

wire [71:0] S2MM_CMD = {
	4'd0        ,//没啥用
	4'd0        ,//TAG, 最终会流传到STS上，不用
	s2mm_saddr  ,//SADDR, 起始地址
	1'b0        ,//DRE重新对齐请求。	
	s2mm_eof    ,//EOF标志, 永不停歇
	6'd0        ,//DRE 流对齐
	s2mm_incr   ,//传完后不做地址递增
	s2mm_lenx    //一次传输65536个byte
};

always @ (posedge axi_aclk or negedge axi_aresetn )
	if(!axi_aresetn) begin
		MM2S_CMD_tdata      <= 72'd0    ;
		MM2S_CMD_tvalid     <=  1'd0;
	end else begin
		MM2S_CMD_tdata      <= MM2S_CMD ;
		MM2S_CMD_tvalid     <= !M_AXIS_MM2S_CMD_tready;
	end


always @ (posedge axi_aclk or negedge axi_aresetn )
	if(!axi_aresetn) begin
		S2MM_CMD_tdata      <= 72'd0    ;
		S2MM_CMD_tvalid     <=  1'd0;
	end else begin
		S2MM_CMD_tdata      <= S2MM_CMD ;
		S2MM_CMD_tvalid     <= !M_AXIS_S2MM_CMD_tready;
	end




//========================================================================================================
//2. 寄存器控制总线
localparam ADDR_WIDTH = 32; 
localparam DATA_WIDTH = 32;
localparam STRB_WIDTH =  4;
wire [ADDR_WIDTH-1:0]  reg_wr_addr;
wire [DATA_WIDTH-1:0]  reg_wr_data;
wire [STRB_WIDTH-1:0]  reg_wr_strb;
wire                   reg_wr_en  ;
wire [ADDR_WIDTH-1:0]  reg_rd_addr;
wire                   reg_rd_en  ;
reg  [DATA_WIDTH-1:0]  reg_rd_data;

axil_reg_if axil_reg_if_inst (
    .clk              ( axi_aclk          ),
    .rst              (~axi_aresetn       ),

    .s_axil_awaddr    (S_AXI_LITE_awaddr    ),//output wire [ADDR_WIDTH-1:0]    m04_axil_awaddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    .s_axil_awprot    (S_AXI_LITE_awprot    ),//output wire [2:0]               m04_axil_awprot,   <--> input  wire [2:0]             s_axil_awprot,
    .s_axil_awvalid   (S_AXI_LITE_awvalid   ),//output wire                     m04_axil_awvalid,  <--> input  wire                   s_axil_awvalid,
    .s_axil_awready   (S_AXI_LITE_awready   ),//input  wire                     m04_axil_awready,  <--> output wire                   s_axil_awready,
    .s_axil_wdata     (S_AXI_LITE_wdata     ),//output wire [DATA_WIDTH-1:0]    m04_axil_wdata,    <--> input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    .s_axil_wstrb     (S_AXI_LITE_wstrb     ),//output wire [STRB_WIDTH-1:0]    m04_axil_wstrb,    <--> input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    .s_axil_wvalid    (S_AXI_LITE_wvalid    ),//output wire                     m04_axil_wvalid,   <--> input  wire                   s_axil_wvalid,
    .s_axil_wready    (S_AXI_LITE_wready    ),//input  wire                     m04_axil_wready,   <--> output wire                   s_axil_wready,
    .s_axil_bresp     (S_AXI_LITE_bresp     ),//input  wire [1:0]               m04_axil_bresp,    <--> output wire [1:0]             s_axil_bresp,
    .s_axil_bvalid    (S_AXI_LITE_bvalid    ),//input  wire                     m04_axil_bvalid,   <--> output wire                   s_axil_bvalid,
    .s_axil_bready    (S_AXI_LITE_bready    ),//output wire                     m04_axil_bready,   <--> input  wire                   s_axil_bready,
    .s_axil_araddr    (S_AXI_LITE_araddr    ),//output wire [ADDR_WIDTH-1:0]    m04_axil_araddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    .s_axil_arprot    (S_AXI_LITE_arprot    ),//output wire [2:0]               m04_axil_arprot,   <--> input  wire [2:0]             s_axil_arprot,
    .s_axil_arvalid   (S_AXI_LITE_arvalid   ),//output wire                     m04_axil_arvalid,  <--> input  wire                   s_axil_arvalid,
    .s_axil_arready   (S_AXI_LITE_arready   ),//input  wire                     m04_axil_arready,  <--> output wire                   s_axil_arready,
    .s_axil_rdata     (S_AXI_LITE_rdata     ),//input  wire [DATA_WIDTH-1:0]    m04_axil_rdata,    <--> output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    .s_axil_rresp     (S_AXI_LITE_rresp     ),//input  wire [1:0]               m04_axil_rresp,    <--> output wire [1:0]             s_axil_rresp,
    .s_axil_rvalid    (S_AXI_LITE_rvalid    ),//input  wire                     m04_axil_rvalid,   <--> output wire                   s_axil_rvalid,
    .s_axil_rready    (S_AXI_LITE_rready    ),//output wire                     m04_axil_rready    <--> input  wire                   s_axil_rready,

    .reg_wr_addr      (reg_wr_addr        ),//output wire [ADDR_WIDTH-1:0]  reg_wr_addr,
    .reg_wr_data      (reg_wr_data        ),//output wire [DATA_WIDTH-1:0]  reg_wr_data,
    .reg_wr_strb      (reg_wr_strb        ),//output wire [STRB_WIDTH-1:0]  reg_wr_strb,
    .reg_wr_en        (reg_wr_en          ),//output wire                   reg_wr_en  ,
    .reg_wr_wait      (1'b0               ),//input  wire                   reg_wr_wait,
    .reg_wr_ack       (1'b1               ),//input  wire                   reg_wr_ack ,
    .reg_rd_addr      (reg_rd_addr        ),//output wire [ADDR_WIDTH-1:0]  reg_rd_addr,
    .reg_rd_en        (reg_rd_en          ),//output wire                   reg_rd_en  ,
    .reg_rd_data      (reg_rd_data        ),//input  wire [DATA_WIDTH-1:0]  reg_rd_data,
    .reg_rd_wait      (1'b0               ),//input  wire                   reg_rd_wait,
    .reg_rd_ack       (1'b1               ) //input  wire                   reg_rd_ack 
);

                       
                       
                       
//写入
always @ (posedge axi_aclk or negedge axi_aresetn )
	if(!axi_aresetn) begin
		mm2s_saddr <= 32'd0;
		mm2s_eof   <=  1'd0;
		mm2s_incr  <=  1'd0;
		mm2s_lenx  <= 23'd1;
		
		s2mm_saddr <= 32'd0;
		s2mm_eof   <=  1'd0;
		s2mm_incr  <=  1'd0;
		s2mm_lenx  <= 23'd1;
	end
	else if(reg_wr_en)
	begin
		case({reg_wr_addr[3:2],2'b00})
			4'h0: begin
				if(reg_wr_strb[0]) mm2s_saddr[ 7: 0] <= reg_wr_data[ 7: 0]; 
				if(reg_wr_strb[1]) mm2s_saddr[15: 8] <= reg_wr_data[15: 8]; 
				if(reg_wr_strb[2]) mm2s_saddr[23:16] <= reg_wr_data[23:16]; 
				if(reg_wr_strb[3]) mm2s_saddr[31:24] <= reg_wr_data[31:24]; 
			end
			4'h4:begin
				if(reg_wr_strb[0]) mm2s_lenx [ 7: 0] <= reg_wr_data[ 7: 0]; 
				if(reg_wr_strb[1]) mm2s_lenx [15: 8] <= reg_wr_data[15: 8]; 
				if(reg_wr_strb[2]) mm2s_lenx [22:16] <= reg_wr_data[22:16]; 
				if(reg_wr_strb[3]) mm2s_incr         <= reg_wr_data[23   ]; 
				if(reg_wr_strb[3]) mm2s_eof          <= reg_wr_data[30   ]; 
			end
			4'h08: begin
				if(reg_wr_strb[0]) s2mm_saddr[ 7: 0] <= reg_wr_data[ 7: 0]; 
				if(reg_wr_strb[1]) s2mm_saddr[15: 8] <= reg_wr_data[15: 8]; 
				if(reg_wr_strb[2]) s2mm_saddr[23:16] <= reg_wr_data[23:16]; 
				if(reg_wr_strb[3]) s2mm_saddr[31:24] <= reg_wr_data[31:24]; 
			end
			4'h0c:begin
				if(reg_wr_strb[0]) s2mm_lenx [ 7: 0] <= reg_wr_data[ 7: 0]; 
				if(reg_wr_strb[1]) s2mm_lenx [15: 8] <= reg_wr_data[15: 8]; 
				if(reg_wr_strb[2]) s2mm_lenx [22:16] <= reg_wr_data[22:16]; 
				if(reg_wr_strb[3]) s2mm_incr         <= reg_wr_data[23   ]; 
				if(reg_wr_strb[3]) s2mm_eof          <= reg_wr_data[30   ]; 
			end
		endcase
	end






//读出
always @ (posedge axi_aclk or negedge axi_aresetn )
	if(!axi_aresetn) 
		reg_rd_data <= 32'd0;
	else if(reg_rd_en) begin
		case({reg_rd_addr[3:2],2'b00})
			4'h00  : reg_rd_data <= mm2s_saddr;
			4'h04  : reg_rd_data <= MM2S_CMD[31:0];
			4'h08  : reg_rd_data <= s2mm_saddr;
			4'h0c  : reg_rd_data <= S2MM_CMD[31:0];
			default: reg_rd_data <= 32'd0;
		endcase
	end

















endmodule
