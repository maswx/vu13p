//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2025年01月13日 星期一 23时51分44秒
//========================================================================



module alivu13p_top(
	input  [   0:0] pcie_ref_clk_p      ,
	input  [   0:0] pcie_ref_clk_n      ,
	input  [  15:0] pcie_lane_rxp       ,
	input  [  15:0] pcie_lane_rxn       ,
	output [  15:0] pcie_lane_txp       ,
	output [  15:0] pcie_lane_txn       ,
	input           pcie_perst_n        ,
	output          pcie_link_up        ,
	output [   7:0] LED
);




basepcie basepcie_inst (
	.LED            (LED            ),
    .pcie_lane_rxn  (pcie_lane_rxn  ),
    .pcie_lane_rxp  (pcie_lane_rxp  ),
    .pcie_lane_txn  (pcie_lane_txn  ),
    .pcie_lane_txp  (pcie_lane_txp  ),
    .pcie_link_up   (pcie_link_up   ),
    .pcie_perst_n   (pcie_perst_n   ),
    .pcie_ref_clk_n (pcie_ref_clk_n ),
    .pcie_ref_clk_p (pcie_ref_clk_p ) 
);
endmodule

