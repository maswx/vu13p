//========================================================================
//        author   : masw
//        creattime: Sun 19 Mar 2023 04:40:04 PM CST
//========================================================================
//
//
//
//  Model: GPT-4
//  
// Q 用Verilog 写一个FIR 滤波器，其中输入输出端口的位宽为16bit, 一共33个系数，每个系数的位宽也都是16bit, 并且系数位宽可通过端口配置
//
// A  根据你的要求，下面是一个基于Verilog的FIR滤波器的实现。它有16位宽的输入和输出端口，33个16位宽的系数，且系数位宽可以通过端口配置。
// 
// Q 输入信号data_in是有符号数，直接使用乘法符号 * 并不正确，应该增加一个子模块，专门处理乘法，或者调用xilinx ultrascale plus 乘法器原语。另外 加法树太长了，应当在加法树处增加寄存器打拍
//
// A 你的建议是非常合理的。针对有符号数的乘法，我们可以使用专门的乘法子模块。这里我为你提供一个基于Xilinx UltraScale+ FPGA的有符号数乘法器原语DSP48E1的实现。
//
// Q 我希望在累加器处每4个加法打一拍。
//
// A 根据您的要求，我们可以在累加器处每4个加法后添加一个寄存器。以下是修改后的FIR滤波器模块：


