//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年12月09日 星期六 21时32分20秒
//========================================================================


module example1_app_bram(
	input  [   0:0] pcie_ref_clk_p ,
	input  [   0:0] pcie_ref_clk_n ,
	input  [  15:0] pcie_lane_rxp  ,
	input  [  15:0] pcie_lane_rxn  ,
	output [  15:0] pcie_lane_txp  ,
	output [  15:0] pcie_lane_txn  ,
	input           pcie_perst_n   ,
	output          pcie_link_up   ,
	output [   7:0] LED
);

wire           axi_aclk         ;
wire           axi_aresetn      ;

wire           m_axi_awready    ;
wire           m_axi_wready     ;
wire [  3 : 0] m_axi_bid        ;
wire [  1 : 0] m_axi_bresp      ;
wire           m_axi_bvalid     ;
wire           m_axi_arready    ;
wire [  3 : 0] m_axi_rid        ;
wire [511 : 0] m_axi_rdata      ;
wire [  1 : 0] m_axi_rresp      ;
wire           m_axi_rlast      ;
wire           m_axi_rvalid     ;
wire [  3 : 0] m_axi_awid       ;
wire [ 63 : 0] m_axi_awaddr     ;
wire [  7 : 0] m_axi_awlen      ;
wire [  2 : 0] m_axi_awsize     ;
wire [  1 : 0] m_axi_awburst    ;
wire [  2 : 0] m_axi_awprot     ;
wire           m_axi_awvalid    ;
wire           m_axi_awlock     ;
wire [  3 : 0] m_axi_awcache    ;
wire [511 : 0] m_axi_wdata      ;
wire [ 63 : 0] m_axi_wstrb      ;
wire           m_axi_wlast      ;
wire           m_axi_wvalid     ;
wire           m_axi_bready     ;
wire [  3 : 0] m_axi_arid       ;
wire [ 63 : 0] m_axi_araddr     ;
wire [  7 : 0] m_axi_arlen      ;
wire [  2 : 0] m_axi_arsize     ;
wire [  1 : 0] m_axi_arburst    ;
wire [  2 : 0] m_axi_arprot     ;
wire           m_axi_arvalid    ;
wire           m_axi_arlock     ;
wire [  3 : 0] m_axi_arcache    ;
wire           m_axi_rready     ;

wire [ 31 : 0] m_axil_awaddr    ;
wire [  2 : 0] m_axil_awprot    ;
wire           m_axil_awvalid   ;
wire           m_axil_awready   ;
wire [ 31 : 0] m_axil_wdata     ;
wire [  3 : 0] m_axil_wstrb     ;
wire           m_axil_wvalid    ;
wire           m_axil_wready    ;
wire           m_axil_bvalid    ;
wire [  1 : 0] m_axil_bresp     ;
wire           m_axil_bready    ;
wire [ 31 : 0] m_axil_araddr    ;
wire [  2 : 0] m_axil_arprot    ;
wire           m_axil_arvalid   ;
wire           m_axil_arready   ;
wire [ 31 : 0] m_axil_rdata     ;
wire [  1 : 0] m_axil_rresp     ;
wire           m_axil_rvalid    ;
wire           m_axil_rready    ;


wire [ 1:0]usr_irq_req = LED[1:0];

