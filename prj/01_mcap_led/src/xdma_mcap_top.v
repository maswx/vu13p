//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月03日 星期五 22时55分44秒
//========================================================================



//2. 
/* design by masw@masw.tech 
                                                                                                        
                   +--------+   +--------+                                                              
                   |        |   |        |                                                              
               +-->| M_AXI  |-->| OUTPUT |       
   +--------+  |   |        |   |        |       
   |        |  |   +--------+   +--------+       
   |  XDMA  |--+                                          +-------------+
   |        |  |                                 +---M00->| Alex QSPI   |(64kB)------->  XVC JTAG
   +--------+  |   +--------+   +--------+       |        +-------------+
               |   |        |   | bridge |       |        +-------------+                                                        
               +-->| M_AXIL |-->|        |-------+---M01->|   ICAP      |(64kB)
                   |        |   | 1 to 4 |       |        +-------------+                                                        
                   +--------+   +--------+       |        +-------------+                                                                             
                                                 +---M02->|debug bridge |(64kB)-------> QSPI在线更新静态FLASH区域
                                                 |        +-------------+                      
*/


module xdma_mcap_top#(
	parameter WIRQ       =  2,//中断信号的个数
	parameter ADDR_WIDTH = 32, 
	parameter DATA_WIDTH = 32,
	parameter STRB_WIDTH =  4 
)
(
	input  [   0:0] pcie_ref_clk_p ,
	input  [   0:0] pcie_ref_clk_n ,
	input  [  15:0] pcie_lane_rxp  ,
	input  [  15:0] pcie_lane_rxn  ,
	output [  15:0] pcie_lane_txp  ,
	output [  15:0] pcie_lane_txn  ,
	input           pcie_perst_n   ,
	output          pcie_link_up   ,
//---------------------------------------------------
	output wire           axi_aclk    ,
    input       [WIRQ-1:0]usr_irq_req ,
	output                tandem_rst_n,
	output wire           axi_aresetn ,//log:建议使用tandem_rst_n用于复位, 
//AXI 接口
	input  wire           m_axi_awready    ,
	input  wire           m_axi_wready     ,
	input  wire [  3 : 0] m_axi_bid        ,
	input  wire [  1 : 0] m_axi_bresp      ,
	input  wire           m_axi_bvalid     ,
	input  wire           m_axi_arready    ,
	input  wire [  3 : 0] m_axi_rid        ,
	input  wire [511 : 0] m_axi_rdata      ,
	input  wire [  1 : 0] m_axi_rresp      ,
	input  wire           m_axi_rlast      ,
	input  wire           m_axi_rvalid     ,
	output wire [  3 : 0] m_axi_awid       ,
	output wire [ 63 : 0] m_axi_awaddr     ,
	output wire [  7 : 0] m_axi_awlen      ,
	output wire [  2 : 0] m_axi_awsize     ,
	output wire [  1 : 0] m_axi_awburst    ,
	output wire [  2 : 0] m_axi_awprot     ,
	output wire           m_axi_awvalid    ,
	output wire           m_axi_awlock     ,
	output wire [  3 : 0] m_axi_awcache    ,
	output wire [511 : 0] m_axi_wdata      ,
	output wire [ 63 : 0] m_axi_wstrb      ,
	output wire           m_axi_wlast      ,
	output wire           m_axi_wvalid     ,
	output wire           m_axi_bready     ,
	output wire [  3 : 0] m_axi_arid       ,
	output wire [ 63 : 0] m_axi_araddr     ,
	output wire [  7 : 0] m_axi_arlen      ,
	output wire [  2 : 0] m_axi_arsize     ,
	output wire [  1 : 0] m_axi_arburst    ,
	output wire [  2 : 0] m_axi_arprot     ,
	output wire           m_axi_arvalid    ,
	output wire           m_axi_arlock     ,
	output wire [  3 : 0] m_axi_arcache    ,
	output wire           m_axi_rready     ,
//---------------------------------------------------
//AXIL 接口
	output wire [ADDR_WIDTH-1:0]    m_axil_awaddr  ,
	output wire [2:0]               m_axil_awprot  ,
	output wire                     m_axil_awvalid ,
	input  wire                     m_axil_awready ,
	output wire [DATA_WIDTH-1:0]    m_axil_wdata   ,
	output wire [STRB_WIDTH-1:0]    m_axil_wstrb   ,
	output wire                     m_axil_wvalid  ,
	input  wire                     m_axil_wready  ,
	input  wire [1:0]               m_axil_bresp   ,
	input  wire                     m_axil_bvalid  ,
	output wire                     m_axil_bready  ,
	output wire [ADDR_WIDTH-1:0]    m_axil_araddr  ,
	output wire [2:0]               m_axil_arprot  ,
	output wire                     m_axil_arvalid ,
	input  wire                     m_axil_arready ,
	input  wire [DATA_WIDTH-1:0]    m_axil_rdata   ,
	input  wire [1:0]               m_axil_rresp   ,
	input  wire                     m_axil_rvalid  ,
	output wire                     m_axil_rready  

//---------------------------------------------------
// 中断

);
//wire           axi_aclk      ;//output wire           axi_aclk      ,250M
//wire           axi_aresetn   ;//output wire           axi_aresetn   ,
//wire           m_axi_awready ;//input  wire           m_axi_awready ,
//wire           m_axi_wready  ;//input  wire           m_axi_wready  ,
//wire [  3 : 0] m_axi_bid     ;//input  wire [  3 : 0] m_axi_bid     ,
//wire [  1 : 0] m_axi_bresp   ;//input  wire [  1 : 0] m_axi_bresp   ,
//wire           m_axi_bvalid  ;//input  wire           m_axi_bvalid  ,
//wire           m_axi_arready ;//input  wire           m_axi_arready ,
//wire [  3 : 0] m_axi_rid     ;//input  wire [  3 : 0] m_axi_rid     ,
//wire [511 : 0] m_axi_rdata   ;//input  wire [511 : 0] m_axi_rdata   ,
//wire [  1 : 0] m_axi_rresp   ;//input  wire [  1 : 0] m_axi_rresp   ,
//wire           m_axi_rlast   ;//input  wire           m_axi_rlast   ,
//wire           m_axi_rvalid  ;//input  wire           m_axi_rvalid  ,
//wire [  3 : 0] m_axi_awid    ;//output wire [  3 : 0] m_axi_awid    ,
//wire [ 63 : 0] m_axi_awaddr  ;//output wire [ 63 : 0] m_axi_awaddr  ,
//wire [  7 : 0] m_axi_awlen   ;//output wire [  7 : 0] m_axi_awlen   ,
//wire [  2 : 0] m_axi_awsize  ;//output wire [  2 : 0] m_axi_awsize  ,
//wire [  1 : 0] m_axi_awburst ;//output wire [  1 : 0] m_axi_awburst ,
//wire [  2 : 0] m_axi_awprot  ;//output wire [  2 : 0] m_axi_awprot  ,
//wire           m_axi_awvalid ;//output wire           m_axi_awvalid ,
//wire           m_axi_awlock  ;//output wire           m_axi_awlock  ,
//wire [  3 : 0] m_axi_awcache ;//output wire [  3 : 0] m_axi_awcache ,
//wire [511 : 0] m_axi_wdata   ;//output wire [511 : 0] m_axi_wdata   ,
//wire [ 63 : 0] m_axi_wstrb   ;//output wire [ 63 : 0] m_axi_wstrb   ,
//wire           m_axi_wlast   ;//output wire           m_axi_wlast   ,
//wire           m_axi_wvalid  ;//output wire           m_axi_wvalid  ,
//wire           m_axi_bready  ;//output wire           m_axi_bready  ,
//wire [  3 : 0] m_axi_arid    ;//output wire [  3 : 0] m_axi_arid    ,
//wire [ 63 : 0] m_axi_araddr  ;//output wire [ 63 : 0] m_axi_araddr  ,
//wire [  7 : 0] m_axi_arlen   ;//output wire [  7 : 0] m_axi_arlen   ,
//wire [  2 : 0] m_axi_arsize  ;//output wire [  2 : 0] m_axi_arsize  ,
//wire [  1 : 0] m_axi_arburst ;//output wire [  1 : 0] m_axi_arburst ,
//wire [  2 : 0] m_axi_arprot  ;//output wire [  2 : 0] m_axi_arprot  ,
//wire           m_axi_arvalid ;//output wire           m_axi_arvalid ,
//wire           m_axi_arlock  ;//output wire           m_axi_arlock  ,
//wire [  3 : 0] m_axi_arcache ;//output wire [  3 : 0] m_axi_arcache ,
//wire           m_axi_rready  ;//output wire           m_axi_rready  ,
//==========================================================================================================
//1. xdma core
wire [ 31 : 0] axil_awaddr ;//output wire [ 31 : 0] m_axil_awaddr ,
wire [  2 : 0] axil_awprot ;//output wire [  2 : 0] m_axil_awprot ,
wire           axil_awvalid;//output wire           m_axil_awvalid,
wire           axil_awready;//input  wire           m_axil_awready,
wire [ 31 : 0] axil_wdata  ;//output wire [ 31 : 0] m_axil_wdata  ,
wire [  3 : 0] axil_wstrb  ;//output wire [  3 : 0] m_axil_wstrb  ,
wire           axil_wvalid ;//output wire           m_axil_wvalid ,
wire           axil_wready ;//input  wire           m_axil_wready ,
wire           axil_bvalid ;//input  wire           m_axil_bvalid ,
wire [  1 : 0] axil_bresp  ;//input  wire [  1 : 0] m_axil_bresp  ,
wire           axil_bready ;//output wire           m_axil_bready ,
wire [ 31 : 0] axil_araddr ;//output wire [ 31 : 0] m_axil_araddr ,
wire [  2 : 0] axil_arprot ;//output wire [  2 : 0] m_axil_arprot ,
wire           axil_arvalid;//output wire           m_axil_arvalid,
wire           axil_arready;//input  wire           m_axil_arready,
wire [ 31 : 0] axil_rdata  ;//input  wire [ 31 : 0] m_axil_rdata  ,
wire [  1 : 0] axil_rresp  ;//input  wire [  1 : 0] m_axil_rresp  ,
wire           axil_rvalid ;//input  wire           m_axil_rvalid ,
wire           axil_rready ;//output wire           m_axil_rready 
wire mcap_design_switch   ;
wire pcie_sys_clk   ;
wire pcie_sys_clk_gt;
IBUFDS_GTE4 #(
    .REFCLK_HROW_CK_SEL(2'b00)
) ibufds_gte4_pcie_mgt_refclk_inst (
    .I             (pcie_ref_clk_p ),
    .IB            (pcie_ref_clk_n ),
    .CEB           (1'b0           ),
    .O             (pcie_sys_clk_gt),
    .ODIV2         (pcie_sys_clk   )
);

xdma_0 xdma_0_inst(
	.sys_clk              (pcie_sys_clk         ),// input  wire sys_clk
	.sys_clk_gt           (pcie_sys_clk_gt      ),// input  wire sys_clk_gt
	.sys_rst_n            (pcie_perst_n         ),// input  wire sys_rst_n
	.user_lnk_up          (pcie_link_up         ),// output wire user_lnk_up
	.pci_exp_txp          (pcie_lane_txp        ),// output wire [15 : 0] pci_exp_txp
	.pci_exp_txn          (pcie_lane_txn        ),// output wire [15 : 0] pci_exp_txn
	.pci_exp_rxp          (pcie_lane_rxp        ),// input  wire [15 : 0] pci_exp_rxp
	.pci_exp_rxn          (pcie_lane_rxn        ),// input  wire [15 : 0] pci_exp_rxn

	.axi_aclk             (axi_aclk             ),// output wire axi_aclk
	.axi_aresetn          (axi_aresetn          ),// output wire axi_aresetn
	.usr_irq_req          (usr_irq_req          ),// input  wire [7 : 0] usr_irq_req
	.usr_irq_ack          (                     ),// output wire [7 : 0] usr_irq_ack
	.msi_enable           (                     ),// output wire msi_enable
	.msi_vector_width     (                     ),// output wire [2 : 0] msi_vector_width
	.m_axi_awready        (mcap_design_switch ? m_axi_awready  :   1'd1),// input  wire m_axi_awready
	.m_axi_wready         (mcap_design_switch ? m_axi_wready   :   1'd1),// input  wire m_axi_wready
	.m_axi_bid            (mcap_design_switch ? m_axi_bid      :   4'd0),// input  wire [3 : 0] m_axi_bid
	.m_axi_bresp          (mcap_design_switch ? m_axi_bresp    :   2'd0),// input  wire [1 : 0] m_axi_bresp
	.m_axi_bvalid         (mcap_design_switch ? m_axi_bvalid   :   1'd0),// input  wire m_axi_bvalid
	.m_axi_arready        (mcap_design_switch ? m_axi_arready  :   1'd1),// input  wire m_axi_arready
	.m_axi_rid            (mcap_design_switch ? m_axi_rid      :   4'd0),// input  wire [3 : 0] m_axi_rid
	.m_axi_rdata          (mcap_design_switch ? m_axi_rdata    : 512'd0),// input  wire [511 : 0] m_axi_rdata
	.m_axi_rresp          (mcap_design_switch ? m_axi_rresp    :   2'd0),// input  wire [1 : 0] m_axi_rresp
	.m_axi_rlast          (mcap_design_switch ? m_axi_rlast    :   1'd0),// input  wire m_axi_rlast
	.m_axi_rvalid         (mcap_design_switch ? m_axi_rvalid   :   1'd0),// input  wire m_axi_rvalid
	.m_axi_awid           (m_axi_awid                                  ),// output wire [3 : 0] m_axi_awid
	.m_axi_awaddr         (m_axi_awaddr                                ),// output wire [63 : 0] m_axi_awaddr
	.m_axi_awlen          (m_axi_awlen                                 ),// output wire [7 : 0] m_axi_awlen
	.m_axi_awsize         (m_axi_awsize                                ),// output wire [2 : 0] m_axi_awsize
	.m_axi_awburst        (m_axi_awburst                               ),// output wire [1 : 0] m_axi_awburst
	.m_axi_awprot         (m_axi_awprot                                ),// output wire [2 : 0] m_axi_awprot
	.m_axi_awvalid        (m_axi_awvalid                               ),// output wire m_axi_awvalid
	.m_axi_awlock         (m_axi_awlock                                ),// output wire m_axi_awlock
	.m_axi_awcache        (m_axi_awcache                               ),// output wire [3 : 0] m_axi_awcache
	.m_axi_wdata          (m_axi_wdata                                 ),// output wire [511 : 0] m_axi_wdata
	.m_axi_wstrb          (m_axi_wstrb                                 ),// output wire [63 : 0] m_axi_wstrb
	.m_axi_wlast          (m_axi_wlast                                 ),// output wire m_axi_wlast
	.m_axi_wvalid         (m_axi_wvalid                                ),// output wire m_axi_wvalid
	.m_axi_bready         (m_axi_bready                                ),// output wire m_axi_bready
	.m_axi_arid           (m_axi_arid                                  ),// output wire [3 : 0] m_axi_arid
	.m_axi_araddr         (m_axi_araddr                                ),// output wire [63 : 0] m_axi_araddr
	.m_axi_arlen          (m_axi_arlen                                 ),// output wire [7 : 0] m_axi_arlen
	.m_axi_arsize         (m_axi_arsize                                ),// output wire [2 : 0] m_axi_arsize
	.m_axi_arburst        (m_axi_arburst                               ),// output wire [1 : 0] m_axi_arburst
	.m_axi_arprot         (m_axi_arprot                                ),// output wire [2 : 0] m_axi_arprot
	.m_axi_arvalid        (m_axi_arvalid                               ),// output wire m_axi_arvalid
	.m_axi_arlock         (m_axi_arlock                                ),// output wire m_axi_arlock
	.m_axi_arcache        (m_axi_arcache                               ),// output wire [3 : 0] m_axi_arcache
	.m_axi_rready         (m_axi_rready                                ),// output wire m_axi_rready
	.m_axil_awready       (mcap_design_switch ?  axil_awready  :  1'd1 ),// input  wire m_axil_awready
	.m_axil_wready        (mcap_design_switch ?  axil_wready   :  1'd1 ),// input  wire m_axil_wready
	.m_axil_bvalid        (mcap_design_switch ?  axil_bvalid   :  1'd0 ),// input  wire m_axil_bvalid
	.m_axil_bresp         (mcap_design_switch ?  axil_bresp    :  2'd0 ),// input  wire [1 : 0] m_axil_bresp
	.m_axil_arready       (mcap_design_switch ?  axil_arready  :  1'd1 ),// input  wire m_axil_arready
	.m_axil_rdata         (mcap_design_switch ?  axil_rdata    : 31'd0 ),// input  wire [31 : 0] m_axil_rdata
	.m_axil_rresp         (mcap_design_switch ?  axil_rresp    :  2'd0 ),// input  wire [1 : 0] m_axil_rresp
	.m_axil_rvalid        (mcap_design_switch ?  axil_rvalid   :  1'd0 ),// input  wire m_axil_rvalid
	.m_axil_awaddr        (  axil_awaddr                               ),// output wire [31 : 0] m_axil_awaddr
	.m_axil_awprot        (  axil_awprot                               ),// output wire [2 : 0] m_axil_awprot
	.m_axil_awvalid       (  axil_awvalid                              ),// output wire m_axil_awvalid
	.m_axil_wdata         (  axil_wdata                                ),// output wire [31 : 0] m_axil_wdata
	.m_axil_wstrb         (  axil_wstrb                                ),// output wire [3 : 0] m_axil_wstrb
	.m_axil_wvalid        (  axil_wvalid                               ),// output wire m_axil_wvalid
	.m_axil_bready        (  axil_bready                               ),// output wire m_axil_bready
	.m_axil_araddr        (  axil_araddr                               ),// output wire [31 : 0] m_axil_araddr
	.m_axil_arprot        (  axil_arprot                               ),// output wire [2 : 0] m_axil_arprot
	.m_axil_arvalid       (  axil_arvalid                              ),// output wire m_axil_arvalid
	.m_axil_rready        (  axil_rready                               ),// output wire m_axil_rready
	.mcap_design_switch   (mcap_design_switch                          ),// output wire mcap_design_switch 0: 尚未加载 stage2 ； 1: stage2加载OK
	.cap_req              (                                            ),// output wire cap_req
	.cap_gnt              (1'b1                                        ),// input  wire cap_gnt
	.cap_rel              (1'b0                                        ) // input  wire cap_rel
);



assign tandem_rst_n  = ~mcap_design_switch;
//==========================================================================================================

wire [ 31 : 0]           m00_axil_awaddr ;//output wire [ 31 : 0] m_axil_awaddr ,
wire [  2 : 0]           m00_axil_awprot ;//output wire [  2 : 0] m_axil_awprot ,
wire                     m00_axil_awvalid;//output wire           m_axil_awvalid,
wire                     m00_axil_awready;//input  wire           m_axil_awready,
wire [ 31 : 0]           m00_axil_wdata  ;//output wire [ 31 : 0] m_axil_wdata  ,
wire [  3 : 0]           m00_axil_wstrb  ;//output wire [  3 : 0] m_axil_wstrb  ,
wire                     m00_axil_wvalid ;//output wire           m_axil_wvalid ,
wire                     m00_axil_wready ;//input  wire           m_axil_wready ,
wire                     m00_axil_bvalid ;//input  wire           m_axil_bvalid ,
wire [  1 : 0]           m00_axil_bresp  ;//input  wire [  1 : 0] m_axil_bresp  ,
wire                     m00_axil_bready ;//output wire           m_axil_bready ,
wire [ 31 : 0]           m00_axil_araddr ;//output wire [ 31 : 0] m_axil_araddr ,
wire [  2 : 0]           m00_axil_arprot ;//output wire [  2 : 0] m_axil_arprot ,
wire                     m00_axil_arvalid;//output wire           m_axil_arvalid,
wire                     m00_axil_arready;//input  wire           m_axil_arready,
wire [ 31 : 0]           m00_axil_rdata  ;//input  wire [ 31 : 0] m_axil_rdata  ,
wire [  1 : 0]           m00_axil_rresp  ;//input  wire [  1 : 0] m_axil_rresp  ,
wire                     m00_axil_rvalid ;//input  wire           m_axil_rvalid ,
wire                     m00_axil_rready ;//output wire           m_axil_rready 


wire [ADDR_WIDTH-1:0]    m01_axil_awaddr    ;
wire [2:0]               m01_axil_awprot    ;
wire                     m01_axil_awvalid   ;
wire                     m01_axil_awready   ;
wire [DATA_WIDTH-1:0]    m01_axil_wdata     ;
wire [STRB_WIDTH-1:0]    m01_axil_wstrb     ;
wire                     m01_axil_wvalid    ;
wire                     m01_axil_wready    ;
wire [1:0]               m01_axil_bresp     ;
wire                     m01_axil_bvalid    ;
wire                     m01_axil_bready    ;
wire [ADDR_WIDTH-1:0]    m01_axil_araddr    ;
wire [2:0]               m01_axil_arprot    ;
wire                     m01_axil_arvalid   ;
wire                     m01_axil_arready   ;
wire [DATA_WIDTH-1:0]    m01_axil_rdata     ;
wire [1:0]               m01_axil_rresp     ;
wire                     m01_axil_rvalid    ;
wire                     m01_axil_rready    ;
// AXI bus mux
localparam M_REGIONS = 1;
axil_interconnect_wrap_1x3 # (
    .DATA_WIDTH           ( 32                  ),
    .ADDR_WIDTH           ( 20                  ),
    .STRB_WIDTH           ( (DATA_WIDTH/8)      ),
    .M_REGIONS            ( M_REGIONS           ),
    .M00_BASE_ADDR        ( 0                   ),
    .M00_ADDR_WIDTH       ( {M_REGIONS{32'd16}} ),//64KB
    .M00_CONNECT_READ     ( 1'b1                ),
    .M00_CONNECT_WRITE    ( 1'b1                ),
    .M00_SECURE           ( 1'b0                ),
    .M01_BASE_ADDR        ( 0                   ),
    .M01_ADDR_WIDTH       ( {M_REGIONS{32'd16}} ),//64kB
    .M01_CONNECT_READ     ( 1'b1                ),
    .M01_CONNECT_WRITE    ( 1'b1                ),
    .M01_SECURE           ( 1'b0                ),
    .M02_BASE_ADDR        ( 0                   ),
    .M02_ADDR_WIDTH       ( {M_REGIONS{32'd19}} ),//64kB
    .M02_CONNECT_READ     ( 1'b1                ),
    .M02_CONNECT_WRITE    ( 1'b1                ),
    .M02_SECURE           ( 1'b0                ) 
)axil_interconnect_wrap_1x4_inst (
    .clk                  ( axi_aclk            ),
    .rst                  (~axi_aresetn         ),

    .s00_axil_awaddr      (  axil_awaddr        ),//output wire [ 31 : 0] m_axil_awaddr   <--> input  wire [ADDR_WIDTH-1:0]    s00_axil_awaddr,
    .s00_axil_awprot      (  axil_awprot        ),//output wire [  2 : 0] m_axil_awprot   <--> input  wire [2:0]               s00_axil_awprot,
    .s00_axil_awvalid     (  axil_awvalid       ),//output wire           m_axil_awvalid  <--> input  wire                     s00_axil_awvalid,
    .s00_axil_awready     (  axil_awready       ),//input  wire           m_axil_awready  <--> output wire                     s00_axil_awready,
    .s00_axil_wdata       (  axil_wdata         ),//output wire [ 31 : 0] m_axil_wdata    <--> input  wire [DATA_WIDTH-1:0]    s00_axil_wdata,
    .s00_axil_wstrb       (  axil_wstrb         ),//output wire [  3 : 0] m_axil_wstrb    <--> input  wire [STRB_WIDTH-1:0]    s00_axil_wstrb,
    .s00_axil_wvalid      (  axil_wvalid        ),//output wire           m_axil_wvalid   <--> input  wire                     s00_axil_wvalid,
    .s00_axil_wready      (  axil_wready        ),//input  wire           m_axil_wready   <--> output wire                     s00_axil_wready,
    .s00_axil_bvalid      (  axil_bvalid        ),//input  wire           m_axil_bvalid   <--> output wire                     s00_axil_bvalid,
    .s00_axil_bresp       (  axil_bresp         ),//input  wire [  1 : 0] m_axil_bresp    <--> output wire [1:0]               s00_axil_bresp,
    .s00_axil_bready      (  axil_bready        ),//output wire           m_axil_bready   <--> input  wire                     s00_axil_bready,
    .s00_axil_araddr      (  axil_araddr        ),//output wire [ 31 : 0] m_axil_araddr   <--> input  wire [ADDR_WIDTH-1:0]    s00_axil_araddr,
    .s00_axil_arprot      (  axil_arprot        ),//output wire [  2 : 0] m_axil_arprot   <--> input  wire [2:0]               s00_axil_arprot,
    .s00_axil_arvalid     (  axil_arvalid       ),//output wire           m_axil_arvalid  <--> input  wire                     s00_axil_arvalid,
    .s00_axil_arready     (  axil_arready       ),//input  wire           m_axil_arready  <--> output wire                     s00_axil_arready,
    .s00_axil_rdata       (  axil_rdata         ),//input  wire [ 31 : 0] m_axil_rdata    <--> output wire [DATA_WIDTH-1:0]    s00_axil_rdata,
    .s00_axil_rresp       (  axil_rresp         ),//input  wire [  1 : 0] m_axil_rresp    <--> output wire [1:0]               s00_axil_rresp,
    .s00_axil_rvalid      (  axil_rvalid        ),//input  wire           m_axil_rvalid   <--> output wire                     s00_axil_rvalid,
    .s00_axil_rready      (  axil_rready        ),//output wire           m_axil_rready   <--> input  wire                     s00_axil_rready,

    .m00_axil_awaddr      (m00_axil_awaddr      ),//output wire [ 31 : 0] m_axil_awaddr   <--> output wire [ADDR_WIDTH-1:0]    m00_axil_awaddr,
    .m00_axil_awprot      (m00_axil_awprot      ),//output wire [  2 : 0] m_axil_awprot   <--> output wire [2:0]               m00_axil_awprot,
    .m00_axil_awvalid     (m00_axil_awvalid     ),//output wire           m_axil_awvalid  <--> output wire                     m00_axil_awvalid,
    .m00_axil_awready     (m00_axil_awready     ),//input  wire           m_axil_awready  <--> input  wire                     m00_axil_awready,
    .m00_axil_wdata       (m00_axil_wdata       ),//output wire [ 31 : 0] m_axil_wdata    <--> output wire [DATA_WIDTH-1:0]    m00_axil_wdata,
    .m00_axil_wstrb       (m00_axil_wstrb       ),//output wire [  3 : 0] m_axil_wstrb    <--> output wire [STRB_WIDTH-1:0]    m00_axil_wstrb,
    .m00_axil_wvalid      (m00_axil_wvalid      ),//output wire           m_axil_wvalid   <--> output wire                     m00_axil_wvalid,
    .m00_axil_wready      (m00_axil_wready      ),//input  wire           m_axil_wready   <--> input  wire                     m00_axil_wready,
    .m00_axil_bresp       (m00_axil_bresp       ),//input  wire [  1 : 0] m_axil_bresp    <--> input  wire [1:0]               m00_axil_bresp,
    .m00_axil_bvalid      (m00_axil_bvalid      ),//input  wire           m_axil_bvalid   <--> input  wire                     m00_axil_bvalid,
    .m00_axil_bready      (m00_axil_bready      ),//output wire           m_axil_bready   <--> output wire                     m00_axil_bready,
    .m00_axil_araddr      (m00_axil_araddr      ),//output wire [ 31 : 0] m_axil_araddr   <--> output wire [ADDR_WIDTH-1:0]    m00_axil_araddr,
    .m00_axil_arprot      (m00_axil_arprot      ),//output wire [  2 : 0] m_axil_arprot   <--> output wire [2:0]               m00_axil_arprot,
    .m00_axil_arvalid     (m00_axil_arvalid     ),//output wire           m_axil_arvalid  <--> output wire                     m00_axil_arvalid,
    .m00_axil_arready     (m00_axil_arready     ),//input  wire           m_axil_arready  <--> input  wire                     m00_axil_arready,
    .m00_axil_rdata       (m00_axil_rdata       ),//input  wire [ 31 : 0] m_axil_rdata    <--> input  wire [DATA_WIDTH-1:0]    m00_axil_rdata,
    .m00_axil_rresp       (m00_axil_rresp       ),//input  wire [  1 : 0] m_axil_rresp    <--> input  wire [1:0]               m00_axil_rresp,
    .m00_axil_rvalid      (m00_axil_rvalid      ),//input  wire           m_axil_rvalid   <--> input  wire                     m00_axil_rvalid,
    .m00_axil_rready      (m00_axil_rready      ),//output wire           m_axil_rready   <--> output wire                     m00_axil_rready,

    .m01_axil_awaddr      (m01_axil_awaddr      ),//output wire [ADDR_WIDTH-1:0]    m01_axil_awaddr,
    .m01_axil_awprot      (m01_axil_awprot      ),//output wire [2:0]               m01_axil_awprot,
    .m01_axil_awvalid     (m01_axil_awvalid     ),//output wire                     m01_axil_awvalid,
    .m01_axil_awready     (m01_axil_awready     ),//input  wire                     m01_axil_awready,
    .m01_axil_wdata       (m01_axil_wdata       ),//output wire [DATA_WIDTH-1:0]    m01_axil_wdata,
    .m01_axil_wstrb       (m01_axil_wstrb       ),//output wire [STRB_WIDTH-1:0]    m01_axil_wstrb,
    .m01_axil_wvalid      (m01_axil_wvalid      ),//output wire                     m01_axil_wvalid,
    .m01_axil_wready      (m01_axil_wready      ),//input  wire                     m01_axil_wready,
    .m01_axil_bresp       (m01_axil_bresp       ),//input  wire [1:0]               m01_axil_bresp,
    .m01_axil_bvalid      (m01_axil_bvalid      ),//input  wire                     m01_axil_bvalid,
    .m01_axil_bready      (m01_axil_bready      ),//output wire                     m01_axil_bready,
    .m01_axil_araddr      (m01_axil_araddr      ),//output wire [ADDR_WIDTH-1:0]    m01_axil_araddr,
    .m01_axil_arprot      (m01_axil_arprot      ),//output wire [2:0]               m01_axil_arprot,
    .m01_axil_arvalid     (m01_axil_arvalid     ),//output wire                     m01_axil_arvalid,
    .m01_axil_arready     (m01_axil_arready     ),//input  wire                     m01_axil_arready,
    .m01_axil_rdata       (m01_axil_rdata       ),//input  wire [DATA_WIDTH-1:0]    m01_axil_rdata,
    .m01_axil_rresp       (m01_axil_rresp       ),//input  wire [1:0]               m01_axil_rresp,
    .m01_axil_rvalid      (m01_axil_rvalid      ),//input  wire                     m01_axil_rvalid,
    .m01_axil_rready      (m01_axil_rready      ),//output wire                     m01_axil_rready,
                                                
    .m02_axil_awaddr      (m_axil_awaddr      ),//output wire [ADDR_WIDTH-1:0]    m02_axil_awaddr,
    .m02_axil_awprot      (m_axil_awprot      ),//output wire [2:0]               m02_axil_awprot,
    .m02_axil_awvalid     (m_axil_awvalid     ),//output wire                     m02_axil_awvalid,
    .m02_axil_awready     (m_axil_awready     ),//input  wire                     m02_axil_awready,
    .m02_axil_wdata       (m_axil_wdata       ),//output wire [DATA_WIDTH-1:0]    m02_axil_wdata,
    .m02_axil_wstrb       (m_axil_wstrb       ),//output wire [STRB_WIDTH-1:0]    m02_axil_wstrb,
    .m02_axil_wvalid      (m_axil_wvalid      ),//output wire                     m02_axil_wvalid,
    .m02_axil_wready      (m_axil_wready      ),//input  wire                     m02_axil_wready,
    .m02_axil_bresp       (m_axil_bresp       ),//input  wire [1:0]               m02_axil_bresp,
    .m02_axil_bvalid      (m_axil_bvalid      ),//input  wire                     m02_axil_bvalid,
    .m02_axil_bready      (m_axil_bready      ),//output wire                     m02_axil_bready,
    .m02_axil_araddr      (m_axil_araddr      ),//output wire [ADDR_WIDTH-1:0]    m02_axil_araddr,
    .m02_axil_arprot      (m_axil_arprot      ),//output wire [2:0]               m02_axil_arprot,
    .m02_axil_arvalid     (m_axil_arvalid     ),//output wire                     m02_axil_arvalid,
    .m02_axil_arready     (m_axil_arready     ),//input  wire                     m02_axil_arready,
    .m02_axil_rdata       (m_axil_rdata       ),//input  wire [DATA_WIDTH-1:0]    m02_axil_rdata,
    .m02_axil_rresp       (m_axil_rresp       ),//input  wire [1:0]               m02_axil_rresp,
    .m02_axil_rvalid      (m_axil_rvalid      ),//input  wire                     m02_axil_rvalid,
    .m02_axil_rready      (m_axil_rready      ) //output wire                     m02_axil_rready

);



alex_axil_qspi alex_axil_qspi_inst(
  .axi_aclk         (  axi_aclk         ),// input  wire s_axi_aclk
  .axi_aresetn      (  axi_aresetn      ),// input  wire s_axi_aresetn
  .s_axil_araddr    (m00_axil_araddr    ),// input  wire [4 : 0] S_AXI_araddr
  .s_axil_arprot    (m00_axil_arprot    ),// input  wire [2 : 0] S_AXI_arprot
  .s_axil_arready   (m00_axil_arready   ),// output wire S_AXI_arready
  .s_axil_arvalid   (m00_axil_arvalid   ),// input  wire S_AXI_arvalid
  .s_axil_awaddr    (m00_axil_awaddr    ),// input  wire [4 : 0] S_AXI_awaddr
  .s_axil_awprot    (m00_axil_awprot    ),// input  wire [2 : 0] S_AXI_awprot
  .s_axil_awready   (m00_axil_awready   ),// output wire S_AXI_awready
  .s_axil_awvalid   (m00_axil_awvalid   ),// input  wire S_AXI_awvalid
  .s_axil_bready    (m00_axil_bready    ),// input  wire S_AXI_bready
  .s_axil_bresp     (m00_axil_bresp     ),// output wire [1 : 0] S_AXI_bresp
  .s_axil_bvalid    (m00_axil_bvalid    ),// output wire S_AXI_bvalid
  .s_axil_rdata     (m00_axil_rdata     ),// output wire [31 : 0] S_AXI_rdata
  .s_axil_rready    (m00_axil_rready    ),// input  wire S_AXI_rready
  .s_axil_rresp     (m00_axil_rresp     ),// output wire [1 : 0] S_AXI_rresp
  .s_axil_rvalid    (m00_axil_rvalid    ),// output wire S_AXI_rvalid
  .s_axil_wdata     (m00_axil_wdata     ),// input  wire [31 : 0] S_AXI_wdata
  .s_axil_wready    (m00_axil_wready    ),// output wire S_AXI_wready
  .s_axil_wstrb     (m00_axil_wstrb     ),// input  wire [3 : 0] S_AXI_wstrb
  .s_axil_wvalid    (m00_axil_wvalid    ) // input  wire S_AXI_wvalid
);



debug_bridge_0 debug_bridge_0_inst(
  .s_axi_aclk      (  axi_aclk         ),// input  wire s_axi_aclk
  .s_axi_aresetn   (  axi_aresetn      ),// input  wire s_axi_aresetn
  .S_AXI_araddr    (m01_axil_araddr    ),// input  wire [4 : 0] S_AXI_araddr
  .S_AXI_arprot    (m01_axil_arprot    ),// input  wire [2 : 0] S_AXI_arprot
  .S_AXI_arready   (m01_axil_arready   ),// output wire S_AXI_arready
  .S_AXI_arvalid   (m01_axil_arvalid   ),// input  wire S_AXI_arvalid
  .S_AXI_awaddr    (m01_axil_awaddr    ),// input  wire [4 : 0] S_AXI_awaddr
  .S_AXI_awprot    (m01_axil_awprot    ),// input  wire [2 : 0] S_AXI_awprot
  .S_AXI_awready   (m01_axil_awready   ),// output wire S_AXI_awready
  .S_AXI_awvalid   (m01_axil_awvalid   ),// input  wire S_AXI_awvalid
  .S_AXI_bready    (m01_axil_bready    ),// input  wire S_AXI_bready
  .S_AXI_bresp     (m01_axil_bresp     ),// output wire [1 : 0] S_AXI_bresp
  .S_AXI_bvalid    (m01_axil_bvalid    ),// output wire S_AXI_bvalid
  .S_AXI_rdata     (m01_axil_rdata     ),// output wire [31 : 0] S_AXI_rdata
  .S_AXI_rready    (m01_axil_rready    ),// input  wire S_AXI_rready
  .S_AXI_rresp     (m01_axil_rresp     ),// output wire [1 : 0] S_AXI_rresp
  .S_AXI_rvalid    (m01_axil_rvalid    ),// output wire S_AXI_rvalid
  .S_AXI_wdata     (m01_axil_wdata     ),// input  wire [31 : 0] S_AXI_wdata
  .S_AXI_wready    (m01_axil_wready    ),// output wire S_AXI_wready
  .S_AXI_wstrb     (m01_axil_wstrb     ),// input  wire [3 : 0] S_AXI_wstrb
  .S_AXI_wvalid    (m01_axil_wvalid    ) // input  wire S_AXI_wvalid
);












endmodule


