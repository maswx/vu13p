// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: xilinx.com:ip:xdma:4.1
// IP Revision: 20

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
xdma_base your_instance_name (
  .sys_clk(sys_clk),                        // input wire sys_clk
  .sys_clk_gt(sys_clk_gt),                  // input wire sys_clk_gt
  .sys_rst_n(sys_rst_n),                    // input wire sys_rst_n
  .user_lnk_up(user_lnk_up),                // output wire user_lnk_up
  .pci_exp_txp(pci_exp_txp),                // output wire [15 : 0] pci_exp_txp
  .pci_exp_txn(pci_exp_txn),                // output wire [15 : 0] pci_exp_txn
  .pci_exp_rxp(pci_exp_rxp),                // input wire [15 : 0] pci_exp_rxp
  .pci_exp_rxn(pci_exp_rxn),                // input wire [15 : 0] pci_exp_rxn
  .axi_aclk(axi_aclk),                      // output wire axi_aclk
  .axi_aresetn(axi_aresetn),                // output wire axi_aresetn
  .usr_irq_req(usr_irq_req),                // input wire [7 : 0] usr_irq_req
  .usr_irq_ack(usr_irq_ack),                // output wire [7 : 0] usr_irq_ack
  .msi_enable(msi_enable),                  // output wire msi_enable
  .msi_vector_width(msi_vector_width),      // output wire [2 : 0] msi_vector_width
  .m_axi_awready(m_axi_awready),            // input wire m_axi_awready
  .m_axi_wready(m_axi_wready),              // input wire m_axi_wready
  .m_axi_bid(m_axi_bid),                    // input wire [3 : 0] m_axi_bid
  .m_axi_bresp(m_axi_bresp),                // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid(m_axi_bvalid),              // input wire m_axi_bvalid
  .m_axi_arready(m_axi_arready),            // input wire m_axi_arready
  .m_axi_rid(m_axi_rid),                    // input wire [3 : 0] m_axi_rid
  .m_axi_rdata(m_axi_rdata),                // input wire [511 : 0] m_axi_rdata
  .m_axi_rresp(m_axi_rresp),                // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast(m_axi_rlast),                // input wire m_axi_rlast
  .m_axi_rvalid(m_axi_rvalid),              // input wire m_axi_rvalid
  .m_axi_awid(m_axi_awid),                  // output wire [3 : 0] m_axi_awid
  .m_axi_awaddr(m_axi_awaddr),              // output wire [63 : 0] m_axi_awaddr
  .m_axi_awlen(m_axi_awlen),                // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize(m_axi_awsize),              // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst(m_axi_awburst),            // output wire [1 : 0] m_axi_awburst
  .m_axi_awprot(m_axi_awprot),              // output wire [2 : 0] m_axi_awprot
  .m_axi_awvalid(m_axi_awvalid),            // output wire m_axi_awvalid
  .m_axi_awlock(m_axi_awlock),              // output wire m_axi_awlock
  .m_axi_awcache(m_axi_awcache),            // output wire [3 : 0] m_axi_awcache
  .m_axi_wdata(m_axi_wdata),                // output wire [511 : 0] m_axi_wdata
  .m_axi_wstrb(m_axi_wstrb),                // output wire [63 : 0] m_axi_wstrb
  .m_axi_wlast(m_axi_wlast),                // output wire m_axi_wlast
  .m_axi_wvalid(m_axi_wvalid),              // output wire m_axi_wvalid
  .m_axi_bready(m_axi_bready),              // output wire m_axi_bready
  .m_axi_arid(m_axi_arid),                  // output wire [3 : 0] m_axi_arid
  .m_axi_araddr(m_axi_araddr),              // output wire [63 : 0] m_axi_araddr
  .m_axi_arlen(m_axi_arlen),                // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize(m_axi_arsize),              // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst(m_axi_arburst),            // output wire [1 : 0] m_axi_arburst
  .m_axi_arprot(m_axi_arprot),              // output wire [2 : 0] m_axi_arprot
  .m_axi_arvalid(m_axi_arvalid),            // output wire m_axi_arvalid
  .m_axi_arlock(m_axi_arlock),              // output wire m_axi_arlock
  .m_axi_arcache(m_axi_arcache),            // output wire [3 : 0] m_axi_arcache
  .m_axi_rready(m_axi_rready),              // output wire m_axi_rready
  .m_axil_awaddr(m_axil_awaddr),            // output wire [31 : 0] m_axil_awaddr
  .m_axil_awprot(m_axil_awprot),            // output wire [2 : 0] m_axil_awprot
  .m_axil_awvalid(m_axil_awvalid),          // output wire m_axil_awvalid
  .m_axil_awready(m_axil_awready),          // input wire m_axil_awready
  .m_axil_wdata(m_axil_wdata),              // output wire [31 : 0] m_axil_wdata
  .m_axil_wstrb(m_axil_wstrb),              // output wire [3 : 0] m_axil_wstrb
  .m_axil_wvalid(m_axil_wvalid),            // output wire m_axil_wvalid
  .m_axil_wready(m_axil_wready),            // input wire m_axil_wready
  .m_axil_bvalid(m_axil_bvalid),            // input wire m_axil_bvalid
  .m_axil_bresp(m_axil_bresp),              // input wire [1 : 0] m_axil_bresp
  .m_axil_bready(m_axil_bready),            // output wire m_axil_bready
  .m_axil_araddr(m_axil_araddr),            // output wire [31 : 0] m_axil_araddr
  .m_axil_arprot(m_axil_arprot),            // output wire [2 : 0] m_axil_arprot
  .m_axil_arvalid(m_axil_arvalid),          // output wire m_axil_arvalid
  .m_axil_arready(m_axil_arready),          // input wire m_axil_arready
  .m_axil_rdata(m_axil_rdata),              // input wire [31 : 0] m_axil_rdata
  .m_axil_rresp(m_axil_rresp),              // input wire [1 : 0] m_axil_rresp
  .m_axil_rvalid(m_axil_rvalid),            // input wire m_axil_rvalid
  .m_axil_rready(m_axil_rready),            // output wire m_axil_rready
  .mcap_design_switch(mcap_design_switch),  // output wire mcap_design_switch
  .cap_req(cap_req),                        // output wire cap_req
  .cap_gnt(cap_gnt),                        // input wire cap_gnt
  .cap_rel(cap_rel)                        // input wire cap_rel
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file xdma_base.v when simulating
// the core, xdma_base. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

