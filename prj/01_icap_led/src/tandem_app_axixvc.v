//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月04日 星期六 15时25分40秒
//========================================================================
//
module tandem_app_axixvc#(
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
debug_bridge_0 your_instance_name (
  .s_axi_aclk      (  axi_aclk      ),// input  wire s_axi_aclk
  .s_axi_aresetn   (  axi_aresetn   ),// input  wire s_axi_aresetn
  .S_AXI_araddr    (s_axil_araddr    ),// input  wire [4 : 0] S_AXI_araddr
  .S_AXI_arprot    (s_axil_arprot    ),// input  wire [2 : 0] S_AXI_arprot
  .S_AXI_arready   (s_axil_arready   ),// output wire S_AXI_arready
  .S_AXI_arvalid   (s_axil_arvalid   ),// input  wire S_AXI_arvalid
  .S_AXI_awaddr    (s_axil_awaddr    ),// input  wire [4 : 0] S_AXI_awaddr
  .S_AXI_awprot    (s_axil_awprot    ),// input  wire [2 : 0] S_AXI_awprot
  .S_AXI_awready   (s_axil_awready   ),// output wire S_AXI_awready
  .S_AXI_awvalid   (s_axil_awvalid   ),// input  wire S_AXI_awvalid
  .S_AXI_bready    (s_axil_bready    ),// input  wire S_AXI_bready
  .S_AXI_bresp     (s_axil_bresp     ),// output wire [1 : 0] S_AXI_bresp
  .S_AXI_bvalid    (s_axil_bvalid    ),// output wire S_AXI_bvalid
  .S_AXI_rdata     (s_axil_rdata     ),// output wire [31 : 0] S_AXI_rdata
  .S_AXI_rready    (s_axil_rready    ),// input  wire S_AXI_rready
  .S_AXI_rresp     (s_axil_rresp     ),// output wire [1 : 0] S_AXI_rresp
  .S_AXI_rvalid    (s_axil_rvalid    ),// output wire S_AXI_rvalid
  .S_AXI_wdata     (s_axil_wdata     ),// input  wire [31 : 0] S_AXI_wdata
  .S_AXI_wready    (s_axil_wready    ),// output wire S_AXI_wready
  .S_AXI_wstrb     (s_axil_wstrb     ),// input  wire [3 : 0] S_AXI_wstrb
  .S_AXI_wvalid    (s_axil_wvalid    ) // input  wire S_AXI_wvalid
);
assign LED = 8'd0;

endmodule
