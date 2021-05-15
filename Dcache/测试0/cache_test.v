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
    wire [31:0] data_from_cpu;
    wire [31:0] data_from_cache;
    wire [31:0] addr;
    wire dcache_rreq_o;
    wire dcache_wsel_o;

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
        .dcache_data_i(data_from_cache),
        .dcache_wdata_o(data_from_cpu),
        .dcache_waddr_o(addr),
        .dcache_rreq_o(dcache_rreq_o),
        .dcache_wsel_o(dcache_wsel_o)
    );
endmodule

