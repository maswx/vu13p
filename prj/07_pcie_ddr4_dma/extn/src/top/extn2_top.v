//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 04:46:45 PM CST
//========================================================================




`timescale 1 ps / 1 ps

module extn2_top(
output                   c0_ddr4_act_n           ,//o
output             [16:0]c0_ddr4_adr             ,//o
output             [ 1:0]c0_ddr4_ba              ,//o
output             [ 0:0]c0_ddr4_bg              ,//o
output             [ 0:0]c0_ddr4_ck_c            ,//o
output             [ 0:0]c0_ddr4_ck_t            ,//o
output             [ 0:0]c0_ddr4_cke             ,//o
input                    c0_ddr4_clk_clk_n       ,//i
input                    c0_ddr4_clk_clk_p       ,//i
output             [ 0:0]c0_ddr4_cs_n            ,//o
inout              [ 8:0]c0_ddr4_dm_n            ,//i
inout              [71:0]c0_ddr4_dq              ,//i
inout              [ 8:0]c0_ddr4_dqs_c           ,//i
inout              [ 8:0]c0_ddr4_dqs_t           ,//i
output             [ 0:0]c0_ddr4_odt             ,//o
output                   c0_ddr4_reset_n         ,//o
inout                    main_iic_sda            ,//io
inout                    main_iic_scl            ,//io
input              [15:0]pcie_lane_rxn           ,//i
input              [15:0]pcie_lane_rxp           ,//i
output             [15:0]pcie_lane_txn           ,//o
output             [15:0]pcie_lane_txp           ,//o
input                    pcie_perst              ,//i
input              [ 0:0]pcie_ref_clk_n          ,//i
input              [ 0:0]pcie_ref_clk_p          ,//i
output                   pcie_lnk_up              //o
);

wire                  sink_s2mm_aclk          ;//i
wire            [31:0]sink_s2mm_tdata         ;//i
wire            [ 3:0]sink_s2mm_tkeep         ;//i
wire                  sink_s2mm_tlast         ;//i
wire                  sink_s2mm_tready        ;//o
wire                  sink_s2mm_tvalid        ;//i
wire                  source_mm2s_aclk        ;//i
wire            [31:0]source_mm2s_tdata       ;//o
wire            [ 3:0]source_mm2s_tkeep       ;//o
wire                  source_mm2s_tlast       ;//o
wire                  source_mm2s_tready      ;//i
wire                  source_mm2s_tvalid      ;//o
wire                  tb_clk                  ;//o
wire                  tb_clk_locked           ;//o
wire                  testvec_s2mm_aclk       ;//i
wire            [63:0]testvec_s2mm_tdata      ;//i
wire            [ 7:0]testvec_s2mm_tkeep      ;//i
wire                  testvec_s2mm_tlast      ;//i
wire                  testvec_s2mm_tready     ;//o
wire                  testvec_s2mm_tvalid     ;//i

wire iic_scl_i;
wire iic_scl_o;
wire iic_scl_t;
wire iic_sda_i;
wire iic_sda_o;
wire iic_sda_t;

base base_inst     (
   .c0_ddr4_act_n        (c0_ddr4_act_n         ),
   .c0_ddr4_adr          (c0_ddr4_adr           ),
   .c0_ddr4_ba           (c0_ddr4_ba            ),
   .c0_ddr4_bg           (c0_ddr4_bg            ),
   .c0_ddr4_ck_c         (c0_ddr4_ck_c          ),
   .c0_ddr4_ck_t         (c0_ddr4_ck_t          ),
   .c0_ddr4_cke          (c0_ddr4_cke           ),
   .c0_ddr4_clk_clk_n    (c0_ddr4_clk_clk_n     ),
   .c0_ddr4_clk_clk_p    (c0_ddr4_clk_clk_p     ),
   .c0_ddr4_cs_n         (c0_ddr4_cs_n          ),
   .c0_ddr4_dm_n         (c0_ddr4_dm_n          ),
   .c0_ddr4_dq           (c0_ddr4_dq            ),
   .c0_ddr4_dqs_c        (c0_ddr4_dqs_c         ),
   .c0_ddr4_dqs_t        (c0_ddr4_dqs_t         ),
   .c0_ddr4_odt          (c0_ddr4_odt           ),
   .c0_ddr4_reset_n      (c0_ddr4_reset_n       ),
   .iic_scl_i            (iic_scl_i             ),
   .iic_scl_o            (iic_scl_o             ),
   .iic_scl_t            (iic_scl_t             ),
   .iic_sda_i            (iic_sda_i             ),
   .iic_sda_o            (iic_sda_o             ),
   .iic_sda_t            (iic_sda_t             ),
   .pcie_lane_rxn        (pcie_lane_rxn         ),
   .pcie_lane_rxp        (pcie_lane_rxp         ),
   .pcie_lane_txn        (pcie_lane_txn         ),
   .pcie_lane_txp        (pcie_lane_txp         ),
   .pcie_lnk_up          (pcie_lnk_up           ),
   .pcie_perst           (pcie_perst            ),
   .pcie_ref_clk_n       (pcie_ref_clk_n        ),
   .pcie_ref_clk_p       (pcie_ref_clk_p        ),
   .sink_s2mm_aclk       (sink_s2mm_aclk        ),
   .sink_s2mm_tdata      (sink_s2mm_tdata       ),
   .sink_s2mm_tkeep      (sink_s2mm_tkeep       ),
   .sink_s2mm_tlast      (sink_s2mm_tlast       ),
   .sink_s2mm_tready     (sink_s2mm_tready      ),
   .sink_s2mm_tvalid     (sink_s2mm_tvalid      ),
   .source_mm2s_aclk     (source_mm2s_aclk      ),
   .source_mm2s_tdata    (source_mm2s_tdata     ),
   .source_mm2s_tkeep    (source_mm2s_tkeep     ),
   .source_mm2s_tlast    (source_mm2s_tlast     ),
   .source_mm2s_tready   (source_mm2s_tready    ),
   .source_mm2s_tvalid   (source_mm2s_tvalid    ),
   .tb_clk               (tb_clk                ),
   .tb_clk_locked        (tb_clk_locked         ),
   .testvec_s2mm_aclk    (testvec_s2mm_aclk     ),
   .testvec_s2mm_tdata   (testvec_s2mm_tdata    ),
   .testvec_s2mm_tkeep   (testvec_s2mm_tkeep    ),
   .testvec_s2mm_tlast   (testvec_s2mm_tlast    ),
   .testvec_s2mm_tready  (testvec_s2mm_tready   ),
   .testvec_s2mm_tvalid  (testvec_s2mm_tvalid   )
);

//--input                    sink_s2mm_aclk          ,//i
//--input              [31:0]sink_s2mm_tdata         ,//i
//--input              [ 3:0]sink_s2mm_tkeep         ,//i
//--input                    sink_s2mm_tlast         ,//i
//--output                   sink_s2mm_tready        ,//o
//--input                    sink_s2mm_tvalid        ,//i
//--input                    source_mm2s_aclk        ,//i
//--output             [31:0]source_mm2s_tdata       ,//o
//--output             [ 3:0]source_mm2s_tkeep       ,//o
//--output                   source_mm2s_tlast       ,//o
//--input                    source_mm2s_tready      ,//i
//--output                   source_mm2s_tvalid      ,//o
//--output                   tb_clk                  ,//o
//--output                   tb_clk_locked           ,//o
//--input                    testvec_s2mm_aclk       ,//i
//--input              [63:0]testvec_s2mm_tdata      ,//i
//--input              [ 7:0]testvec_s2mm_tkeep      ,//i
//--input                    testvec_s2mm_tlast      ,//i
//--output                   testvec_s2mm_tready     ,//o
//--input                    testvec_s2mm_tvalid      //i


//---IOBUF IIC_scl_iobuf
//---     (.I (iic_scl_o      ),
//---      .IO(main_iic_scl),
//---      .O (iic_scl_i      ),
//---      .T (iic_scl_t      ));
//---
//---IOBUF IIC_sda_iobuf
//---     (.I (iic_sda_o      ),
//---      .IO(main_iic_sda),
//---      .O (iic_sda_i      ),
//---      .T (iic_sda_t      ));



wire dut_sda_i;
wire dut_scl_i;
wire dut_scl_t;
wire dut_sda_t;
wire dut_scl_o;
wire dut_sda_o;
wire [15:0]data_in  = source_mm2s_tdata[15:0];
wire [15:0]data_out;
wire [63:0]testvec ;


assign iic_scl_i    = main_iic_scl;
assign dut_scl_i    = main_iic_scl;
assign main_iic_scl = (dut_scl_o & iic_scl_t) ? 1'bz : 1'b0;
assign iic_sda_i    = main_iic_sda;
assign dut_sda_i    = main_iic_sda;
assign main_iic_sda = (dut_sda_o & iic_sda_t) ? 1'bz : 1'b0;

//assign dut_sda_i = dut_sda_o & iic_sda_t;
//assign dut_scl_i = dut_scl_o & iic_scl_t;
//assign iic_sda_i = dut_sda_o & iic_sda_t;
//assign iic_scl_i = dut_scl_o & iic_scl_t;


fir_top dut_top_inst(
    .clk        ( tb_clk                ),//i
    .rst        (~tb_clk_locked         ),//i
    .data_in    (data_in                ),//i   
    .data_out   (data_out               ),//o
    .i2c_scl_i  (dut_scl_i              ),//i
    .i2c_scl_o  (dut_scl_o              ),//o   
    .i2c_scl_t  (dut_scl_t              ),//o
    .i2c_sda_i  (dut_sda_i              ),//i
    .i2c_sda_o  (dut_sda_o              ),//o
    .i2c_sda_t  (dut_sda_t              ),//o
	.testvec    (testvec                ) //o送到逻辑分析仪的测试矢量
);                 
                      
assign sink_s2mm_aclk      =  tb_clk    ;//i//--input                    
assign sink_s2mm_tdata     =  data_out  ;//i//--input              [31:0]
assign sink_s2mm_tkeep     =  4'hf      ;//i//--input              [ 3:0]
assign sink_s2mm_tlast     =  1'd0      ;//i//--input                    
assign sink_s2mm_tvalid    =  1'd1      ;//i//--input                    
assign source_mm2s_aclk    =  tb_clk    ;//i//--input                    
assign source_mm2s_tready  =  1'd1      ;//i//--input                    
assign testvec_s2mm_aclk   =  tb_clk    ;//i//--input                    
assign testvec_s2mm_tdata  =  testvec   ;//i//--input              [63:0]
assign testvec_s2mm_tkeep  =  8'hff     ;//i//--input              [ 7:0]
assign testvec_s2mm_tlast  =  1'd0      ;//i//--input                    
assign testvec_s2mm_tvalid =  1'd1      ;//i//--input                    
                   














endmodule
