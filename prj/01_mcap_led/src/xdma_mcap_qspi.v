//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月03日 星期五 22时55分44秒
//========================================================================



module xdma_mcap_qspi(
	input           clk_50M        ,
	input           pcie_ref_clk_p ,
	input           pcie_ref_clk_n ,
	input  [  15:0] pcie_lane_rxp  ,
	input  [  15:0] pcie_lane_rxn  ,
	output [  15:0] pcie_lane_txp  ,
	output [  15:0] pcie_lane_txn  ,
	input           pcie_perst_n   ,
	output          pcie_link_up   ,
	//XDMA interface
	output wire           axi_aclk      ,//output wire           axi_aclk      ,250M
	output wire           axi_aresetn   ,//output wire           axi_aresetn   ,
	input  wire [  7 : 0] usr_irq_req   ,//input  wire [  7 : 0] usr_irq_req   ,
	input  wire           m_axi_awready ,//input  wire           m_axi_awready ,
	input  wire           m_axi_wready  ,//input  wire           m_axi_wready  ,
	input  wire [  3 : 0] m_axi_bid     ,//input  wire [  3 : 0] m_axi_bid     ,
	input  wire [  1 : 0] m_axi_bresp   ,//input  wire [  1 : 0] m_axi_bresp   ,
	input  wire           m_axi_bvalid  ,//input  wire           m_axi_bvalid  ,
	input  wire           m_axi_arready ,//input  wire           m_axi_arready ,
	input  wire [  3 : 0] m_axi_rid     ,//input  wire [  3 : 0] m_axi_rid     ,
	input  wire [511 : 0] m_axi_rdata   ,//input  wire [511 : 0] m_axi_rdata   ,
	input  wire [  1 : 0] m_axi_rresp   ,//input  wire [  1 : 0] m_axi_rresp   ,
	input  wire           m_axi_rlast   ,//input  wire           m_axi_rlast   ,
	input  wire           m_axi_rvalid  ,//input  wire           m_axi_rvalid  ,
	output wire [  3 : 0] m_axi_awid    ,//output wire [  3 : 0] m_axi_awid    ,
	output wire [ 63 : 0] m_axi_awaddr  ,//output wire [ 63 : 0] m_axi_awaddr  ,
	output wire [  7 : 0] m_axi_awlen   ,//output wire [  7 : 0] m_axi_awlen   ,
	output wire [  2 : 0] m_axi_awsize  ,//output wire [  2 : 0] m_axi_awsize  ,
	output wire [  1 : 0] m_axi_awburst ,//output wire [  1 : 0] m_axi_awburst ,
	output wire [  2 : 0] m_axi_awprot  ,//output wire [  2 : 0] m_axi_awprot  ,
	output wire           m_axi_awvalid ,//output wire           m_axi_awvalid ,
	output wire           m_axi_awlock  ,//output wire           m_axi_awlock  ,
	output wire [  3 : 0] m_axi_awcache ,//output wire [  3 : 0] m_axi_awcache ,
	output wire [511 : 0] m_axi_wdata   ,//output wire [511 : 0] m_axi_wdata   ,
	output wire [ 63 : 0] m_axi_wstrb   ,//output wire [ 63 : 0] m_axi_wstrb   ,
	output wire           m_axi_wlast   ,//output wire           m_axi_wlast   ,
	output wire           m_axi_wvalid  ,//output wire           m_axi_wvalid  ,
	output wire           m_axi_bready  ,//output wire           m_axi_bready  ,
	output wire [  3 : 0] m_axi_arid    ,//output wire [  3 : 0] m_axi_arid    ,
	output wire [ 63 : 0] m_axi_araddr  ,//output wire [ 63 : 0] m_axi_araddr  ,
	output wire [  7 : 0] m_axi_arlen   ,//output wire [  7 : 0] m_axi_arlen   ,
	output wire [  2 : 0] m_axi_arsize  ,//output wire [  2 : 0] m_axi_arsize  ,
	output wire [  1 : 0] m_axi_arburst ,//output wire [  1 : 0] m_axi_arburst ,
	output wire [  2 : 0] m_axi_arprot  ,//output wire [  2 : 0] m_axi_arprot  ,
	output wire           m_axi_arvalid ,//output wire           m_axi_arvalid ,
	output wire           m_axi_arlock  ,//output wire           m_axi_arlock  ,
	output wire [  3 : 0] m_axi_arcache ,//output wire [  3 : 0] m_axi_arcache ,
	output wire           m_axi_rready  ,//output wire           m_axi_rready  ,
	output wire [ 31 : 0] m_axil_awaddr ,//output wire [ 31 : 0] m_axil_awaddr ,
	output wire [  2 : 0] m_axil_awprot ,//output wire [  2 : 0] m_axil_awprot ,
	output wire           m_axil_awvalid,//output wire           m_axil_awvalid,
	input  wire           m_axil_awready,//input  wire           m_axil_awready,
	output wire [ 31 : 0] m_axil_wdata  ,//output wire [ 31 : 0] m_axil_wdata  ,
	output wire [  3 : 0] m_axil_wstrb  ,//output wire [  3 : 0] m_axil_wstrb  ,
	output wire           m_axil_wvalid ,//output wire           m_axil_wvalid ,
	input  wire           m_axil_wready ,//input  wire           m_axil_wready ,
	input  wire           m_axil_bvalid ,//input  wire           m_axil_bvalid ,
	input  wire [  1 : 0] m_axil_bresp  ,//input  wire [  1 : 0] m_axil_bresp  ,
	output wire           m_axil_bready ,//output wire           m_axil_bready ,
	output wire [ 31 : 0] m_axil_araddr ,//output wire [ 31 : 0] m_axil_araddr ,
	output wire [  2 : 0] m_axil_arprot ,//output wire [  2 : 0] m_axil_arprot ,
	output wire           m_axil_arvalid,//output wire           m_axil_arvalid,
	input  wire           m_axil_arready,//input  wire           m_axil_arready,
	input  wire [ 31 : 0] m_axil_rdata  ,//input  wire [ 31 : 0] m_axil_rdata  ,
	input  wire [  1 : 0] m_axil_rresp  ,//input  wire [  1 : 0] m_axil_rresp  ,
	input  wire           m_axil_rvalid ,//input  wire           m_axil_rvalid ,
	output wire           m_axil_rready ,//output wire           m_axil_rready 

    input  wire           i2c_scl_i     , //input  wire           i2c_scl_i,
    output wire           i2c_scl_o     , //output wire           i2c_scl_o,
    output wire           i2c_scl_t     , //output wire           i2c_scl_t,
    input  wire           i2c_sda_i     , //input  wire           i2c_sda_i,
    output wire           i2c_sda_o     , //output wire           i2c_sda_o,
    output wire           i2c_sda_t       //output wire           i2c_sda_t
);
wire sys_clk = axi_aclk;
wire rst_n   = axi_aresetn;

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
	.m_axi_awready        (m_axi_awready        ),// input  wire m_axi_awready
	.m_axi_wready         (m_axi_wready         ),// input  wire m_axi_wready
	.m_axi_bid            (m_axi_bid            ),// input  wire [3 : 0] m_axi_bid
	.m_axi_bresp          (m_axi_bresp          ),// input  wire [1 : 0] m_axi_bresp
	.m_axi_bvalid         (m_axi_bvalid         ),// input  wire m_axi_bvalid
	.m_axi_arready        (m_axi_arready        ),// input  wire m_axi_arready
	.m_axi_rid            (m_axi_rid            ),// input  wire [3 : 0] m_axi_rid
	.m_axi_rdata          (m_axi_rdata          ),// input  wire [511 : 0] m_axi_rdata
	.m_axi_rresp          (m_axi_rresp          ),// input  wire [1 : 0] m_axi_rresp
	.m_axi_rlast          (m_axi_rlast          ),// input  wire m_axi_rlast
	.m_axi_rvalid         (m_axi_rvalid         ),// input  wire m_axi_rvalid
	.m_axi_awid           (m_axi_awid           ),// output wire [3 : 0] m_axi_awid
	.m_axi_awaddr         (m_axi_awaddr         ),// output wire [63 : 0] m_axi_awaddr
	.m_axi_awlen          (m_axi_awlen          ),// output wire [7 : 0] m_axi_awlen
	.m_axi_awsize         (m_axi_awsize         ),// output wire [2 : 0] m_axi_awsize
	.m_axi_awburst        (m_axi_awburst        ),// output wire [1 : 0] m_axi_awburst
	.m_axi_awprot         (m_axi_awprot         ),// output wire [2 : 0] m_axi_awprot
	.m_axi_awvalid        (m_axi_awvalid        ),// output wire m_axi_awvalid
	.m_axi_awlock         (m_axi_awlock         ),// output wire m_axi_awlock
	.m_axi_awcache        (m_axi_awcache        ),// output wire [3 : 0] m_axi_awcache
	.m_axi_wdata          (m_axi_wdata          ),// output wire [511 : 0] m_axi_wdata
	.m_axi_wstrb          (m_axi_wstrb          ),// output wire [63 : 0] m_axi_wstrb
	.m_axi_wlast          (m_axi_wlast          ),// output wire m_axi_wlast
	.m_axi_wvalid         (m_axi_wvalid         ),// output wire m_axi_wvalid
	.m_axi_bready         (m_axi_bready         ),// output wire m_axi_bready
	.m_axi_arid           (m_axi_arid           ),// output wire [3 : 0] m_axi_arid
	.m_axi_araddr         (m_axi_araddr         ),// output wire [63 : 0] m_axi_araddr
	.m_axi_arlen          (m_axi_arlen          ),// output wire [7 : 0] m_axi_arlen
	.m_axi_arsize         (m_axi_arsize         ),// output wire [2 : 0] m_axi_arsize
	.m_axi_arburst        (m_axi_arburst        ),// output wire [1 : 0] m_axi_arburst
	.m_axi_arprot         (m_axi_arprot         ),// output wire [2 : 0] m_axi_arprot
	.m_axi_arvalid        (m_axi_arvalid        ),// output wire m_axi_arvalid
	.m_axi_arlock         (m_axi_arlock         ),// output wire m_axi_arlock
	.m_axi_arcache        (m_axi_arcache        ),// output wire [3 : 0] m_axi_arcache
	.m_axi_rready         (m_axi_rready         ),// output wire m_axi_rready
	.m_axil_awaddr        (  axil_awaddr        ),// output wire [31 : 0] m_axil_awaddr
	.m_axil_awprot        (  axil_awprot        ),// output wire [2 : 0] m_axil_awprot
	.m_axil_awvalid       (  axil_awvalid       ),// output wire m_axil_awvalid
	.m_axil_awready       (  axil_awready       ),// input  wire m_axil_awready
	.m_axil_wdata         (  axil_wdata         ),// output wire [31 : 0] m_axil_wdata
	.m_axil_wstrb         (  axil_wstrb         ),// output wire [3 : 0] m_axil_wstrb
	.m_axil_wvalid        (  axil_wvalid        ),// output wire m_axil_wvalid
	.m_axil_wready        (  axil_wready        ),// input  wire m_axil_wready
	.m_axil_bvalid        (  axil_bvalid        ),// input  wire m_axil_bvalid
	.m_axil_bresp         (  axil_bresp         ),// input  wire [1 : 0] m_axil_bresp
	.m_axil_bready        (  axil_bready        ),// output wire m_axil_bready
	.m_axil_araddr        (  axil_araddr        ),// output wire [31 : 0] m_axil_araddr
	.m_axil_arprot        (  axil_arprot        ),// output wire [2 : 0] m_axil_arprot
	.m_axil_arvalid       (  axil_arvalid       ),// output wire m_axil_arvalid
	.m_axil_arready       (  axil_arready       ),// input  wire m_axil_arready
	.m_axil_rdata         (  axil_rdata         ),// input  wire [31 : 0] m_axil_rdata
	.m_axil_rresp         (  axil_rresp         ),// input  wire [1 : 0] m_axil_rresp
	.m_axil_rvalid        (  axil_rvalid        ),// input  wire m_axil_rvalid
	.m_axil_rready        (  axil_rready        ),// output wire m_axil_rready
	.mcap_design_switch   (                     ),// output wire mcap_design_switch
	.cap_req              (                     ),// output wire cap_req
	.cap_gnt              (1'b1                 ),// input  wire cap_gnt
	.cap_rel              (1'b0                 ) // input  wire cap_rel
);
//==========================================================================================================
//2. AXI bus mux
/* design by masw@masw.tech 
                                                                                                        
                   +--------+   +--------+                                                              
                   |        |   |        |                                                              
               +-->| M_AXI  |-->| OUTPUT |       
   +--------+  |   |        |   |        |       
   |        |  |   +--------+   +--------+       
   |  XDMA  |--+                                          +-------------+
   |        |  |                                 +---M00->|module output|-------> 512kB
   +--------+  |   +--------+   +--------+       |        +-------------+
               |   |        |   | bridge |       |        +-------------+                                                        
               +-->| M_AXIL |-->|        |-------+---M01->|AXIL to QPSI |(64kB)-------> QSPI在线更新                                                       
                   |        |   | 1 to 4 |       |        +-------------+                                                        
                   +--------+   +--------+       |        +-------------+                                                                             
                                                 +---M02->|AXIL to I2C  |(64kB)--------> i2c/Mbus板子电源控制
                                                 |        +-------------+                      
                                                 |        +-------------+              +-------------+                                                                    
                                                 +---M03->|AXIL to WB   |(64kB)------->| WB reg_list |   寄存器配置列表(控制暖重启(reboot)) 
                                                          +-------------+              +-------------+                                                                    
*/
localparam ADDR_WIDTH = 32; 
localparam DATA_WIDTH = 32;
localparam STRB_WIDTH =  4;


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

wire [ADDR_WIDTH-1:0]    m02_axil_awaddr    ;
wire [2:0]               m02_axil_awprot    ;
wire                     m02_axil_awvalid   ;
wire                     m02_axil_awready   ;
wire [DATA_WIDTH-1:0]    m02_axil_wdata     ;
wire [STRB_WIDTH-1:0]    m02_axil_wstrb     ;
wire                     m02_axil_wvalid    ;
wire                     m02_axil_wready    ;
wire [1:0]               m02_axil_bresp     ;
wire                     m02_axil_bvalid    ;
wire                     m02_axil_bready    ;
wire [ADDR_WIDTH-1:0]    m02_axil_araddr    ;
wire [2:0]               m02_axil_arprot    ;
wire                     m02_axil_arvalid   ;
wire                     m02_axil_arready   ;
wire [DATA_WIDTH-1:0]    m02_axil_rdata     ;
wire [1:0]               m02_axil_rresp     ;
wire                     m02_axil_rvalid    ;
wire                     m02_axil_rready    ;

wire [ADDR_WIDTH-1:0]    m03_axil_awaddr    ;
wire [2:0]               m03_axil_awprot    ;
wire                     m03_axil_awvalid   ;
wire                     m03_axil_awready   ;
wire [DATA_WIDTH-1:0]    m03_axil_wdata     ;
wire [STRB_WIDTH-1:0]    m03_axil_wstrb     ;
wire                     m03_axil_wvalid    ;
wire                     m03_axil_wready    ;
wire [1:0]               m03_axil_bresp     ;
wire                     m03_axil_bvalid    ;
wire                     m03_axil_bready    ;
wire [ADDR_WIDTH-1:0]    m03_axil_araddr    ;
wire [2:0]               m03_axil_arprot    ;
wire                     m03_axil_arvalid   ;
wire                     m03_axil_arready   ;
wire [DATA_WIDTH-1:0]    m03_axil_rdata     ;
wire [1:0]               m03_axil_rresp     ;
wire                     m03_axil_rvalid    ;
wire                     m03_axil_rready    ;

axil_interconnect_wrap_1x4 # (
    .DATA_WIDTH           ( 32                  ),
    .ADDR_WIDTH           ( 16                  ),
    .STRB_WIDTH           ( (DATA_WIDTH/8)      ),
    .M_REGIONS            ( 1                   ),
    .M00_BASE_ADDR        ( 0                   ),
    .M00_ADDR_WIDTH       ( {M_REGIONS{32'd19}} ),//512KB
    .M00_CONNECT_READ     ( 1'b1                ),
    .M00_CONNECT_WRITE    ( 1'b1                ),
    .M00_SECURE           ( 1'b0                ),
    .M01_BASE_ADDR        ( 0                   ),
    .M01_ADDR_WIDTH       ( {M_REGIONS{32'd16}} ),//64kB
    .M01_CONNECT_READ     ( 1'b1                ),
    .M01_CONNECT_WRITE    ( 1'b1                ),
    .M01_SECURE           ( 1'b0                ),
    .M02_BASE_ADDR        ( 0                   ),
    .M02_ADDR_WIDTH       ( {M_REGIONS{32'd16}} ),//64kB
    .M02_CONNECT_READ     ( 1'b1                ),
    .M02_CONNECT_WRITE    ( 1'b1                ),
    .M02_SECURE           ( 1'b0                ),
    .M03_BASE_ADDR        ( 0                   ),
    .M03_ADDR_WIDTH       ( {M_REGIONS{32'd16}} ),//64kB
    .M03_CONNECT_READ     ( 1'b1                ),
    .M03_CONNECT_WRITE    ( 1'b1                ),
    .M03_SECURE           ( 1'b0                )
)axil_interconnect_wrap_1x3_inst (
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

    .m00_axil_awaddr      (m_axil_awaddr        ),//output wire [ 31 : 0] m_axil_awaddr   <--> output wire [ADDR_WIDTH-1:0]    m00_axil_awaddr,
    .m00_axil_awprot      (m_axil_awprot        ),//output wire [  2 : 0] m_axil_awprot   <--> output wire [2:0]               m00_axil_awprot,
    .m00_axil_awvalid     (m_axil_awvalid       ),//output wire           m_axil_awvalid  <--> output wire                     m00_axil_awvalid,
    .m00_axil_awready     (m_axil_awready       ),//input  wire           m_axil_awready  <--> input  wire                     m00_axil_awready,
    .m00_axil_wdata       (m_axil_wdata         ),//output wire [ 31 : 0] m_axil_wdata    <--> output wire [DATA_WIDTH-1:0]    m00_axil_wdata,
    .m00_axil_wstrb       (m_axil_wstrb         ),//output wire [  3 : 0] m_axil_wstrb    <--> output wire [STRB_WIDTH-1:0]    m00_axil_wstrb,
    .m00_axil_wvalid      (m_axil_wvalid        ),//output wire           m_axil_wvalid   <--> output wire                     m00_axil_wvalid,
    .m00_axil_wready      (m_axil_wready        ),//input  wire           m_axil_wready   <--> input  wire                     m00_axil_wready,
    .m00_axil_bresp       (m_axil_bresp         ),//input  wire [  1 : 0] m_axil_bresp    <--> input  wire [1:0]               m00_axil_bresp,
    .m00_axil_bvalid      (m_axil_bvalid        ),//input  wire           m_axil_bvalid   <--> input  wire                     m00_axil_bvalid,
    .m00_axil_bready      (m_axil_bready        ),//output wire           m_axil_bready   <--> output wire                     m00_axil_bready,
    .m00_axil_araddr      (m_axil_araddr        ),//output wire [ 31 : 0] m_axil_araddr   <--> output wire [ADDR_WIDTH-1:0]    m00_axil_araddr,
    .m00_axil_arprot      (m_axil_arprot        ),//output wire [  2 : 0] m_axil_arprot   <--> output wire [2:0]               m00_axil_arprot,
    .m00_axil_arvalid     (m_axil_arvalid       ),//output wire           m_axil_arvalid  <--> output wire                     m00_axil_arvalid,
    .m00_axil_arready     (m_axil_arready       ),//input  wire           m_axil_arready  <--> input  wire                     m00_axil_arready,
    .m00_axil_rdata       (m_axil_rdata         ),//input  wire [ 31 : 0] m_axil_rdata    <--> input  wire [DATA_WIDTH-1:0]    m00_axil_rdata,
    .m00_axil_rresp       (m_axil_rresp         ),//input  wire [  1 : 0] m_axil_rresp    <--> input  wire [1:0]               m00_axil_rresp,
    .m00_axil_rvalid      (m_axil_rvalid        ),//input  wire           m_axil_rvalid   <--> input  wire                     m00_axil_rvalid,
    .m00_axil_rready      (m_axil_rready        ),//output wire           m_axil_rready   <--> output wire                     m00_axil_rready,

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
                                                
    .m02_axil_awaddr      (m02_axil_awaddr      ),//output wire [ADDR_WIDTH-1:0]    m02_axil_awaddr,
    .m02_axil_awprot      (m02_axil_awprot      ),//output wire [2:0]               m02_axil_awprot,
    .m02_axil_awvalid     (m02_axil_awvalid     ),//output wire                     m02_axil_awvalid,
    .m02_axil_awready     (m02_axil_awready     ),//input  wire                     m02_axil_awready,
    .m02_axil_wdata       (m02_axil_wdata       ),//output wire [DATA_WIDTH-1:0]    m02_axil_wdata,
    .m02_axil_wstrb       (m02_axil_wstrb       ),//output wire [STRB_WIDTH-1:0]    m02_axil_wstrb,
    .m02_axil_wvalid      (m02_axil_wvalid      ),//output wire                     m02_axil_wvalid,
    .m02_axil_wready      (m02_axil_wready      ),//input  wire                     m02_axil_wready,
    .m02_axil_bresp       (m02_axil_bresp       ),//input  wire [1:0]               m02_axil_bresp,
    .m02_axil_bvalid      (m02_axil_bvalid      ),//input  wire                     m02_axil_bvalid,
    .m02_axil_bready      (m02_axil_bready      ),//output wire                     m02_axil_bready,
    .m02_axil_araddr      (m02_axil_araddr      ),//output wire [ADDR_WIDTH-1:0]    m02_axil_araddr,
    .m02_axil_arprot      (m02_axil_arprot      ),//output wire [2:0]               m02_axil_arprot,
    .m02_axil_arvalid     (m02_axil_arvalid     ),//output wire                     m02_axil_arvalid,
    .m02_axil_arready     (m02_axil_arready     ),//input  wire                     m02_axil_arready,
    .m02_axil_rdata       (m02_axil_rdata       ),//input  wire [DATA_WIDTH-1:0]    m02_axil_rdata,
    .m02_axil_rresp       (m02_axil_rresp       ),//input  wire [1:0]               m02_axil_rresp,
    .m02_axil_rvalid      (m02_axil_rvalid      ),//input  wire                     m02_axil_rvalid,
    .m02_axil_rready      (m02_axil_rready      ) //output wire                     m02_axil_rready
                                                
    .m03_axil_awaddr      (m03_axil_awaddr      ),//output wire [ADDR_WIDTH-1:0]    m03_axil_awaddr,
    .m03_axil_awprot      (m03_axil_awprot      ),//output wire [2:0]               m03_axil_awprot,
    .m03_axil_awvalid     (m03_axil_awvalid     ),//output wire                     m03_axil_awvalid,
    .m03_axil_awready     (m03_axil_awready     ),//input  wire                     m03_axil_awready,
    .m03_axil_wdata       (m03_axil_wdata       ),//output wire [DATA_WIDTH-1:0]    m03_axil_wdata,
    .m03_axil_wstrb       (m03_axil_wstrb       ),//output wire [STRB_WIDTH-1:0]    m03_axil_wstrb,
    .m03_axil_wvalid      (m03_axil_wvalid      ),//output wire                     m03_axil_wvalid,
    .m03_axil_wready      (m03_axil_wready      ),//input  wire                     m03_axil_wready,
    .m03_axil_bresp       (m03_axil_bresp       ),//input  wire [1:0]               m03_axil_bresp,
    .m03_axil_bvalid      (m03_axil_bvalid      ),//input  wire                     m03_axil_bvalid,
    .m03_axil_bready      (m03_axil_bready      ),//output wire                     m03_axil_bready,
    .m03_axil_araddr      (m03_axil_araddr      ),//output wire [ADDR_WIDTH-1:0]    m03_axil_araddr,
    .m03_axil_arprot      (m03_axil_arprot      ),//output wire [2:0]               m03_axil_arprot,
    .m03_axil_arvalid     (m03_axil_arvalid     ),//output wire                     m03_axil_arvalid,
    .m03_axil_arready     (m03_axil_arready     ),//input  wire                     m03_axil_arready,
    .m03_axil_rdata       (m03_axil_rdata       ),//input  wire [DATA_WIDTH-1:0]    m03_axil_rdata,
    .m03_axil_rresp       (m03_axil_rresp       ),//input  wire [1:0]               m03_axil_rresp,
    .m03_axil_rvalid      (m03_axil_rvalid      ),//input  wire                     m03_axil_rvalid,
    .m03_axil_rready      (m03_axil_rready      ) //output wire                     m03_axil_rready
);





//==========================================================================================================
//3. fpga boot

// reboot from QSPI flash, 仅仅适用于VU/VUP系列 
fpga_reboot fpga_reboot_inst(
	.sys_clk  (sys_clk  ),//i1,
	.rst_n    (rst_n    ),//i1, 
	.reboot   (reboot   ) //i1,
);

//==========================================================================================================
//4. qspi flash 
wire cfgclk      ;
wire cfgmclk     ;
wire eos         ;
wire preq        ;
wire gsr         ;
wire gts         ;
wire keyclearb   ;
wire usrcclkts   ;
wire usrdoneo    ;
wire usrdonets   ;
wire ip2intc_irpt;

axi_quad_spi_0 axi_quad_spi_0_inst(
    .ext_spi_clk         (clk_50M              ), // input  wire ext_spi_clk
    .s_axi_aclk          (  axi_aclk           ), // input  wire s_axi_aclk
    .s_axi_aresetn       (  axi_aresetn        ), // input  wire s_axi_aresetn
    .s_axi_awaddr        (m01_axil_awaddr      ), //output wire [ADDR_WIDTH-1:0]    m01_axil_awaddr,          input  wire [6 : 0] s_axi_awaddr
                                                  //output wire [2:0]               m01_axil_awprot,          
    .s_axi_awvalid       (m01_axil_awvalid     ), //output wire                     m01_axil_awvalid,         input  wire s_axi_awvalid
    .s_axi_awready       (m01_axil_awready     ), //input  wire                     m01_axil_awready,         output wire s_axi_awready
    .s_axi_wdata         (m01_axil_wdata       ), //output wire [DATA_WIDTH-1:0]    m01_axil_wdata,           input  wire [31 : 0] s_axi_wdata
    .s_axi_wstrb         (m01_axil_wstrb       ), //output wire [STRB_WIDTH-1:0]    m01_axil_wstrb,           input  wire [3 : 0] s_axi_wstrb
    .s_axi_wvalid        (m01_axil_wvalid      ), //output wire                     m01_axil_wvalid,          input  wire s_axi_wvalid
    .s_axi_wready        (m01_axil_wready      ), //input  wire                     m01_axil_wready,          output wire s_axi_wready
    .s_axi_bresp         (m01_axil_bresp       ), //input  wire [1:0]               m01_axil_bresp,           output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid        (m01_axil_bvalid      ), //input  wire                     m01_axil_bvalid,          output wire s_axi_bvalid
    .s_axi_bready        (m01_axil_bready      ), //output wire                     m01_axil_bready,          input  wire s_axi_bready
    .s_axi_araddr        (m01_axil_araddr      ), //output wire [ADDR_WIDTH-1:0]    m01_axil_araddr,          input  wire [6 : 0] s_axi_araddr
                                                  //output wire [2:0]               m01_axil_arprot,          
    .s_axi_arvalid       (m01_axil_arvalid     ), //output wire                     m01_axil_arvalid,         input  wire s_axi_arvalid
    .s_axi_arready       (m01_axil_arready     ), //input  wire                     m01_axil_arready,         output wire s_axi_arready
    .s_axi_rdata         (m01_axil_rdata       ), //input  wire [DATA_WIDTH-1:0]    m01_axil_rdata,           output wire [31 : 0] s_axi_rdata
    .s_axi_rresp         (m01_axil_rresp       ), //input  wire [1:0]               m01_axil_rresp,           output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid        (m01_axil_rvalid      ), //input  wire                     m01_axil_rvalid,          output wire s_axi_rvalid
    .s_axi_rready        (m01_axil_rready      ), //output wire                     m01_axil_rready,          input  wire s_axi_rready

    .cfgclk              (                     ), // output wire cfgclk
    .cfgmclk             (                     ), // output wire cfgmclk
    .eos                 (                     ), // output wire eos
    .preq                (                     ), // output wire preq
    .gsr                 (1'b0                 ), // input  wire gsr
    .gts                 (1'b0                 ), // input  wire gts
    .keyclearb           (1'b1                 ), // input  wire keyclearb
    .usrcclkts           (1'b0                 ), // input  wire usrcclkts
    .usrdoneo            (1'b0                 ), // input  wire usrdoneo
    .usrdonets           (1'b1                 ), // input  wire usrdonets
    .ip2intc_irpt        (                     )  // output wire ip2intc_irpt
);



//==========================================================================================================
//5.  AXIL to I2c, 用于板子电源控制
i2c_master_axil # (
    .DEFAULT_PRESCALE  ( 1               ),
    .FIXED_PRESCALE    ( 0               ),
    .CMD_FIFO          ( 1               ),
    .CMD_FIFO_DEPTH    ( 32              ),
    .WRITE_FIFO        ( 1               ),
    .WRITE_FIFO_DEPTH  ( 32              ),
    .READ_FIFO         ( 1               ),
    .READ_FIFO_DEPTH   ( 32              ) 
)i2c_master_axil_inst (
    .clk               ( axi_aclk        ),
    .rst               (~axi_aresetn     ),

    .s_axil_awaddr     (m02_axil_awaddr  ),//output wire [ADDR_WIDTH-1:0]    m02_axil_awaddr,  <---> input  wire [3:0]  s_axil_awaddr,
    .s_axil_awprot     (m02_axil_awprot  ),//output wire [2:0]               m02_axil_awprot,  <---> input  wire [2:0]  s_axil_awprot,
    .s_axil_awvalid    (m02_axil_awvalid ),//output wire                     m02_axil_awvalid, <---> input  wire        s_axil_awvalid,
    .s_axil_awready    (m02_axil_awready ),//input  wire                     m02_axil_awready, <---> output wire        s_axil_awready,
    .s_axil_wdata      (m02_axil_wdata   ),//output wire [DATA_WIDTH-1:0]    m02_axil_wdata,   <---> input  wire [31:0] s_axil_wdata,
    .s_axil_wstrb      (m02_axil_wstrb   ),//output wire [STRB_WIDTH-1:0]    m02_axil_wstrb,   <---> input  wire [3:0]  s_axil_wstrb,
    .s_axil_wvalid     (m02_axil_wvalid  ),//output wire                     m02_axil_wvalid,  <---> input  wire        s_axil_wvalid,
    .s_axil_wready     (m02_axil_wready  ),//input  wire                     m02_axil_wready,  <---> output wire        s_axil_wready,
    .s_axil_bresp      (m02_axil_bresp   ),//input  wire [1:0]               m02_axil_bresp,   <---> output wire [1:0]  s_axil_bresp,
    .s_axil_bvalid     (m02_axil_bvalid  ),//input  wire                     m02_axil_bvalid,  <---> output wire        s_axil_bvalid,
    .s_axil_bready     (m02_axil_bready  ),//output wire                     m02_axil_bready,  <---> input  wire        s_axil_bready,
    .s_axil_araddr     (m02_axil_araddr  ),//output wire [ADDR_WIDTH-1:0]    m02_axil_araddr,  <---> input  wire [3:0]  s_axil_araddr,
    .s_axil_arprot     (m02_axil_arprot  ),//output wire [2:0]               m02_axil_arprot,  <---> input  wire [2:0]  s_axil_arprot,
    .s_axil_arvalid    (m02_axil_arvalid ),//output wire                     m02_axil_arvalid, <---> input  wire        s_axil_arvalid,
    .s_axil_arready    (m02_axil_arready ),//input  wire                     m02_axil_arready, <---> output wire        s_axil_arready,
    .s_axil_rdata      (m02_axil_rdata   ),//input  wire [DATA_WIDTH-1:0]    m02_axil_rdata,   <---> output wire [31:0] s_axil_rdata,
    .s_axil_rresp      (m02_axil_rresp   ),//input  wire [1:0]               m02_axil_rresp,   <---> output wire [1:0]  s_axil_rresp,
    .s_axil_rvalid     (m02_axil_rvalid  ),//input  wire                     m02_axil_rvalid,  <---> output wire        s_axil_rvalid,
    .s_axil_rready     (m02_axil_rready  ),//output wire                     m02_axil_rready   <---> input  wire        s_axil_rready,

    .i2c_scl_i         (i2c_scl_i        ),
    .i2c_scl_o         (i2c_scl_o        ),
    .i2c_scl_t         (i2c_scl_t        ),
    .i2c_sda_i         (i2c_sda_i        ),
    .i2c_sda_o         (i2c_sda_o        ),
    .i2c_sda_t         (i2c_sda_t        )
);


//========================================================================================================
//6. 寄存器控制总线
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

    .s_axil_awaddr    (m03_axil_awaddr    ),//output wire [ADDR_WIDTH-1:0]    m03_axil_awaddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    .s_axil_awprot    (m03_axil_awprot    ),//output wire [2:0]               m03_axil_awprot,   <--> input  wire [2:0]             s_axil_awprot,
    .s_axil_awvalid   (m03_axil_awvalid   ),//output wire                     m03_axil_awvalid,  <--> input  wire                   s_axil_awvalid,
    .s_axil_awready   (m03_axil_awready   ),//input  wire                     m03_axil_awready,  <--> output wire                   s_axil_awready,
    .s_axil_wdata     (m03_axil_wdata     ),//output wire [DATA_WIDTH-1:0]    m03_axil_wdata,    <--> input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    .s_axil_wstrb     (m03_axil_wstrb     ),//output wire [STRB_WIDTH-1:0]    m03_axil_wstrb,    <--> input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    .s_axil_wvalid    (m03_axil_wvalid    ),//output wire                     m03_axil_wvalid,   <--> input  wire                   s_axil_wvalid,
    .s_axil_wready    (m03_axil_wready    ),//input  wire                     m03_axil_wready,   <--> output wire                   s_axil_wready,
    .s_axil_bresp     (m03_axil_bresp     ),//input  wire [1:0]               m03_axil_bresp,    <--> output wire [1:0]             s_axil_bresp,
    .s_axil_bvalid    (m03_axil_bvalid    ),//input  wire                     m03_axil_bvalid,   <--> output wire                   s_axil_bvalid,
    .s_axil_bready    (m03_axil_bready    ),//output wire                     m03_axil_bready,   <--> input  wire                   s_axil_bready,
    .s_axil_araddr    (m03_axil_araddr    ),//output wire [ADDR_WIDTH-1:0]    m03_axil_araddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    .s_axil_arprot    (m03_axil_arprot    ),//output wire [2:0]               m03_axil_arprot,   <--> input  wire [2:0]             s_axil_arprot,
    .s_axil_arvalid   (m03_axil_arvalid   ),//output wire                     m03_axil_arvalid,  <--> input  wire                   s_axil_arvalid,
    .s_axil_arready   (m03_axil_arready   ),//input  wire                     m03_axil_arready,  <--> output wire                   s_axil_arready,
    .s_axil_rdata     (m03_axil_rdata     ),//input  wire [DATA_WIDTH-1:0]    m03_axil_rdata,    <--> output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    .s_axil_rresp     (m03_axil_rresp     ),//input  wire [1:0]               m03_axil_rresp,    <--> output wire [1:0]             s_axil_rresp,
    .s_axil_rvalid    (m03_axil_rvalid    ),//input  wire                     m03_axil_rvalid,   <--> output wire                   s_axil_rvalid,
    .s_axil_rready    (m03_axil_rready    ),//output wire                     m03_axil_rready    <--> input  wire                   s_axil_rready,

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

reg  fpga_reboot_reg;
reg [7:0] led_reg ;
//写入
always @ (posedge sys_clk or negedge rst_n)
	if(!rst_n)
	begin
		fpga_reboot_reg <= 1'd0;
		led_reg         <= 8'd0;
	end
	else if(reg_wr_en)
	begin
		case(reg_wr_addr[3:2],2'b00)
			4'h0: begin
				if(reg_wr_strb[0]) 
					fpga_reboot_reg <= reg_wr_data[0];
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
			4'h0: reg_rd_data <= {31'd0, fpga_reboot_reg};
		endcase
	end

















endmodule

