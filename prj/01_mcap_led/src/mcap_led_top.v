//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月03日 星期五 22时55分44秒
//========================================================================



module mcap_led_top(
    input  [ 0:0] clk_100M_p     ,	
    input  [ 0:0] clk_100M_n     ,
	input  [ 0:0] pcie_ref_clk_p ,
	input  [ 0:0] pcie_ref_clk_n ,
	input  [15:0] pcie_lane_rxp  ,
	input  [15:0] pcie_lane_rxn  ,
	output [15:0] pcie_lane_txp  ,
	output [15:0] pcie_lane_txn  ,
	input         pcie_perst_n   ,
	output        pcie_link_up   ,
	inout         main_i2c_scl   ,
	inout         main_i2c_sda   ,
	output [ 7:0] LED 
);
//==========================================================================================================
//0. 本地时钟100M
wire clk_100M_in;
wire clk_100M   ;
wire clk_50M    ;// for QSPI
IBUFDS IBUFDS_inst  (.O(clk_100M_in), .I(clk_100M_p ), .IB(clk_100M_n));
BUFG   BUFG_100_inst(.O(clk_100M   ), .I(clk_100M_in)                 );
BUFGCE_DIV #(.BUFGCE_DIVIDE(2)) BUFGCE_DIV_inst(
	.O  (clk_50M ),
	.CE (1'b1    ),
	.CLR(1'b0    ),
	.I  (clk_100M)
);


//==========================================================================================================
wire           axi_awready ;
wire           axi_wready  ;
wire [  3 : 0] axi_bid     ;
wire [  1 : 0] axi_bresp   ;
wire           axi_bvalid  ;
wire           axi_arready ;
wire [  3 : 0] axi_rid     ;
wire [511 : 0] axi_rdata   ;
wire [  1 : 0] axi_rresp   ;
wire           axi_rlast   ;
wire           axi_rvalid  ;
wire [  3 : 0] axi_awid    ;
wire [ 63 : 0] axi_awaddr  ;
wire [  7 : 0] axi_awlen   ;
wire [  2 : 0] axi_awsize  ;
wire [  1 : 0] axi_awburst ;
wire [  2 : 0] axi_awprot  ;
wire           axi_awvalid ;
wire           axi_awlock  ;
wire [  3 : 0] axi_awcache ;
wire [511 : 0] axi_wdata   ;
wire [ 63 : 0] axi_wstrb   ;
wire           axi_wlast   ;
wire           axi_wvalid  ;
wire           axi_bready  ;
wire [  3 : 0] axi_arid    ;
wire [ 63 : 0] axi_araddr  ;
wire [  7 : 0] axi_arlen   ;
wire [  2 : 0] axi_arsize  ;
wire [  1 : 0] axi_arburst ;
wire [  2 : 0] axi_arprot  ;
wire           axi_arvalid ;
wire           axi_arlock  ;
wire [  3 : 0] axi_arcache ;
wire           axi_rready  ;

wire [ 31 : 0] axil_awaddr ;
wire [  2 : 0] axil_awprot ;
wire           axil_awvalid;
wire           axil_awready;
wire [ 31 : 0] axil_wdata  ;
wire [  3 : 0] axil_wstrb  ;
wire           axil_wvalid ;
wire           axil_wready ;
wire           axil_bvalid ;
wire [  1 : 0] axil_bresp  ;
wire           axil_bready ;
wire [ 31 : 0] axil_araddr ;
wire [  2 : 0] axil_arprot ;
wire           axil_arvalid;
wire           axil_arready;
wire [ 31 : 0] axil_rdata  ;
wire [  1 : 0] axil_rresp  ;
wire           axil_rvalid ;
wire           axil_rready 

wire i2c_scl_i; 
wire i2c_scl_o;
wire i2c_scl_t;
wire i2c_sda_i;
wire i2c_sda_o;
wire i2c_sda_t;

//1. 本地时钟100M
xdma_mcap_qspi xdma_mcap_qspi_inst(
	.clk_50M        (clk_50M       ),
	.pcie_ref_clk_p (pcie_ref_clk_p),
	.pcie_ref_clk_n (pcie_ref_clk_n),
	.pcie_lane_rxp  (pcie_lane_rxp ),
	.pcie_lane_rxn  (pcie_lane_rxn ),
	.pcie_lane_txp  (pcie_lane_txp ),
	.pcie_lane_txn  (pcie_lane_txn ),
	.pcie_perst_n   (pcie_perst_n  ),
	.pcie_link_up   (pcie_link_up  ),
	//XDMA interface
	.axi_aclk       (axi_aclk       ),//output wire           axi_aclk      ,250M
	.axi_aresetn    (axi_aresetn    ),//output wire           axi_aresetn   ,
	.usr_irq_req    (8'd0           ),//input  wire [  7 : 0] usr_irq_req   ,
	.m_axi_awready  (  axi_awready  ),//input  wire           m_axi_awready ,
	.m_axi_wready   (  axi_wready   ),//input  wire           m_axi_wready  ,
	.m_axi_bid      (  axi_bid      ),//input  wire [  3 : 0] m_axi_bid     ,
	.m_axi_bresp    (  axi_bresp    ),//input  wire [  1 : 0] m_axi_bresp   ,
	.m_axi_bvalid   (  axi_bvalid   ),//input  wire           m_axi_bvalid  ,
	.m_axi_arready  (  axi_arready  ),//input  wire           m_axi_arready ,
	.m_axi_rid      (  axi_rid      ),//input  wire [  3 : 0] m_axi_rid     ,
	.m_axi_rdata    (  axi_rdata    ),//input  wire [511 : 0] m_axi_rdata   ,
	.m_axi_rresp    (  axi_rresp    ),//input  wire [  1 : 0] m_axi_rresp   ,
	.m_axi_rlast    (  axi_rlast    ),//input  wire           m_axi_rlast   ,
	.m_axi_rvalid   (  axi_rvalid   ),//input  wire           m_axi_rvalid  ,
	.m_axi_awid     (  axi_awid     ),//output wire [  3 : 0] m_axi_awid    ,
	.m_axi_awaddr   (  axi_awaddr   ),//output wire [ 63 : 0] m_axi_awaddr  ,
	.m_axi_awlen    (  axi_awlen    ),//output wire [  7 : 0] m_axi_awlen   ,
	.m_axi_awsize   (  axi_awsize   ),//output wire [  2 : 0] m_axi_awsize  ,
	.m_axi_awburst  (  axi_awburst  ),//output wire [  1 : 0] m_axi_awburst ,
	.m_axi_awprot   (  axi_awprot   ),//output wire [  2 : 0] m_axi_awprot  ,
	.m_axi_awvalid  (  axi_awvalid  ),//output wire           m_axi_awvalid ,
	.m_axi_awlock   (  axi_awlock   ),//output wire           m_axi_awlock  ,
	.m_axi_awcache  (  axi_awcache  ),//output wire [  3 : 0] m_axi_awcache ,
	.m_axi_wdata    (  axi_wdata    ),//output wire [511 : 0] m_axi_wdata   ,
	.m_axi_wstrb    (  axi_wstrb    ),//output wire [ 63 : 0] m_axi_wstrb   ,
	.m_axi_wlast    (  axi_wlast    ),//output wire           m_axi_wlast   ,
	.m_axi_wvalid   (  axi_wvalid   ),//output wire           m_axi_wvalid  ,
	.m_axi_bready   (  axi_bready   ),//output wire           m_axi_bready  ,
	.m_axi_arid     (  axi_arid     ),//output wire [  3 : 0] m_axi_arid    ,
	.m_axi_araddr   (  axi_araddr   ),//output wire [ 63 : 0] m_axi_araddr  ,
	.m_axi_arlen    (  axi_arlen    ),//output wire [  7 : 0] m_axi_arlen   ,
	.m_axi_arsize   (  axi_arsize   ),//output wire [  2 : 0] m_axi_arsize  ,
	.m_axi_arburst  (  axi_arburst  ),//output wire [  1 : 0] m_axi_arburst ,
	.m_axi_arprot   (  axi_arprot   ),//output wire [  2 : 0] m_axi_arprot  ,
	.m_axi_arvalid  (  axi_arvalid  ),//output wire           m_axi_arvalid ,
	.m_axi_arlock   (  axi_arlock   ),//output wire           m_axi_arlock  ,
	.m_axi_arcache  (  axi_arcache  ),//output wire [  3 : 0] m_axi_arcache ,
	.m_axi_rready   (  axi_rready   ),//output wire           m_axi_rready  ,
	.m_axil_awaddr  (  axil_awaddr  ),//output wire [ 31 : 0] m_axil_awaddr ,
	.m_axil_awprot  (  axil_awprot  ),//output wire [  2 : 0] m_axil_awprot ,
	.m_axil_awvalid (  axil_awvalid ),//output wire           m_axil_awvalid,
	.m_axil_awready (  axil_awready ),//input  wire           m_axil_awready,
	.m_axil_wdata   (  axil_wdata   ),//output wire [ 31 : 0] m_axil_wdata  ,
	.m_axil_wstrb   (  axil_wstrb   ),//output wire [  3 : 0] m_axil_wstrb  ,
	.m_axil_wvalid  (  axil_wvalid  ),//output wire           m_axil_wvalid ,
	.m_axil_wready  (  axil_wready  ),//input  wire           m_axil_wready ,
	.m_axil_bvalid  (  axil_bvalid  ),//input  wire           m_axil_bvalid ,
	.m_axil_bresp   (  axil_bresp   ),//input  wire [  1 : 0] m_axil_bresp  ,
	.m_axil_bready  (  axil_bready  ),//output wire           m_axil_bready ,
	.m_axil_araddr  (  axil_araddr  ),//output wire [ 31 : 0] m_axil_araddr ,
	.m_axil_arprot  (  axil_arprot  ),//output wire [  2 : 0] m_axil_arprot ,
	.m_axil_arvalid (  axil_arvalid ),//output wire           m_axil_arvalid,
	.m_axil_arready (  axil_arready ),//input  wire           m_axil_arready,
	.m_axil_rdata   (  axil_rdata   ),//input  wire [ 31 : 0] m_axil_rdata  ,
	.m_axil_rresp   (  axil_rresp   ),//input  wire [  1 : 0] m_axil_rresp  ,
	.m_axil_rvalid  (  axil_rvalid  ),//input  wire           m_axil_rvalid ,
	.m_axil_rready  (  axil_rready  ),//output wire           m_axil_rready 

    .i2c_scl_i      (  i2c_scl_i    ),//i1 
    .i2c_scl_o      (  i2c_scl_o    ),//o1
    .i2c_scl_t      (  i2c_scl_t    ),//o1
    .i2c_sda_i      (  i2c_sda_i    ),//i1
    .i2c_sda_o      (  i2c_sda_o    ),//o1
    .i2c_sda_t      (  i2c_sda_t    ) //o1 
);

IOBUF IOBUF_scl_inst (
	.O (i2c_scl_i    ),
	.I (i2c_scl_i    ),
	.IO(main_i2c_scl ),
	.T (i2c_scl_t    ) 
);
IOBUF IOBUF_sda_inst (
	.O (i2c_sda_i    ),
	.I (i2c_sda_i    ),
	.IO(main_i2c_sda ),
	.T (i2c_sda_t    )
);


//==========================================================================================================
//1. AXI BRAM
axi_ram # (
    .DATA_WIDTH      ( 512 ), 
    .ADDR_WIDTH      ( 16  ),
    .STRB_WIDTH      ( 64  ),
    .ID_WIDTH        ( 8   ),
    .PIPELINE_OUTPUT ( 0   )
)axi_ram_inst (
    .clk             ( axi_aclk     ),
    .rst             (~axi_aresetn  ),

    .s_axi_awid      (axi_awid      ),//input  wire [ID_WIDTH-1:0]    s_axi_awid,
    .s_axi_awaddr    (axi_awaddr    ),//input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    .s_axi_awlen     (axi_awlen     ),//input  wire [7:0]             s_axi_awlen,
    .s_axi_awsize    (axi_awsize    ),//input  wire [2:0]             s_axi_awsize,
    .s_axi_awburst   (axi_awburst   ),//input  wire [1:0]             s_axi_awburst,
    .s_axi_awlock    (axi_awlock    ),//input  wire                   s_axi_awlock,
    .s_axi_awcache   (axi_awcache   ),//input  wire [3:0]             s_axi_awcache,
    .s_axi_awprot    (axi_awprot    ),//input  wire [2:0]             s_axi_awprot,
    .s_axi_awvalid   (axi_awvalid   ),//input  wire                   s_axi_awvalid,
    .s_axi_awready   (axi_awready   ),//output wire                   s_axi_awready,
    .s_axi_wdata     (axi_wdata     ),//input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    .s_axi_wstrb     (axi_wstrb     ),//input  wire [STRB_WIDTH-1:0]  s_axi_wstrb,
    .s_axi_wlast     (axi_wlast     ),//input  wire                   s_axi_wlast,
    .s_axi_wvalid    (axi_wvalid    ),//input  wire                   s_axi_wvalid,
    .s_axi_wready    (axi_wready    ),//output wire                   s_axi_wready,
    .s_axi_bid       (axi_bid       ),//output wire [ID_WIDTH-1:0]    s_axi_bid,
    .s_axi_bresp     (axi_bresp     ),//output wire [1:0]             s_axi_bresp,
    .s_axi_bvalid    (axi_bvalid    ),//output wire                   s_axi_bvalid,
    .s_axi_bready    (axi_bready    ),//input  wire                   s_axi_bready,
    .s_axi_arid      (axi_arid      ),//input  wire [ID_WIDTH-1:0]    s_axi_arid,
    .s_axi_araddr    (axi_araddr    ),//input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    .s_axi_arlen     (axi_arlen     ),//input  wire [7:0]             s_axi_arlen,
    .s_axi_arsize    (axi_arsize    ),//input  wire [2:0]             s_axi_arsize,
    .s_axi_arburst   (axi_arburst   ),//input  wire [1:0]             s_axi_arburst,
    .s_axi_arlock    (axi_arlock    ),//input  wire                   s_axi_arlock,
    .s_axi_arcache   (axi_arcache   ),//input  wire [3:0]             s_axi_arcache,
    .s_axi_arprot    (axi_arprot    ),//input  wire [2:0]             s_axi_arprot,
    .s_axi_arvalid   (axi_arvalid   ),//input  wire                   s_axi_arvalid,
    .s_axi_arready   (axi_arready   ),//output wire                   s_axi_arready,
    .s_axi_rid       (axi_rid       ),//output wire [ID_WIDTH-1:0]    s_axi_rid,
    .s_axi_rdata     (axi_rdata     ),//output wire [DATA_WIDTH-1:0]  s_axi_rdata,
    .s_axi_rresp     (axi_rresp     ),//output wire [1:0]             s_axi_rresp,
    .s_axi_rlast     (axi_rlast     ),//output wire                   s_axi_rlast,
    .s_axi_rvalid    (axi_rvalid    ),//output wire                   s_axi_rvalid,
    .s_axi_rready    (axi_rready    ) //input  wire                   s_axi_rready
);


//==========================================================================================================
//2. AXIL BRAM

`ifdef USE_AXIL_RAM
tandem_app_bram tandem_app_inst (
    .axi_aclk        ( axi_aclk       ),
    .axi_aresetn     ( axi_aresetn    ),

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
    .s_axil_rready   (  axil_rready   ),//input  wire                   s_axil_rready
	.LED             (  LED           )
);
`else
tandem_app_led tandem_app_inst (
    .axi_aclk        ( axi_aclk       ),
    .axi_aresetn     ( axi_aresetn    ),

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
    .s_axil_rready   (  axil_rready   ),//input  wire                   s_axil_rready
	.LED             (  LED           )
);

`endif
endmodule


