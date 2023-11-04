//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月04日 星期六 15时25分40秒
//========================================================================
//
module tandem_app_bram #(
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

output [7:0] LED

);
axil_ram # (
    .DATA_WIDTH      ( 32 ),
    .ADDR_WIDTH      ( 16 ),
    .STRB_WIDTH      ( 4  ),
    .PIPELINE_OUTPUT ( 0  ) 
)axil_ram_inst (
    .clk             ( axi_aclk       ),
    .rst             (~axi_aresetn    ),

    .s_axil_awaddr   (  axil_awaddr   ),//input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    .s_axil_awprot   (  axil_awprot   ),//input  wire [2:0]             s_axil_awprot,
    .s_axil_awvalid  (  axil_awvalid  ),//input  wire                   s_axil_awvalid,
    .s_axil_awready  (  axil_awready  ),//output wire                   s_axil_awready,
    .s_axil_wdata    (  axil_wdata    ),//input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    .s_axil_wstrb    (  axil_wstrb    ),//input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    .s_axil_wvalid   (  axil_wvalid   ),//input  wire                   s_axil_wvalid,
    .s_axil_wready   (  axil_wready   ),//output wire                   s_axil_wready,
    .s_axil_bresp    (  axil_bresp    ),//output wire [1:0]             s_axil_bresp,
    .s_axil_bvalid   (  axil_bvalid   ),//output wire                   s_axil_bvalid,
    .s_axil_bready   (  axil_bready   ),//input  wire                   s_axil_bready,
    .s_axil_araddr   (  axil_araddr   ),//input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    .s_axil_arprot   (  axil_arprot   ),//input  wire [2:0]             s_axil_arprot,
    .s_axil_arvalid  (  axil_arvalid  ),//input  wire                   s_axil_arvalid,
    .s_axil_arready  (  axil_arready  ),//output wire                   s_axil_arready,
    .s_axil_rdata    (  axil_rdata    ),//output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    .s_axil_rresp    (  axil_rresp    ),//output wire [1:0]             s_axil_rresp,
    .s_axil_rvalid   (  axil_rvalid   ),//output wire                   s_axil_rvalid,
    .s_axil_rready   (  axil_rready   ) //input  wire                   s_axil_rready
);
assign LED = 8'd0;
endmodule
