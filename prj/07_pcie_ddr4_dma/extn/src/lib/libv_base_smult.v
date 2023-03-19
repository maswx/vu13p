/** #TOKEN begin document generation 
### libv_base_smult.v
```verilog
//template
libv_base_smult #(8,8,8) libv_base_smult_inst(.a(), .b(), .o() );
libv_base_smult #(8,8,8, "REG") libv_base_smult_inst(.clk(), .rst(), .ena(), .a(), .b(), .o());
*/
module libv_base_smult
#(
	parameter WIA =  8, 
	parameter WIB =  8, 
	parameter WO  = 15,
	parameter REG = "NO"
)(
	input           clk,
	input           rst,
	input           ena,
	input [WIA-1:0] a, 
	input [WIB-1:0] b, 
	output [WO-1:0] o
);
///# TOKEN end document generation 

wire [WIA+WIB-1:0] a_mult_b = $signed(a) * $signed(b);
wire [WIA+WIB-2:0] a_mult_b_limt = ( a_mult_b[WIA+WIB-2] ^ a_mult_b[WIA+WIB-1] ) ?  {a_mult_b[WIA+WIB-1], {  (WIA+WIB-2){!a_mult_b[WIA+WIB-1]}}  } :a_mult_b[WIA+WIB-2:0];


generate
	if(REG == "NO")
		begin
		assign o = a_mult_b_limt[WIA+WIB-2:WIA+WIB-2-WO+1];
		end
	else 
		begin
		reg [WO-1:0]reg_dat;
		always @ (posedge clk or posedge rst)
		if(rst) 
			reg_dat <= {WO{1'b0}};
		else if(ena)
			reg_dat <= a_mult_b_limt[WIA+WIB-2:WIA+WIB-2-WO+1];
		assign o = reg_dat;
		end

endgenerate 






endmodule 