xdma_mcap_top#(
	.WIRQ       (2),//中断信号的个数
)xdma_mcap_top_inst (
	.pcie_ref_clk_p (pcie_ref_clk_p ),
	.pcie_ref_clk_n (pcie_ref_clk_n ),
	.pcie_lane_rxp  (pcie_lane_rxp  ),
	.pcie_lane_rxn  (pcie_lane_rxn  ),
	.pcie_lane_txp  (pcie_lane_txp  ),
	.pcie_lane_txn  (pcie_lane_txn  ),
	.pcie_perst_n   (pcie_perst_n   ),
	.pcie_link_up   (pcie_link_up   ),
//---------------------------------------------------
	.axi_aclk       (axi_aclk       ),
    .usr_irq_req    (usr_irq_req    ),
	.tandem_rst_n   (axi_aresetn    ),
	.axi_aresetn    (               ),//log:建议使用tandem_rst_n用于复位, 
	.m_axi_awready  (m_axi_awready  ),
	.m_axi_wready   (m_axi_wready   ),
	.m_axi_bid      (m_axi_bid      ),
	.m_axi_bresp    (m_axi_bresp    ),
	.m_axi_bvalid   (m_axi_bvalid   ),
	.m_axi_arready  (m_axi_arready  ),
	.m_axi_rid      (m_axi_rid      ),
	.m_axi_rdata    (m_axi_rdata    ),
	.m_axi_rresp    (m_axi_rresp    ),
	.m_axi_rlast    (m_axi_rlast    ),
	.m_axi_rvalid   (m_axi_rvalid   ),
	.m_axi_awid     (m_axi_awid     ),
	.m_axi_awaddr   (m_axi_awaddr   ),
	.m_axi_awlen    (m_axi_awlen    ),
	.m_axi_awsize   (m_axi_awsize   ),
	.m_axi_awburst  (m_axi_awburst  ),
	.m_axi_awprot   (m_axi_awprot   ),
	.m_axi_awvalid  (m_axi_awvalid  ),
	.m_axi_awlock   (m_axi_awlock   ),
	.m_axi_awcache  (m_axi_awcache  ),
	.m_axi_wdata    (m_axi_wdata    ),
	.m_axi_wstrb    (m_axi_wstrb    ),
	.m_axi_wlast    (m_axi_wlast    ),
	.m_axi_wvalid   (m_axi_wvalid   ),
	.m_axi_bready   (m_axi_bready   ),
	.m_axi_arid     (m_axi_arid     ),
	.m_axi_araddr   (m_axi_araddr   ),
	.m_axi_arlen    (m_axi_arlen    ),
	.m_axi_arsize   (m_axi_arsize   ),
	.m_axi_arburst  (m_axi_arburst  ),
	.m_axi_arprot   (m_axi_arprot   ),
	.m_axi_arvalid  (m_axi_arvalid  ),
	.m_axi_arlock   (m_axi_arlock   ),
	.m_axi_arcache  (m_axi_arcache  ),
	.m_axi_rready   (m_axi_rready   ),
//---------------------------------------------------
//AXIL 接口
	.m_axil_awaddr  (m_axil_awaddr  ),
	.m_axil_awprot  (m_axil_awprot  ),
	.m_axil_awvalid (m_axil_awvalid ),
	.m_axil_awready (m_axil_awready ),
	.m_axil_wdata   (m_axil_wdata   ),
	.m_axil_wstrb   (m_axil_wstrb   ),
	.m_axil_wvalid  (m_axil_wvalid  ),
	.m_axil_wready  (m_axil_wready  ),
	.m_axil_bresp   (m_axil_bresp   ),
	.m_axil_bvalid  (m_axil_bvalid  ),
	.m_axil_bready  (m_axil_bready  ),
	.m_axil_araddr  (m_axil_araddr  ),
	.m_axil_arprot  (m_axil_arprot  ),
	.m_axil_arvalid (m_axil_arvalid ),
	.m_axil_arready (m_axil_arready ),
	.m_axil_rdata   (m_axil_rdata   ),
	.m_axil_rresp   (m_axil_rresp   ),
	.m_axil_rvalid  (m_axil_rvalid  ),
	.m_axil_rready  (m_axil_rready  )
);






