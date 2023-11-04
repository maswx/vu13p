//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月04日 星期六 15时25分36秒
//========================================================================
//
//
module tandem_app_led #(
	parameter  DATA_WIDTH      = 32 ,
	parameter  ADDR_WIDTH      = 16 ,
	parameter  STRB_WIDTH      = 4  ,
	parameter  PIPELINE_OUTPUT = 0   
) (
input                         axi_aclk   ,
input                         axi_aresetn,

input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
input  wire [2:0]             s_axil_awprot,
input  wire                   s_axil_awvalid,
output wire                   s_axil_awready,
input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
input  wire                   s_axil_wvalid,
output wire                   s_axil_wready,
output wire [1:0]             s_axil_bresp,
output wire                   s_axil_bvalid,
input  wire                   s_axil_bready,
input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
input  wire [2:0]             s_axil_arprot,
input  wire                   s_axil_arvalid,
output wire                   s_axil_arready,
output wire [DATA_WIDTH-1:0]  s_axil_rdata,
output wire [1:0]             s_axil_rresp,
output wire                   s_axil_rvalid,
input  wire                   s_axil_rready,

output      [7:0]             LED
);

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

    .s_axil_awaddr    ( axil_awaddr    ),//output wire [ADDR_WIDTH-1:0]    m03_axil_awaddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    .s_axil_awprot    ( axil_awprot    ),//output wire [2:0]               m03_axil_awprot,   <--> input  wire [2:0]             s_axil_awprot,
    .s_axil_awvalid   ( axil_awvalid   ),//output wire                     m03_axil_awvalid,  <--> input  wire                   s_axil_awvalid,
    .s_axil_awready   ( axil_awready   ),//input  wire                     m03_axil_awready,  <--> output wire                   s_axil_awready,
    .s_axil_wdata     ( axil_wdata     ),//output wire [DATA_WIDTH-1:0]    m03_axil_wdata,    <--> input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    .s_axil_wstrb     ( axil_wstrb     ),//output wire [STRB_WIDTH-1:0]    m03_axil_wstrb,    <--> input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    .s_axil_wvalid    ( axil_wvalid    ),//output wire                     m03_axil_wvalid,   <--> input  wire                   s_axil_wvalid,
    .s_axil_wready    ( axil_wready    ),//input  wire                     m03_axil_wready,   <--> output wire                   s_axil_wready,
    .s_axil_bresp     ( axil_bresp     ),//input  wire [1:0]               m03_axil_bresp,    <--> output wire [1:0]             s_axil_bresp,
    .s_axil_bvalid    ( axil_bvalid    ),//input  wire                     m03_axil_bvalid,   <--> output wire                   s_axil_bvalid,
    .s_axil_bready    ( axil_bready    ),//output wire                     m03_axil_bready,   <--> input  wire                   s_axil_bready,
    .s_axil_araddr    ( axil_araddr    ),//output wire [ADDR_WIDTH-1:0]    m03_axil_araddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    .s_axil_arprot    ( axil_arprot    ),//output wire [2:0]               m03_axil_arprot,   <--> input  wire [2:0]             s_axil_arprot,
    .s_axil_arvalid   ( axil_arvalid   ),//output wire                     m03_axil_arvalid,  <--> input  wire                   s_axil_arvalid,
    .s_axil_arready   ( axil_arready   ),//input  wire                     m03_axil_arready,  <--> output wire                   s_axil_arready,
    .s_axil_rdata     ( axil_rdata     ),//input  wire [DATA_WIDTH-1:0]    m03_axil_rdata,    <--> output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    .s_axil_rresp     ( axil_rresp     ),//input  wire [1:0]               m03_axil_rresp,    <--> output wire [1:0]             s_axil_rresp,
    .s_axil_rvalid    ( axil_rvalid    ),//input  wire                     m03_axil_rvalid,   <--> output wire                   s_axil_rvalid,
    .s_axil_rready    ( axil_rready    ),//output wire                     m03_axil_rready    <--> input  wire                   s_axil_rready,

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

reg [7:0] led_reg ;
//写入
always @ (posedge sys_clk or negedge rst_n)
	if(!rst_n)
	begin
		led_reg         <= 8'd0;
	end
	else if(reg_wr_en)
	begin
		case(reg_wr_addr[3:2],2'b00)
			4'h0: begin
				if(reg_wr_strb[0]) 
					led_reg <= reg_wr_data[7:0];
			end
		endcase
	end
//读出
always @ (posedge sys_clk or negedge rst_n)
	if(!rst_n)
		reg_rd_data <= 32'd0;
	else if(reg_rd_en)
	begin
		case(reg_rd_addr[3:2],2'b00)
			4'h0: reg_rd_data <= {24'd0, led_reg};
		endcase
	end

assign LED = led_reg;
