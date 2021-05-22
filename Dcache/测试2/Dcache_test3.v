`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/19 12:10:00
// Design Name: 
// Module Name: Icache_test
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


module Dcache_test3(

    );
    reg clk;
    reg rst;
    wire [31:0] data_from_cpu;
    wire [31:0] data_from_cache;
    wire [31:0] dcache_waddr_o;
    wire [31:0]dcache_raddr_o;
    wire dcache_rreq_o;
    wire [3:0]dcache_sel_o;
    wire dcache_wreq_o;
    wire data_ok;

    wire [127:0] data_from_cpu0;
    wire [127:0] data_from_cpu1;

    wire wr_req;
    wire [127:0]wr_data;
    wire [31:0] wr_addr;
    wire wr_rdy;

    wire rd_rdy;
    wire rd_req;
    wire [31:0] rd_addr;
    wire [127:0] ret_data;


    initial begin
        clk = 1'b0;
        #5 forever clk = ~clk;
    end
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
    end

    /*Cache cache0(
        .clk(clk),
        .rst(rst),
        .valid(1'b1),
        .index(dcache_raddr_o[31:12]),
        .tag(dcache_raddr_o[11:4]),
        .offset(dcache_raddr_o[3:0]),
        .data_ok(data_ok),
        .rdata(data_from_cache),

        .rd_req(rd_req),
        .rd_addr(rd_addr),
        .ret_valid(ret_valid),
        .ret_data(ret_data)
    );*/
    CPU3 CPU(
        .clk(clk),
        .rst(rst),
        .dcache_data_i(data_from_cache),
        .dcache_raddr_o(dcache_raddr_o),
        .dcache_waddr_o(dcache_waddr_o),
        .dcache_wdata_o(data_from_cpu),
        .dcache_wreq_o(dcache_wreq_o),
        .dcache_rreq_o(dcache_rreq_o),
        .dcache_sel_o(dcache_sel_o),
        .stallreq_from_dcahce(data_ok),

        .data_from_memory(ret_data),
        .data_from_cpu0(data_from_cpu0),
        .data_from_cpu1(data_from_cpu1)
    );
    AXI3 axi0(
        .clk(clk),
        .rst(rst),
        
        .wr_req(wr_req),
        .wr_data(wr_data),
        .wr_addr(wr_addr),
        .wr_rdy(wr_rdy),

        .rd_rdy(rd_rdy),
        .rd_req(rd_req),
        .rd_addr(rd_addr),

        .ret_valid(ret_valid),
        .ret_data(ret_data),

        .data_from_cpu0(data_from_cpu0),
        .data_from_cpu1(data_from_cpu1)
    );
endmodule