axi_gpio_0 axi_gpio_0_inst(
  .s_axi_aclk       (  axi_aclk         ),// input  wire s_axi_aclk
  .s_axi_aresetn    (  axi_aresetn      ),// input  wire s_axi_aresetn
  .s_axi_awaddr     (m_axil_awaddr      ),// input  wire [8 : 0] s_axi_awaddr
  .s_axi_awvalid    (m_axil_awvalid     ),// input  wire s_axi_awvalid
  .s_axi_awready    (m_axil_awready     ),// output wire s_axi_awready
  .s_axi_wdata      (m_axil_wdata       ),// input  wire [31 : 0] s_axi_wdata
  .s_axi_wstrb      (m_axil_wstrb       ),// input  wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid     (m_axil_wvalid      ),// input  wire s_axi_wvalid
  .s_axi_wready     (m_axil_wready      ),// output wire s_axi_wready
  .s_axi_bresp      (m_axil_bresp       ),// output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid     (m_axil_bvalid      ),// output wire s_axi_bvalid
  .s_axi_bready     (m_axil_bready      ),// input  wire s_axi_bready
  .s_axi_araddr     (m_axil_araddr      ),// input  wire [8 : 0] s_axi_araddr
  .s_axi_arvalid    (m_axil_arvalid     ),// input  wire s_axi_arvalid
  .s_axi_arready    (m_axil_arready     ),// output wire s_axi_arready
  .s_axi_rdata      (m_axil_rdata       ),// output wire [31 : 0] s_axi_rdata
  .s_axi_rresp      (m_axil_rresp       ),// output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid     (m_axil_rvalid      ),// output wire s_axi_rvalid
  .s_axi_rready     (m_axil_rready      ),// input  wire s_axi_rready
  .gpio_io_o        (LED                ) // output wire ip2intc_irpt
);




axi_ram # (
    .DATA_WIDTH ( 512),
    .ADDR_WIDTH (   8),
    .ID_WIDTH   (   4),
)axi_ram_inst (
    .clk             (  axi_aclk              ),
    .rst             ( ~axi_aresetn           ),
    .s_axi_awid      (m_axi_awid      ),
    .s_axi_awaddr    (m_axi_awaddr    ),
    .s_axi_awlen     (m_axi_awlen     ),
    .s_axi_awsize    (m_axi_awsize    ),
    .s_axi_awburst   (m_axi_awburst   ),
    .s_axi_awlock    (m_axi_awlock    ),
    .s_axi_awcache   (m_axi_awcache   ),
    .s_axi_awprot    (m_axi_awprot    ),
    .s_axi_awvalid   (m_axi_awvalid   ),
    .s_axi_awready   (m_axi_awready   ),
    .s_axi_wdata     (m_axi_wdata     ),
    .s_axi_wstrb     (m_axi_wstrb     ),
    .s_axi_wlast     (m_axi_wlast     ),
    .s_axi_wvalid    (m_axi_wvalid    ),
    .s_axi_wready    (m_axi_wready    ),
    .s_axi_bid       (m_axi_bid       ),
    .s_axi_bresp     (m_axi_bresp     ),
    .s_axi_bvalid    (m_axi_bvalid    ),
    .s_axi_bready    (m_axi_bready    ),
    .s_axi_arid      (m_axi_arid      ),
    .s_axi_araddr    (m_axi_araddr    ),
    .s_axi_arlen     (m_axi_arlen     ),
    .s_axi_arsize    (m_axi_arsize    ),
    .s_axi_arburst   (m_axi_arburst   ),
    .s_axi_arlock    (m_axi_arlock    ),
    .s_axi_arcache   (m_axi_arcache   ),
    .s_axi_arprot    (m_axi_arprot    ),
    .s_axi_arvalid   (m_axi_arvalid   ),
    .s_axi_arready   (m_axi_arready   ),
    .s_axi_rid       (m_axi_rid       ),
    .s_axi_rdata     (m_axi_rdata     ),
    .s_axi_rresp     (m_axi_rresp     ),
    .s_axi_rlast     (m_axi_rlast     ),
    .s_axi_rvalid    (m_axi_rvalid    ),
    .s_axi_rready    (m_axi_rready    ) 
);













endmodule
