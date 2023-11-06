/*

Copyright (c) 2023 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * Pin name UART
 */
module pin_uart #(
    parameter NAME = "AF12"
)
(
    input wire clk,
    input wire rst,
    input wire shift,
    output wire out
);

reg [63:0] data;

initial begin
    data = {64{1'b1}};
    data[0] = 1'b0;
    data[8:1] = (NAME >> 24) & 8'hff;
    data[9] = 1'b1;
    data[10] = 1'b0;
    data[18:11] = (NAME >> 16) & 8'hff;
    data[19] = 1'b1;
    data[20] = 1'b0;
    data[28:21] = (NAME >> 8) & 8'hff;
    data[29] = 1'b1;
    data[30] = 1'b0;
    data[38:31] = (NAME >> 0) & 8'hff;
    data[39] = 1'b1;
end

reg out_reg = 1'b1;
reg [5:0] ptr_reg = 0;

assign out = out_reg;

always @(posedge clk) begin
    if (shift) begin
        out_reg <= data[ptr_reg];
        if (!(&ptr_reg)) begin
            ptr_reg <= ptr_reg + 1;
        end
    end

    if (rst) begin
        out_reg <= 1'b1;
        ptr_reg <= 0;
    end
end

endmodule

`resetall
