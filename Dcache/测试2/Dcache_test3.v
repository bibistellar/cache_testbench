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
    wire [31:0] dcache_addr_o;
    wire dcache_rreq_o;
    wire [3:0]dcache_sel_o;
    wire dcache_wreq_o;
    wire data_ok;

    wire [127:0] data_from_cpu0;
    wire [127:0] data_from_cpu1;
    wire [127:0] data_from_axi;
    wire [127:0] data_from_cache_to_axi;

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
        forever #5 clk = ~clk;
    end
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
    end

DCache DCache_u(.clk(clk), .rst(rst), 
                    .rvalid_i(dcache_rreq_o), .addr_i(dcache_addr_o), 
                    .wvalid_i(dcache_wreq_o), .wsel_i(dcache_sel_o), .wdata_i(data_from_cpu), 
                    .data_ok_o(data_ok_o), .rdata_o(data_from_cache), 
                    .rd_req_o(rd_req), .rd_addr_o(rd_addr), 
                    .ret_valid_i(ret_valid), .ret_data_i(ret_data), 
                    .wr_req_o(wr_req), .wr_addr_o(wr_addr), .wr_data_o(wr_data), .wr_rdy_i(wr_rdy),
                    .stall_o(stall));
    CPU3 CPU(
        .clk(clk),
        .rst(rst),
        .dcache_data_i(data_from_cache),
        .dcache_addr_o(dcache_addr_o),
        .dcache_wdata_o(data_from_cpu),
        .dcache_wreq_o(dcache_wreq_o),
        .dcache_rreq_o(dcache_rreq_o),
        .dcache_sel_o(dcache_sel_o),
        .stallreq_from_dcahce(stall),
        .data_ok(data_ok),

        .data_from_memory(ret_data),
        .data_from_cpu_way0(data_from_cpu0),
        .data_from_cpu_way1(data_from_cpu1)
    );
    AXI3 axi0(
        .clk(clk),
        .rst(rst),
        
        .wr_req(wr_req),
        .wr_data(data_from_cache_to_axi),
        .wr_addr(wr_addr),
        .wr_rdy(wr_rdy),

        .rd_rdy(rd_rdy),
        .rd_req(rd_req),
        .rd_addr(rd_addr),

        .ret_valid(ret_valid),
        .ret_data(ret_data),

        .data_from_cpu0(data_from_cpu0),
        .data_from_cpu1(data_from_cpu1),

        .data_from_axi(data_from_axi)
    );
endmodule
