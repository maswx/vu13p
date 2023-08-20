//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 04:46:45 PM CST
//========================================================================




`timescale 1 ps / 1 ps

module extn_top(
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

    wire [3:0]  s_axil_awaddr     ;
    wire [2:0]  s_axil_awprot     ;
    wire        s_axil_awvalid    ;
    wire        s_axil_awready    ;
    wire [31:0] s_axil_wdata      ;
    wire [3:0]  s_axil_wstrb      ;
    wire        s_axil_wvalid     ;
    wire        s_axil_wready     ;
    wire [1:0]  s_axil_bresp      ;
    wire        s_axil_bvalid     ;
    wire        s_axil_bready     ;
    wire [3:0]  s_axil_araddr     ;
    wire [2:0]  s_axil_arprot     ;
    wire        s_axil_arvalid    ;
    wire        s_axil_arready    ;
    wire [31:0] s_axil_rdata      ;
    wire [1:0]  s_axil_rresp      ;
    wire        s_axil_rvalid     ;
    wire        s_axil_rready     ;
    wire        i2c_master_scl_i ;
    wire        i2c_master_scl_o ;
    wire        i2c_master_scl_t ;
    wire        i2c_master_sda_i ;
    wire        i2c_master_sda_o ;
    wire        i2c_master_sda_t ;
wire iic_scl_i;
wire iic_scl_o;
wire iic_scl_t;
wire iic_sda_i;
wire iic_sda_o;
wire iic_sda_t;

wire [ 3:0]interp;
wire       axi_aclk;
wire [31:0] GPO_tri_o;
wire [30:0]M01_AXI_IIC_araddr ;
wire [ 2:0]M01_AXI_IIC_arprot ;
wire       M01_AXI_IIC_arready;
wire       M01_AXI_IIC_arvalid;
wire [30:0]M01_AXI_IIC_awaddr ;
wire [ 2:0]M01_AXI_IIC_awprot ;
wire       M01_AXI_IIC_awready;
wire       M01_AXI_IIC_awvalid;
wire       M01_AXI_IIC_bready ;
wire [ 1:0]M01_AXI_IIC_bresp  ;
wire       M01_AXI_IIC_bvalid ;
wire [31:0]M01_AXI_IIC_rdata  ;
wire       M01_AXI_IIC_rready ;
wire [ 1:0]M01_AXI_IIC_rresp  ;
wire       M01_AXI_IIC_rvalid ;
wire [31:0]M01_AXI_IIC_wdata  ;
wire       M01_AXI_IIC_wready ;
wire [ 3:0]M01_AXI_IIC_wstrb  ;
wire       M01_AXI_IIC_wvalid ;


assign s_axil_awaddr    =  M01_AXI_IIC_awaddr [3:0];//i [3:0]  
assign s_axil_awprot    =  M01_AXI_IIC_awprot      ;//i [2:0]  
assign s_axil_awvalid   =  M01_AXI_IIC_awvalid     ;//i        
assign s_axil_awready   =  M01_AXI_IIC_awready     ;//o        
assign s_axil_wdata     =  M01_AXI_IIC_wdata       ;//i [31:0] 
assign s_axil_wstrb     =  M01_AXI_IIC_wstrb       ;//i [3:0]  
assign s_axil_wvalid    =  M01_AXI_IIC_wvalid      ;//i        
assign s_axil_wready    =  M01_AXI_IIC_wready      ;//o        
assign s_axil_bresp     =  M01_AXI_IIC_bresp       ;//o [1:0]  
assign s_axil_bvalid    =  M01_AXI_IIC_bvalid      ;//o        
assign s_axil_bready    =  M01_AXI_IIC_bready      ;//i        
assign s_axil_araddr    =  M01_AXI_IIC_araddr [3:0];//i [3:0]  
assign s_axil_arprot    =  M01_AXI_IIC_arprot      ;//i [2:0]  
assign s_axil_arvalid   =  M01_AXI_IIC_arvalid     ;//i        
assign s_axil_arready   =  M01_AXI_IIC_arready     ;//o        
assign s_axil_rdata     =  M01_AXI_IIC_rdata       ;//o [31:0] 
assign s_axil_rresp     =  M01_AXI_IIC_rresp       ;//o [1:0]  
assign s_axil_rvalid    =  M01_AXI_IIC_rvalid      ;//o        
assign s_axil_rready    =  M01_AXI_IIC_rready      ;//i        


wire [15:0] probe0;
wire        probe0_clk;
assign interp = 4'd0;

base base_inst     (
   .probe0               (probe0     ),
   .clk                  (probe0_clk ),
   .interp               (interp             ),
   .GPO_tri_o            (GPO_tri_o          ),
   .M01_AXI_IIC_araddr   (M01_AXI_IIC_araddr ),
   .M01_AXI_IIC_arprot   (M01_AXI_IIC_arprot ),
   .M01_AXI_IIC_arready  (M01_AXI_IIC_arready),
   .M01_AXI_IIC_arvalid  (M01_AXI_IIC_arvalid),
   .M01_AXI_IIC_awaddr   (M01_AXI_IIC_awaddr ),
   .M01_AXI_IIC_awprot   (M01_AXI_IIC_awprot ),
   .M01_AXI_IIC_awready  (M01_AXI_IIC_awready),
   .M01_AXI_IIC_awvalid  (M01_AXI_IIC_awvalid),
   .M01_AXI_IIC_bready   (M01_AXI_IIC_bready ),
   .M01_AXI_IIC_bresp    (M01_AXI_IIC_bresp  ),
   .M01_AXI_IIC_bvalid   (M01_AXI_IIC_bvalid ),
   .M01_AXI_IIC_rdata    (M01_AXI_IIC_rdata  ),
   .M01_AXI_IIC_rready   (M01_AXI_IIC_rready ),
   .M01_AXI_IIC_rresp    (M01_AXI_IIC_rresp  ),
   .M01_AXI_IIC_rvalid   (M01_AXI_IIC_rvalid ),
   .M01_AXI_IIC_wdata    (M01_AXI_IIC_wdata  ),
   .M01_AXI_IIC_wready   (M01_AXI_IIC_wready ),
   .M01_AXI_IIC_wstrb    (M01_AXI_IIC_wstrb  ),
   .M01_AXI_IIC_wvalid   (M01_AXI_IIC_wvalid ),
   .axi_aclk             (axi_aclk           ),//250M
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

i2c_master_axil # (
    .DEFAULT_PRESCALE ( 625), //250M / 0.4M = 2500/4 = 625
    .FIXED_PRESCALE   ( 0  ),
    .CMD_FIFO         ( 1  ),
    .CMD_FIFO_DEPTH   ( 32 ),
    .WRITE_FIFO       ( 1  ),
    .WRITE_FIFO_DEPTH ( 32 ),
    .READ_FIFO        ( 1  ),
    .READ_FIFO_DEPTH  ( 32 )
)
(
    .clk               (axi_aclk          ),//250M
    .rst               (GPO_tri_o[1]      ),
    .s_axil_awaddr     (s_axil_awaddr     ),
    .s_axil_awprot     (s_axil_awprot     ),
    .s_axil_awvalid    (s_axil_awvalid    ),
    .s_axil_awready    (s_axil_awready    ),
    .s_axil_wdata      (s_axil_wdata      ),
    .s_axil_wstrb      (s_axil_wstrb      ),
    .s_axil_wvalid     (s_axil_wvalid     ),
    .s_axil_wready     (s_axil_wready     ),
    .s_axil_bresp      (s_axil_bresp      ),
    .s_axil_bvalid     (s_axil_bvalid     ),
    .s_axil_bready     (s_axil_bready     ),
    .s_axil_araddr     (s_axil_araddr     ),
    .s_axil_arprot     (s_axil_arprot     ),
    .s_axil_arvalid    (s_axil_arvalid    ),
    .s_axil_arready    (s_axil_arready    ),
    .s_axil_rdata      (s_axil_rdata      ),
    .s_axil_rresp      (s_axil_rresp      ),
    .s_axil_rvalid     (s_axil_rvalid     ),
    .s_axil_rready     (s_axil_rready     ),

    .i2c_scl_i         (i2c_master_scl_i  ),
    .i2c_scl_o         (i2c_master_scl_o  ),
    .i2c_scl_t         (i2c_master_scl_t  ),
    .i2c_sda_i         (i2c_master_sda_i  ),
    .i2c_sda_o         (i2c_master_sda_o  ),
    .i2c_sda_t         (i2c_master_sda_t  )
);

wire dut_sda_i;
wire dut_scl_i;
wire dut_scl_t;
wire dut_sda_t;
wire dut_scl_o;
wire dut_sda_o;


assign i2c_master_scl_i = main_iic_scl;
assign        dut_scl_i = main_iic_scl;
assign   main_iic_scl   = (dut_scl_o & i2c_master_scl_o) ? 1'bz : 1'b0;
assign i2c_master_sda_i = main_iic_sda;
assign        dut_sda_i = main_iic_sda;
assign   main_iic_sda   = (dut_sda_o & i2c_master_sda_o) ? 1'bz : 1'b0;





wire [15:0]data_in  = source_mm2s_tdata[15:0];
wire [15:0]data_out;
wire [63:0]testvec ;



wire [15:0] testx= {
interp[1:0],
i2c_master_scl_i, 
i2c_master_scl_o,
i2c_master_scl_t,
i2c_master_sda_i,
i2c_master_sda_o,
i2c_master_sda_t,
main_iic_scl ,
main_iic_sda ,
dut_sda_i,
dut_scl_i,
dut_scl_t,
dut_sda_t,
dut_scl_o,
dut_sda_o };

assign probe0 = testx;

reg [7:0] cnt;
assign probe0_clk = cnt[7];
always @ (posedge tb_clk)
if(~tb_clk_locked)
	cnt <= 8'd0;
else 
	cnt <= cnt + 8'd1;




fir_top dut_top_inst(
    .clk        (tb_clk                 ),//i
    .rst        (GPO_tri_o[0]           ),//i
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