//  verilog
module fir_filter (
    input wire         clk     , 
    input wire         rst     , 
    input wire  [15:0] data_in ,
	input       [15:0] coeff_00,
	input       [15:0] coeff_01,
	input       [15:0] coeff_02,
	input       [15:0] coeff_03,
	input       [15:0] coeff_04,
	input       [15:0] coeff_05,
	input       [15:0] coeff_06,
	input       [15:0] coeff_07,
	input       [15:0] coeff_08,
	input       [15:0] coeff_09,
	input       [15:0] coeff_10,
	input       [15:0] coeff_11,
	input       [15:0] coeff_12,
	input       [15:0] coeff_13,
	input       [15:0] coeff_14,
	input       [15:0] coeff_15,
	input       [15:0] coeff_16,
	input       [15:0] coeff_17,
	input       [15:0] coeff_18,
	input       [15:0] coeff_19,
	input       [15:0] coeff_20,
	input       [15:0] coeff_21,
	input       [15:0] coeff_22,
	input       [15:0] coeff_23,
	input       [15:0] coeff_24,
	input       [15:0] coeff_25,
	input       [15:0] coeff_26,
	input       [15:0] coeff_27,
	input       [15:0] coeff_28,
	input       [15:0] coeff_29,
	input       [15:0] coeff_30,
	input       [15:0] coeff_31,
	input       [15:0] coeff_32,
    output wire [31:0] data_out,
	output wire [63:0] testvec  //送到逻辑分析仪的测试矢量
);

    wire [15:0] coeff[32:0];

	assign coeff[00] = coeff_00;
	assign coeff[01] = coeff_01;
	assign coeff[02] = coeff_02;
	assign coeff[03] = coeff_03;
	assign coeff[04] = coeff_04;
	assign coeff[05] = coeff_05;
	assign coeff[06] = coeff_06;
	assign coeff[07] = coeff_07;
	assign coeff[08] = coeff_08;
	assign coeff[09] = coeff_09;
	assign coeff[10] = coeff_10;
	assign coeff[11] = coeff_11;
	assign coeff[12] = coeff_12;
	assign coeff[13] = coeff_13;
	assign coeff[14] = coeff_14;
	assign coeff[15] = coeff_15;
	assign coeff[16] = coeff_16;
	assign coeff[17] = coeff_17;
	assign coeff[18] = coeff_18;
	assign coeff[19] = coeff_19;
	assign coeff[20] = coeff_20;
	assign coeff[21] = coeff_21;
	assign coeff[22] = coeff_22;
	assign coeff[23] = coeff_23;
	assign coeff[24] = coeff_24;
	assign coeff[25] = coeff_25;
	assign coeff[26] = coeff_26;
	assign coeff[27] = coeff_27;
	assign coeff[28] = coeff_28;
	assign coeff[29] = coeff_29;
	assign coeff[30] = coeff_30;
	assign coeff[31] = coeff_31;
	assign coeff[32] = coeff_32;



    // 定义内部信号
    reg [15:0] data_buffer [32:0];
    wire [31:0] mult_result [32:0];
    wire [31:0] accum_result_stage1 [7:0];
    wire [31:0] accum_result_stage2 [1:0];
    wire [31:0] final_result;
    reg [31:0] final_result_d1;
    reg [31:0] final_result_d2;

    // 有符号数乘法器子模块实例化
    genvar i;
    wire [47:0] result[32:0];
    generate
		// 使用DSP48E1原语进行乘法运算
        for (i = 0; i < 33; i = i + 1) begin
			DSP48E1 dsp_inst (
    		    .CLK(1'b1), // 假设静态时钟
    		    .A(data_buffer[i]),
    		    .B(coeff[i]      ),
    		    .C(48'h0),
    		    .P(result[i]),
    		    .Opmode(7'b0000001), // 选择乘法模式
    		    .ALUMODE(4'b0000),   // 选择无ALU操作
    		    .CARRYINSEL(3'b000), // 选择无进位输入
    		    .CARRYIN(1'b0),      // 无进位输入
    		    .CEA(1'b1),          // A输入使能
    		    .CEB(1'b1),          // B输入使能
    		    .CEADIN(1'b1),       // AD输入使能
    		    .CEALUMODE(1'b1),    // ALU模式使能
    		    .CEC(1'b1),          // C输入使能
    		    .CECARRYIN(1'b1),    // 进位输入使能
    		    .CECTRL(1'b1),       // 控制信号使能
    		    .CEM(1'b1),          // M输入使能
    		    .CEP(1'b1),          // P输入使能
    		    .RSTALUMODE(1'b0),   // 无ALU复位
    		    .RSTALLCARRYIN(1'b0),// 无进位复位
    		    .RSTCTRL(1'b0),      // 无控制信号复位
    		    .RSTM(1'b0),         // 无M复位
    		    .RSTP(1'b0)          // 无P复位
    		);
			assign mult_result[i] = result[i][31:0];
        end
    endgenerate

    // 累加器 - 第一级（每4个加法）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                accum_result_stage1[i] <= 32'h0;
            end
        end else begin
            for (i = 0; i < 8; i = i + 1) begin
                accum_result_stage1[i] <= mult_result[4*i] + mult_result[4*i+1] + mult_result[4*i+2] + mult_result[4*i+3];
            end
        end
    end

    // 累加器 - 第二级（每2个加法）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 2; i = i + 1) begin
                accum_result_stage2[i] <= 32'h0;
            end
        end else begin
            for (i = 0; i < 2; i = i + 1) begin
                accum_result_stage2[i] <= accum_result_stage1[4*i] + accum_result_stage1[4*i+1] + accum_result_stage1[4*i+2] + accum_result_stage1[4*i+3];
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
			mult_result_d1 <= 32'd0;
    		mult_result_d2 <= 32'd0;
        end else begin
			mult_result_d1 <= mult_result[32];
    		mult_result_d2 <= mult_result_d1;
        end
    end



    // 累加器 - 最后一级
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            final_result <= 32'h0;
        end else begin
            final_result <= accum_result_stage2[0] + accum_result_stage2[1] + mult_result_d2;
        end
    end

	assign data_out = final_result ;

    // 延迟线（用于存储输入数据）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (integer i = 0; i < 33; i = i + 1) begin
                data_buffer[i] <= 16'h0;
            end
        end else begin
            data_buffer[32] <= data_buffer[31];
            for (integer i = 31; i > 0; i = i - 1) begin
                data_buffer[i] <= data_buffer[i-1];
            end
            data_buffer[0] <= data_in;
        end
    end


assign testvec = {
	accum_result_stage1 [0][31:16] ,
	accum_result_stage2 [0][31:16] ,
	data_in[15:0],
	coeff[1][7:0],
	coeff[0][7:0]
};

endmodule


module signed_multiplier (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [31:0] product
);

    // 将输入信号转换为有符号数
    //wire signed [15:0] a_signed = $signed(a);
    //wire signed [15:0] b_signed = $signed(b);
    wire signed [15:0] a_signed = a;
    wire signed [15:0] b_signed = b;


endmodule

