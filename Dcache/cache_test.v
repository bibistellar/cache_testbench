`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/14 00:52:34
// Design Name: 
// Module Name: cache_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_test(
    );
    reg clk;
    reg rst;
    wire [31:0] data;
    wire [31:0] addr;
    wire ram_re_o;
    wire ram_sel_o;

    initial begin
        clk <= 1'b1;
        forever #5 clk = ~clk;
    end

    initial begin
        rst <= 1'b1;
        #20 rst <= 1'b0;
    end

    Dcache dcache0(
        .clk(clk),
        .rst(rst)
    );
    

    CPU CPU0(
        .clk(clk),
        .rst(rst),
        .ram_data_o(data),
        .ram_waddr_o(addr),
        .ram_re_o(ram_re_o),
        .ram_sel_o(ram_sel_o)
    );
endmodule
