//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年12月02日 星期六 21时47分57秒
//========================================================================



// cp .v file from alex 
// 致敬Alex的工作。


// 模块集成  STARTUPE3

module alex_ail_qspi#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)

)(
    input  wire                     axi_aclk   ,
    input  wire                     axi_aresetn,

    /*
     * AXI lite slave interfaces
     */
    input  wire [ADDR_WIDTH-1:0]    s_axil_awaddr ,
    input  wire [2:0]               s_axil_awprot ,
    input  wire                     s_axil_awvalid,
    output wire                     s_axil_awready,
    input  wire [DATA_WIDTH-1:0]    s_axil_wdata  ,
    input  wire [STRB_WIDTH-1:0]    s_axil_wstrb  ,
    input  wire                     s_axil_wvalid ,
    output wire                     s_axil_wready ,
    output wire [1:0]               s_axil_bresp  ,
    output wire                     s_axil_bvalid ,
    input  wire                     s_axil_bready ,
    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr ,
    input  wire [2:0]               s_axil_arprot ,
    input  wire                     s_axil_arvalid,
    output wire                     s_axil_arready,
    output wire [DATA_WIDTH-1:0]    s_axil_rdata  ,
    output wire [1:0]               s_axil_rresp  ,
    output wire                     s_axil_rvalid ,
    input  wire                     s_axil_rready 
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

retg  ctrl_reg_rd_ack_reg ;

axil_reg_if axil_reg_if_inst (
    .clk              ( axi_aclk          ),
    .rst              (~axi_aresetn       ),

    .s_axil_awaddr    (s_axil_awaddr      ),//output wire [ADDR_WIDTH-1:0]    m00_axil_awaddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    .s_axil_awprot    (s_axil_awprot      ),//output wire [2:0]               m00_axil_awprot,   <--> input  wire [2:0]             s_axil_awprot,
    .s_axil_awvalid   (s_axil_awvalid     ),//output wire                     m00_axil_awvalid,  <--> input  wire                   s_axil_awvalid,
    .s_axil_awready   (s_axil_awready     ),//input  wire                     m00_axil_awready,  <--> output wire                   s_axil_awready,
    .s_axil_wdata     (s_axil_wdata       ),//output wire [DATA_WIDTH-1:0]    m00_axil_wdata,    <--> input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    .s_axil_wstrb     (s_axil_wstrb       ),//output wire [STRB_WIDTH-1:0]    m00_axil_wstrb,    <--> input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    .s_axil_wvalid    (s_axil_wvalid      ),//output wire                     m00_axil_wvalid,   <--> input  wire                   s_axil_wvalid,
    .s_axil_wready    (s_axil_wready      ),//input  wire                     m00_axil_wready,   <--> output wire                   s_axil_wready,
    .s_axil_bresp     (s_axil_bresp       ),//input  wire [1:0]               m00_axil_bresp,    <--> output wire [1:0]             s_axil_bresp,
    .s_axil_bvalid    (s_axil_bvalid      ),//input  wire                     m00_axil_bvalid,   <--> output wire                   s_axil_bvalid,
    .s_axil_bready    (s_axil_bready      ),//output wire                     m00_axil_bready,   <--> input  wire                   s_axil_bready,
    .s_axil_araddr    (s_axil_araddr      ),//output wire [ADDR_WIDTH-1:0]    m00_axil_araddr,   <--> input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    .s_axil_arprot    (s_axil_arprot      ),//output wire [2:0]               m00_axil_arprot,   <--> input  wire [2:0]             s_axil_arprot,
    .s_axil_arvalid   (s_axil_arvalid     ),//output wire                     m00_axil_arvalid,  <--> input  wire                   s_axil_arvalid,
    .s_axil_arready   (s_axil_arready     ),//input  wire                     m00_axil_arready,  <--> output wire                   s_axil_arready,
    .s_axil_rdata     (s_axil_rdata       ),//input  wire [DATA_WIDTH-1:0]    m00_axil_rdata,    <--> output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    .s_axil_rresp     (s_axil_rresp       ),//input  wire [1:0]               m00_axil_rresp,    <--> output wire [1:0]             s_axil_rresp,
    .s_axil_rvalid    (s_axil_rvalid      ),//input  wire                     m00_axil_rvalid,   <--> output wire                   s_axil_rvalid,
    .s_axil_rready    (s_axil_rready      ),//output wire                     m00_axil_rready    <--> input  wire                   s_axil_rready,

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
    .reg_rd_ack       (ctrl_reg_rd_ack_reg) //input  wire                   reg_rd_ack 
);

reg       fpga_reboot_reg     ;
reg       fpga_boot_reg       ;
reg       qspi_clk_reg        ;
reg       qspi_cs_reg         ;
reg [3:0] qspi_dq_o_reg       ;
reg [3:0] qspi_dq_oe_reg      ;
//写入
always @ (posedge axi_aclk or negedge axi_aresetn)
	if(!axi_aresetn) begin
		fpga_boot_reg   <= 1'd0;
		fpga_reboot_reg <= 1'd0;
        qspi_clk_reg    <= 1'b0;
        qspi_cs_reg     <= 1'b1;
        qspi_dq_o_reg   <= 4'd0;
        qspi_dq_oe_reg  <= 4'd0;
	end
	else if(reg_wr_en)
	begin
		case({reg_wr_addr[7:2],2'b00})
			8'h0: begin
				if(reg_wr_strb[0]) 
					fpga_reboot_reg <= reg_wr_data[0];
			end
            // QSPI flash
            8'h6C: begin
                // SPI flash ctrl: format
                fpga_boot_reg <= ctrl_reg_wr_data == 32'hFEE1DEAD;
            end
            8'h70: begin
                // SPI flash ctrl: control 0
                if (reg_wr_strb[0]) begin
                    qspi_dq_o_reg <= ctrl_reg_wr_data[3:0];
                end
                if (reg_wr_strb[1]) begin
                    qspi_dq_oe_reg <= ctrl_reg_wr_data[11:8];
                end
                if (reg_wr_strb[2]) begin
                    qspi_clk_reg <= ctrl_reg_wr_data[16];
                    qspi_cs_reg <= ctrl_reg_wr_data[17];
                end
            end
		endcase
	end
//读出
always @ (posedge axi_aclk or negedge axi_aresetn)
	if(!axi_aresetn)
		reg_rd_data <= 32'd0;
	else if(reg_rd_en)
	begin
		case({reg_rd_addr[7:2],2'b00})
			4'h0: reg_rd_data <= {31'd0, fpga_reboot_reg};
            // QSPI flash
            8'h60: reg_rd_data <= 32'h0000C120;             // SPI flash ctrl: Type
            8'h64: reg_rd_data <= 32'h00000200;             // SPI flash ctrl: Version
            8'h68: reg_rd_data <= RB_DRP_QSFP0_BASE;        // SPI flash ctrl: Next header
            8'h6C: begin
                // SPI flash ctrl: format
                reg_rd_data[3:0]   <= 2;                   // configuration (two segments)
                reg_rd_data[7:4]   <= 0;                   // default segment
                reg_rd_data[11:8]  <= 1;                   // fallback segment
                reg_rd_data[31:12] <= 32'h01000000 >> 12;  // first segment size (32 M)
            end
            8'h70: begin
                // SPI flash ctrl: control 0
                reg_rd_data[ 3:0] <= qspi_dq_i_reg ;
                reg_rd_data[11:8] <= qspi_dq_oe_reg;
                reg_rd_data[  16] <= qspi_clk_reg  ;
                reg_rd_data[  17] <= qspi_cs_reg   ;
				// [ log by masw@20231202 22:34]: 
				//   log by masw@masw: Alex的QSPI的效率也太低了吧，竟然是用模拟
				// QSPI波形的方案。最好用DMA的方案呀，估计Alex也没空搞
            end
		endcase
	end

always @ (posedge axi_aclk or negedge axi_aresetn)
	if(!axi_aresetn)
		ctrl_reg_rd_ack_reg <= 1'd0;
	else
		ctrl_reg_rd_ack_reg <= reg_rd_en;





// startupe3 instance
STARTUPE3
startupe3_inst (
    .CFGCLK    (                 ),
    .CFGMCLK   (                 ),
    .DI        (qspi_dq_int      ),
    .DO        (qspi_dq_o_reg    ),
    .DTS       (~qspi_dq_oe_reg  ),
    .EOS       (                 ),
    .FCSBO     (qspi_cs_reg      ),
    .FCSBTS    (1'b0             ),
    .GSR       (1'b0             ),
    .GTS       (1'b0             ),
    .KEYCLEARB (1'b1             ),
    .PACK      (1'b0             ),
    .PREQ      (                 ),
    .USRCCLKO  (qspi_clk_reg     ),
    .USRCCLKTS (1'b0             ),
    .USRDONEO  (1'b0             ),
    .USRDONETS (1'b1             )
);

//
//========================================================================
//========================================================================
//========================================================================

// FPGA boot
wire reboot = fpga_reboot_reg || fpga_boot_reg ;

reg fpga_boot_sync_reg_0 = 1'b0;
reg fpga_boot_sync_reg_1 = 1'b0;
reg fpga_boot_sync_reg_2 = 1'b0;

wire icap_avail;
reg [2:0] icap_state = 0;
reg icap_csib_reg = 1'b1;
reg icap_rdwrb_reg = 1'b0;
reg [31:0] icap_di_reg = 32'hffffffff;

wire [31:0] icap_di_rev;

assign icap_di_rev[ 7] = icap_di_reg[ 0];
assign icap_di_rev[ 6] = icap_di_reg[ 1];
assign icap_di_rev[ 5] = icap_di_reg[ 2];
assign icap_di_rev[ 4] = icap_di_reg[ 3];
assign icap_di_rev[ 3] = icap_di_reg[ 4];
assign icap_di_rev[ 2] = icap_di_reg[ 5];
assign icap_di_rev[ 1] = icap_di_reg[ 6];
assign icap_di_rev[ 0] = icap_di_reg[ 7];

assign icap_di_rev[15] = icap_di_reg[ 8];
assign icap_di_rev[14] = icap_di_reg[ 9];
assign icap_di_rev[13] = icap_di_reg[10];
assign icap_di_rev[12] = icap_di_reg[11];
assign icap_di_rev[11] = icap_di_reg[12];
assign icap_di_rev[10] = icap_di_reg[13];
assign icap_di_rev[ 9] = icap_di_reg[14];
assign icap_di_rev[ 8] = icap_di_reg[15];

assign icap_di_rev[23] = icap_di_reg[16];
assign icap_di_rev[22] = icap_di_reg[17];
assign icap_di_rev[21] = icap_di_reg[18];
assign icap_di_rev[20] = icap_di_reg[19];
assign icap_di_rev[19] = icap_di_reg[20];
assign icap_di_rev[18] = icap_di_reg[21];
assign icap_di_rev[17] = icap_di_reg[22];
assign icap_di_rev[16] = icap_di_reg[23];

assign icap_di_rev[31] = icap_di_reg[24];
assign icap_di_rev[30] = icap_di_reg[25];
assign icap_di_rev[29] = icap_di_reg[26];
assign icap_di_rev[28] = icap_di_reg[27];
assign icap_di_rev[27] = icap_di_reg[28];
assign icap_di_rev[26] = icap_di_reg[29];
assign icap_di_rev[25] = icap_di_reg[30];
assign icap_di_rev[24] = icap_di_reg[31];

always @ (posedge axi_aclk )
    case (icap_state)
        0: begin
            icap_state <= 0;
            icap_csib_reg <= 1'b1;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'hffffffff; // dummy word

            if (fpga_boot_sync_reg_2 && icap_avail) begin
                icap_state <= 1;
                icap_csib_reg <= 1'b0;
                icap_rdwrb_reg <= 1'b0;
                icap_di_reg <= 32'hffffffff; // dummy word
            end
        end
        1: begin
            icap_state <= 2;
            icap_csib_reg <= 1'b0;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'hAA995566; // sync word
        end
        2: begin
            icap_state <= 3;
            icap_csib_reg <= 1'b0;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'h20000000; // type 1 noop
        end
        3: begin
            icap_state <= 4;
            icap_csib_reg <= 1'b0;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'h30008001; // write 1 word to CMD
        end
        4: begin
            icap_state <= 5;
            icap_csib_reg <= 1'b0;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'h0000000F; // IPROG
        end
        5: begin
            icap_state <= 0;
            icap_csib_reg <= 1'b0;
            icap_rdwrb_reg <= 1'b0;
            icap_di_reg <= 32'h20000000; // type 1 noop
        end
    endcase

    fpga_boot_sync_reg_0 <= reboot ;
    fpga_boot_sync_reg_1 <= fpga_boot_sync_reg_0;
    fpga_boot_sync_reg_2 <= fpga_boot_sync_reg_1;
end

ICAPE3
icape3_inst (
    .AVAIL(icap_avail),
    .CLK(axi_aclk),
    .CSIB(icap_csib_reg),
    .I(icap_di_rev),
    .O(),
    .PRDONE(),
    .PRERROR(),
    .RDWRB(icap_rdwrb_reg)
);

endmodule 

