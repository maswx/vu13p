//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年11月10日 星期五 22时42分53秒
//========================================================================

/* design by masw@masw.tech 
                                                                                                        


*/

module data_mover_top(
	input wire [0:0]       clk_100M_p,
	input wire [0:0]       clk_100M_n,


    /*
     * Ethernet: QSFP28
     */
    //output wire [3:0] up_qsfp_txp,
    //output wire [3:0] up_qsfp_txn,
    //input  wire [3:0] up_qsfp_rxp,
    //input  wire [3:0] up_qsfp_rxn,
    //input  wire       up_qsfp_161p132_clk_p,
    //input  wire       up_qsfp_161p132_clk_n,

    output wire [3:0] dn_qsfp_txp,
    output wire [3:0] dn_qsfp_txn,
    input  wire [3:0] dn_qsfp_rxp,
    input  wire [3:0] dn_qsfp_rxn,
    input  wire       dn_qsfp_161p132_clk_p,
    input  wire       dn_qsfp_161p132_clk_n,

	//PCIE
	//
	input  [   0:0]   pcie_ref_clk_p  ,
	input  [   0:0]   pcie_ref_clk_n  ,
	input  [  15:0]   pcie_lane_rxp   ,
	input  [  15:0]   pcie_lane_rxn   ,
	output [  15:0]   pcie_lane_txp   ,
	output [  15:0]   pcie_lane_txn   ,
	input             pcie_perst_n    ,
	output            pcie_link_up    ,

	//DDR4
	
    output            c0_ddr4_act_n   ,
    output [16:0]     c0_ddr4_adr     ,
    output [ 1:0]     c0_ddr4_ba      ,
    output [ 0:0]     c0_ddr4_bg      ,
    output [ 0:0]     c0_ddr4_ck_c    ,
    output [ 0:0]     c0_ddr4_ck_t    ,
    output [ 0:0]     c0_ddr4_cke     ,
    output [ 0:0]     c0_ddr4_cs_n    ,
    inout  [ 7:0]     c0_ddr4_dm_n    ,
    inout  [63:0]     c0_ddr4_dq      ,
    inout  [ 7:0]     c0_ddr4_dqs_c   ,
    inout  [ 7:0]     c0_ddr4_dqs_t   ,
    output [ 0:0]     c0_ddr4_odt     ,
    output            c0_ddr4_reset_n ,
	input  [ 0:0]     c0_ddr4_clk_p   ,
	input  [ 0:0]     c0_ddr4_clk_n   


);
wire clk_100mhz_ibufg;
wire clk_100mhz_mmcm_out;
wire clk_100mhz_int;
wire rst_100mhz_int;
wire mmcm_rst = 1'b0;
wire mmcm_locked;
wire mmcm_clkfb;
IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_300mhz_ibufg_inst (
   .O   (clk_100mhz_ibufg),
   .I   (clk_100M_p),
   .IB  (clk_100M_n) 
);
wire        qsfp_0_tx_clk_0_int;
wire        qsfp_0_tx_rst_0_int;
wire [63:0] qsfp_0_txd_0_int   ;
wire [7:0]  qsfp_0_txc_0_int   ;
wire        qsfp_0_rx_clk_0_int;
wire        qsfp_0_rx_rst_0_int;
wire [63:0] qsfp_0_rxd_0_int   ;
wire [7:0]  qsfp_0_rxc_0_int   ;
// MMCM instance
// 100 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 10, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME3_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(10),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_100mhz_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_100mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_100mhz_bufg_inst (
    .I(clk_100mhz_mmcm_out),
    .O(clk_100mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_100mhz_inst (
    .clk(clk_100mhz_int),
    .rst(~mmcm_locked),
    .out(rst_100mhz_int)
);



wire [63:0] rx_fifo_udp_payload_axis_tdata ;
wire [ 7:0] rx_fifo_udp_payload_axis_tkeep ;
wire        rx_fifo_udp_payload_axis_tvalid;
wire        rx_fifo_udp_payload_axis_tready;
wire        rx_fifo_udp_payload_axis_tlast ;
wire        rx_fifo_udp_payload_axis_tuser ;
                                             
wire [63:0] tx_fifo_udp_payload_axis_tdata ;
wire [ 7:0] tx_fifo_udp_payload_axis_tkeep ;
wire        tx_fifo_udp_payload_axis_tvalid;
wire        tx_fifo_udp_payload_axis_tready;
wire        tx_fifo_udp_payload_axis_tlast ;
wire        tx_fifo_udp_payload_axis_tuser ;

//===================================================================================
//===================================================================================
//===================================================================================
//

wire  [31:0]M_AXIS_tdata                  ;
wire  [ 3:0]M_AXIS_tkeep                  ;
wire        M_AXIS_tlast                  ;
wire        M_AXIS_tready                 ;
wire        M_AXIS_tvalid                 ;
wire  [63:0]S_AXIS_tdata                  ;
wire  [ 7:0]S_AXIS_tkeep                  ;
wire        S_AXIS_tlast                  ;
wire        S_AXIS_tready                 ;
wire        S_AXIS_tvalid                 ;
wire        axi_aclk                      ;
wire        axi_aresetn                   ;
wire        M_AXIS_aclk                   ;
wire        M_AXIS_aresetn                ;
wire        S_AXIS_aclk                   ;
wire        S_AXIS_aresetn                ;

// ./ip/bd/base/hdl/base_wrapper.v

base base_i (
    .axi_aclk                            (axi_aclk                        ),//o1
    .axi_aresetn                         (axi_aresetn                     ),//o1
	//数据流 Master通道为32bit, 主频100M, 独立时钟域
    .m_axis_aclk                         (M_AXIS_aclk                     ),//i1
	.m_axis_aresetn                      (M_AXIS_aresetn                  ),//o1, 内部复位输出
    .M_AXIS_tdata                        (M_AXIS_tdata                    ),//o32
    .M_AXIS_tkeep                        (M_AXIS_tkeep                    ),//o4
    .M_AXIS_tlast                        (M_AXIS_tlast                    ),//o1
    .M_AXIS_tready                       (M_AXIS_tready                   ),//i1,
    .M_AXIS_tvalid                       (M_AXIS_tvalid                   ),//o1
	//数据流 Slave 通道为64bit, 仅仅用于将UDP数据流写入DDR4, 主频390.625M , 与UDP同时钟域
    .s_axis_aclk                         ( qsfp_0_rx_clk_0_int            ),
    .s_axis_aresetn                      (                                ),//o1, 内部复位输出
    .S_AXIS_tdata                        (rx_fifo_udp_payload_axis_tdata  ),//i64
    .S_AXIS_tkeep                        (rx_fifo_udp_payload_axis_tkeep  ),//i8
    .S_AXIS_tlast                        (rx_fifo_udp_payload_axis_tlast  ),//i1
    .S_AXIS_tready                       (rx_fifo_udp_payload_axis_tready ),//o1
    .S_AXIS_tvalid                       (rx_fifo_udp_payload_axis_tvalid ),//i1
	//DDR4                                                                  
    .ddr4_rtl_0_act_n                    (c0_ddr4_act_n                   ),
    .ddr4_rtl_0_adr                      (c0_ddr4_adr                     ),
    .ddr4_rtl_0_ba                       (c0_ddr4_ba                      ),
    .ddr4_rtl_0_bg                       (c0_ddr4_bg                      ),
    .ddr4_rtl_0_ck_c                     (c0_ddr4_ck_c                    ),
    .ddr4_rtl_0_ck_t                     (c0_ddr4_ck_t                    ),
    .ddr4_rtl_0_cke                      (c0_ddr4_cke                     ),
    .ddr4_rtl_0_cs_n                     (c0_ddr4_cs_n                    ),
    .ddr4_rtl_0_dm_n                     (c0_ddr4_dm_n                    ),
    .ddr4_rtl_0_dq                       (c0_ddr4_dq                      ),
    .ddr4_rtl_0_dqs_c                    (c0_ddr4_dqs_c                   ),
    .ddr4_rtl_0_dqs_t                    (c0_ddr4_dqs_t                   ),
    .ddr4_rtl_0_odt                      (c0_ddr4_odt                     ),
    .ddr4_rtl_0_reset_n                  (c0_ddr4_reset_n                 ),
    .ddr4_clk_clk_n                      (c0_ddr4_clk_n                   ),
    .ddr4_clk_clk_p                      (c0_ddr4_clk_p                   ),
	//PCIe Port                          
    .pcie_clk_clk_n                      (pcie_ref_clk_n                  ),
    .pcie_clk_clk_p                      (pcie_ref_clk_p                  ),
    .pcie_7x_mgt_rtl_0_rxn               (pcie_lane_rxn                   ),
    .pcie_7x_mgt_rtl_0_rxp               (pcie_lane_rxp                   ),
    .pcie_7x_mgt_rtl_0_txn               (pcie_lane_txn                   ),
    .pcie_7x_mgt_rtl_0_txp               (pcie_lane_txp                   ),
    .pcie_perst_n                        (pcie_perst_n                    ),
    .user_lnk_up                         (pcie_link_up                    )
);



//===================================================================================
//  32bit@100MHz to 64bit@390.625MHz

assign M_AXIS_aclk      =  clk_100mhz_int;
wire            axis_tvalid; 
wire            axis_tready;
wire [63 : 0]   axis_tdata ; 
wire [ 7 : 0]   axis_tkeep ;
wire            axis_tlast ;
axis_dwidth_converter_0 axis_dwidth_converter_0_inst(
  .aclk                   (M_AXIS_aclk   ),// input wire aclk
  .aresetn                (M_AXIS_aresetn),// input wire aresetn
  .s_axis_tvalid          (M_AXIS_tvalid ),// input wire s_axis_tvalid
  .s_axis_tready          (M_AXIS_tready ),// output wire s_axis_tready
  .s_axis_tdata           (M_AXIS_tdata  ),// input wire [31 : 0] s_axis_tdata
  .s_axis_tkeep           (M_AXIS_tkeep  ),// input wire [3 : 0] s_axis_tkeep
  .s_axis_tlast           (M_AXIS_tlast  ),// input wire s_axis_tlast
  .m_axis_tvalid          (  axis_tvalid ),// output wire m_axis_tvalid
  .m_axis_tready          (  axis_tready ),// input  wire m_axis_tready
  .m_axis_tdata           (  axis_tdata  ),// output wire [63 : 0] m_axis_tdata
  .m_axis_tkeep           (  axis_tkeep  ),// output wire [7 : 0] m_axis_tkeep
  .m_axis_tlast           (  axis_tlast  ) // output wire m_axis_tlast
);

// 64bit@100M to 64bit@390.625MHz
axis_data_fifo_0 axis_data_fifo_0_inst(
  .s_axis_aclk   (M_AXIS_aclk                     ),// input wire s_axis_aclk
  .s_axis_aresetn(M_AXIS_aresetn                  ),// input wire s_axis_aresetn
  .s_axis_tvalid (  axis_tvalid                   ),// input wire s_axis_tvalid
  .s_axis_tready (  axis_tready                   ),// output wire s_axis_tready
  .s_axis_tdata  (  axis_tdata                    ),// input wire [63 : 0] s_axis_tdata
  .s_axis_tkeep  (  axis_tkeep                    ),// input wire [7 : 0] s_axis_tkeep
  .s_axis_tlast  (  axis_tlast                    ),// input wire s_axis_tlast
  .s_axis_tuser  (  axis_tuser                    ),// input wire [0 : 0] s_axis_tuser
  .m_axis_aclk   (qsfp_0_tx_clk_0_int             ),// input wire m_axis_aclk
  .m_axis_tvalid (tx_fifo_udp_payload_axis_tvalid ),// output wire m_axis_tvalid
  .m_axis_tready (tx_fifo_udp_payload_axis_tready ),// input wire m_axis_tready
  .m_axis_tdata  (tx_fifo_udp_payload_axis_tdata  ),// output wire [63 : 0] m_axis_tdata
  .m_axis_tkeep  (tx_fifo_udp_payload_axis_tkeep  ),// output wire [7 : 0] m_axis_tkeep
  .m_axis_tlast  (tx_fifo_udp_payload_axis_tlast  ),// output wire m_axis_tlast
  .m_axis_tuser  (tx_fifo_udp_payload_axis_tuser  ) // output wire [0 : 0] m_axis_tuser
);


udp64_sfp_top udp64_sfp_top_inst(
    .clk                               (qsfp_0_tx_clk_0_int),//input  wire        clk                            ,//i1, Clock: 390.625 MHz
    .rst                               (qsfp_0_tx_rst_0_int),//input  wire        rst                            ,//i1, Synchronous reset
    .user_led_g                        (                   ),//output wire [1:0]  user_led_g                     ,//o2, led
                                    
    .qsfp_0_tx_clk_0                   (qsfp_0_tx_clk_0_int),//input  wire        qsfp_0_tx_clk_0                ,
    .qsfp_0_tx_rst_0                   (qsfp_0_tx_rst_0_int),//input  wire        qsfp_0_tx_rst_0                ,
    .qsfp_0_txd_0                      (qsfp_0_txd_0_int   ),//output wire [63:0] qsfp_0_txd_0                   ,
    .qsfp_0_txc_0                      (qsfp_0_txc_0_int   ),//output wire [7:0]  qsfp_0_txc_0                   ,
    .qsfp_0_rx_clk_0                   (qsfp_0_rx_clk_0_int),//input  wire        qsfp_0_rx_clk_0                ,
    .qsfp_0_rx_rst_0                   (qsfp_0_rx_rst_0_int),//input  wire        qsfp_0_rx_rst_0                ,
    .qsfp_0_rxd_0                      (qsfp_0_rxd_0_int   ),//input  wire [63:0] qsfp_0_rxd_0                   ,
    .qsfp_0_rxc_0                      (qsfp_0_rxc_0_int   ),//input  wire [7:0]  qsfp_0_rxc_0                   ,
                                    
	.rx_fifo_udp_payload_axis_tdata    (rx_fifo_udp_payload_axis_tdata ),//output wire [63:0] rx_fifo_udp_payload_axis_tdata ,
	.rx_fifo_udp_payload_axis_tkeep    (rx_fifo_udp_payload_axis_tkeep ),//output wire [ 7:0] rx_fifo_udp_payload_axis_tkeep ,
	.rx_fifo_udp_payload_axis_tvalid   (rx_fifo_udp_payload_axis_tvalid),//output wire        rx_fifo_udp_payload_axis_tvalid,
	.rx_fifo_udp_payload_axis_tready   (rx_fifo_udp_payload_axis_tready),//input  wire        rx_fifo_udp_payload_axis_tready,
	.rx_fifo_udp_payload_axis_tlast    (rx_fifo_udp_payload_axis_tlast ),//output wire        rx_fifo_udp_payload_axis_tlast ,
	.rx_fifo_udp_payload_axis_tuser    (rx_fifo_udp_payload_axis_tuser ),//output wire        rx_fifo_udp_payload_axis_tuser ,
                                                                       
	.tx_fifo_udp_payload_axis_tdata    (tx_fifo_udp_payload_axis_tdata ),//input  wire [63:0] tx_fifo_udp_payload_axis_tdata ,
	.tx_fifo_udp_payload_axis_tkeep    (tx_fifo_udp_payload_axis_tkeep ),//input  wire [ 7:0] tx_fifo_udp_payload_axis_tkeep ,
	.tx_fifo_udp_payload_axis_tvalid   (tx_fifo_udp_payload_axis_tvalid),//input  wire        tx_fifo_udp_payload_axis_tvalid,
	.tx_fifo_udp_payload_axis_tready   (tx_fifo_udp_payload_axis_tready),//output wire        tx_fifo_udp_payload_axis_tready,
	.tx_fifo_udp_payload_axis_tlast    (tx_fifo_udp_payload_axis_tlast ),//input  wire        tx_fifo_udp_payload_axis_tlast ,
	.tx_fifo_udp_payload_axis_tuser    (tx_fifo_udp_payload_axis_tuser ) //input  wire        tx_fifo_udp_payload_axis_tuser  

);

ila_udp your_instance_name (
	.clk(qsfp_0_tx_clk_0_int), // input wire clk


	.probe0 (rx_fifo_udp_payload_axis_tdata ), // input wire [63:0]  probe0  
	.probe1 (rx_fifo_udp_payload_axis_tkeep ), // input wire [7:0]  probe1 
	.probe2 (rx_fifo_udp_payload_axis_tvalid), // input wire [0:0]  probe2 
	.probe3 (rx_fifo_udp_payload_axis_tready), // input wire [0:0]  probe3 
	.probe4 (rx_fifo_udp_payload_axis_tlast ), // input wire [0:0]  probe4 
	.probe5 (rx_fifo_udp_payload_axis_tuser ), // input wire [0:0]  probe5 
	.probe6 (tx_fifo_udp_payload_axis_tdata ), // input wire [63:0]  probe6 
	.probe7 (tx_fifo_udp_payload_axis_tkeep ), // input wire [7:0]  probe7 
	.probe8 (tx_fifo_udp_payload_axis_tvalid), // input wire [0:0]  probe8 
	.probe9 (tx_fifo_udp_payload_axis_tready), // input wire [0:0]  probe9 
	.probe10(tx_fifo_udp_payload_axis_tlast ), // input wire [0:0]  probe10 
	.probe11(tx_fifo_udp_payload_axis_tuser ) // input wire [0:0]  probe11
);



//=======================================================================================================
//=======================================================================================================
//=======================================================================================================
// SFP
wire qsfp_0_rx_block_lock_0;

wire qsfp_0_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_0_mgt_refclk_inst (
    .I     (dn_qsfp_161p132_clk_p),
    .IB    (dn_qsfp_161p132_clk_n),
    .CEB   (1'b0),
    .O     (qsfp_0_mgt_refclk),
    .ODIV2 ()
);

eth_xcvr_phy_quad_wrapper #(
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(100000/2.56)
)
qsfp_0_phy_inst (
    .xcvr_ctrl_clk(clk_100mhz_int),
    .xcvr_ctrl_rst(rst_100mhz_int),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(),

    /*
     * PLL
     */
    .xcvr_gtrefclk00_in(qsfp_0_mgt_refclk),

    /*
     * Serial data
     */
    .xcvr_txp(dn_qsfp_txp),//(qsfp_0_tx_p),
    .xcvr_txn(dn_qsfp_txn),//(qsfp_0_tx_n),
    .xcvr_rxp(dn_qsfp_rxp),//(qsfp_0_rx_p),
    .xcvr_rxn(dn_qsfp_rxn),//(qsfp_0_rx_n),

    /*
     * PHY connections
     */
    .phy_1_tx_clk                     (qsfp_0_tx_clk_0_int      ),//output wire                   phy_1_tx_clk,
    .phy_1_tx_rst                     (qsfp_0_tx_rst_0_int      ),//output wire                   phy_1_tx_rst,
    .phy_1_xgmii_txd                  (qsfp_0_txd_0_int         ),//input  wire [DATA_WIDTH-1:0]  phy_1_xgmii_txd,
    .phy_1_xgmii_txc                  (qsfp_0_txc_0_int         ),//input  wire [CTRL_WIDTH-1:0]  phy_1_xgmii_txc,
    .phy_1_rx_clk                     (qsfp_0_rx_clk_0_int      ),//output wire                   phy_1_rx_clk,
    .phy_1_rx_rst                     (qsfp_0_rx_rst_0_int      ),//output wire                   phy_1_rx_rst,
    .phy_1_xgmii_rxd                  (qsfp_0_rxd_0_int         ),//output wire [DATA_WIDTH-1:0]  phy_1_xgmii_rxd,
    .phy_1_xgmii_rxc                  (qsfp_0_rxc_0_int         ),//output wire [CTRL_WIDTH-1:0]  phy_1_xgmii_rxc,
    .phy_1_tx_bad_block               (                         ),//output wire                   phy_1_tx_bad_block,
    .phy_1_rx_error_count             (                         ),//output wire [6:0]             phy_1_rx_error_count,
    .phy_1_rx_bad_block               (                         ),//output wire                   phy_1_rx_bad_block,
    .phy_1_rx_sequence_error          (                         ),//output wire                   phy_1_rx_sequence_error,
    .phy_1_rx_block_lock              (                         ),//output wire                   phy_1_rx_block_lock,
    .phy_1_rx_status                  (                         ),//output wire                   phy_1_rx_status,
    .phy_1_cfg_tx_prbs31_enable       (1'b0                     ),//input  wire                   phy_1_cfg_tx_prbs31_enable,
    .phy_1_cfg_rx_prbs31_enable       (1'b0                     ),//input  wire                   phy_1_cfg_rx_prbs31_enable,
    .phy_2_tx_clk                     (                         ),//output wire                   phy_2_tx_clk,
    .phy_2_tx_rst                     (                         ),//output wire                   phy_2_tx_rst,
    .phy_2_xgmii_txd                  (64'd0                    ),//input  wire [DATA_WIDTH-1:0]  phy_2_xgmii_txd,
    .phy_2_xgmii_txc                  ( 8'd0                    ),//input  wire [CTRL_WIDTH-1:0]  phy_2_xgmii_txc,
    .phy_2_rx_clk                     (                         ),//output wire                   phy_2_rx_clk,
    .phy_2_rx_rst                     (                         ),//output wire                   phy_2_rx_rst,
    .phy_2_xgmii_rxd                  (                         ),//output wire [DATA_WIDTH-1:0]  phy_2_xgmii_rxd,
    .phy_2_xgmii_rxc                  (                         ),//output wire [CTRL_WIDTH-1:0]  phy_2_xgmii_rxc,
    .phy_2_tx_bad_block               (                         ),//output wire                   phy_2_tx_bad_block,
    .phy_2_rx_error_count             (                         ),//output wire [6:0]             phy_2_rx_error_count,
    .phy_2_rx_bad_block               (                         ),//output wire                   phy_2_rx_bad_block,
    .phy_2_rx_sequence_error          (                         ),//output wire                   phy_2_rx_sequence_error,
    .phy_2_rx_block_lock              (                         ),//output wire                   phy_2_rx_block_lock,
    .phy_2_rx_status                  (                         ),//output wire                   phy_2_rx_status,
    .phy_2_cfg_tx_prbs31_enable       (1'b0                     ),//input  wire                   phy_2_cfg_tx_prbs31_enable,
    .phy_2_cfg_rx_prbs31_enable       (1'b0                     ),//input  wire                   phy_2_cfg_rx_prbs31_enable,
    .phy_3_tx_clk                     (                         ),//output wire                   phy_3_tx_clk,
    .phy_3_tx_rst                     (                         ),//output wire                   phy_3_tx_rst,
    .phy_3_xgmii_txd                  (64'd0                    ),//input  wire [DATA_WIDTH-1:0]  phy_3_xgmii_txd,
    .phy_3_xgmii_txc                  ( 8'd0                    ),//input  wire [CTRL_WIDTH-1:0]  phy_3_xgmii_txc,
    .phy_3_rx_clk                     (                         ),//output wire                   phy_3_rx_clk,
    .phy_3_rx_rst                     (                         ),//output wire                   phy_3_rx_rst,
    .phy_3_xgmii_rxd                  (                         ),//output wire [DATA_WIDTH-1:0]  phy_3_xgmii_rxd,
    .phy_3_xgmii_rxc                  (                         ),//output wire [CTRL_WIDTH-1:0]  phy_3_xgmii_rxc,
    .phy_3_tx_bad_block               (                         ),//output wire                   phy_3_tx_bad_block,
    .phy_3_rx_error_count             (                         ),//output wire [6:0]             phy_3_rx_error_count,
    .phy_3_rx_bad_block               (                         ),//output wire                   phy_3_rx_bad_block,
    .phy_3_rx_sequence_error          (                         ),//output wire                   phy_3_rx_sequence_error,
    .phy_3_rx_block_lock              (                         ),//output wire                   phy_3_rx_block_lock,
    .phy_3_rx_status                  (                         ),//output wire                   phy_3_rx_status,
    .phy_3_cfg_tx_prbs31_enable       (1'b0                     ),//input  wire                   phy_3_cfg_tx_prbs31_enable,
    .phy_3_cfg_rx_prbs31_enable       (1'b0                     ),//input  wire                   phy_3_cfg_rx_prbs31_enable,
    .phy_4_tx_clk                     (                         ),//output wire                   phy_4_tx_clk,
    .phy_4_tx_rst                     (                         ),//output wire                   phy_4_tx_rst,
    .phy_4_xgmii_txd                  (64'd0                    ),//input  wire [DATA_WIDTH-1:0]  phy_4_xgmii_txd,
    .phy_4_xgmii_txc                  ( 8'd0                    ),//input  wire [CTRL_WIDTH-1:0]  phy_4_xgmii_txc,
    .phy_4_rx_clk                     (                         ),//output wire                   phy_4_rx_clk,
    .phy_4_rx_rst                     (                         ),//output wire                   phy_4_rx_rst,
    .phy_4_xgmii_rxd                  (                         ),//output wire [DATA_WIDTH-1:0]  phy_4_xgmii_rxd,
    .phy_4_xgmii_rxc                  (                         ),//output wire [CTRL_WIDTH-1:0]  phy_4_xgmii_rxc,
    .phy_4_tx_bad_block               (                         ),//output wire                   phy_4_tx_bad_block,
    .phy_4_rx_error_count             (                         ),//output wire [6:0]             phy_4_rx_error_count,
    .phy_4_rx_bad_block               (                         ),//output wire                   phy_4_rx_bad_block,
    .phy_4_rx_sequence_error          (                         ),//output wire                   phy_4_rx_sequence_error,
    .phy_4_rx_block_lock              (                         ),//output wire                   phy_4_rx_block_lock,
    .phy_4_rx_status                  (                         ),//output wire                   phy_4_rx_status,
    .phy_4_cfg_tx_prbs31_enable       (1'b0                     ),//input  wire                   phy_4_cfg_tx_prbs31_enable,
    .phy_4_cfg_rx_prbs31_enable       (1'b0                     ) //input  wire                   phy_4_cfg_rx_prbs31_enable,
);







endmodule
