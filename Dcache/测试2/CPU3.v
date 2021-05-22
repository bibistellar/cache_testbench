`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 21:33:51
// Design Name: 
// Module Name: CPU3
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


module CPU3(
    input wire clk,
    input wire rst,
    input wire rom_valid_i1,
    input wire rom_valid_i2,
    input wire[31:0] rom_data_i1,
    input wire[31:0] rom_data_i2,
    output reg[31:0] rom_addr_o1,
    output reg[31:0] rom_addr_o2,

    input wire[31:0] dcache_data_i,
    input wire stallreq_from_dcahce,
    output reg[31:0] dcache_raddr_o,
    output reg[31:0] dcache_waddr_o,
    output reg[31:0] dcache_wdata_o,
    output reg dcache_wreq_o,
    output reg dcache_rreq_o,
    output reg[3:0] dcache_sel_o,

    input wire[127:0] data_from_memory,
    output wire[127:0] data_from_cpu_way0,
    output wire[127:0] data_from_cpu_way1
    );
    reg [3:0] state;
    reg [3:0] count;
    reg [31:0] data_way0[3:0];
    reg [31:0] data_way1[3:0];
    reg [31:0]addr_way0_block0 = 32'b0000_0000_0000_0000_00000_0000_0000_0000;
    reg [31:0]addr_way1_block0 = 32'b0000_0000_0000_0000_00001_0000_0000_0000;
    reg [31:0]addr_data_new = 32'b0000_0000_0000_0000_00010_0000_0000_0000;

    assign data_from_cpu_way0 = {data_way0[0],data_way0[1],data_way0[2],data_way0[3]};
    assign data_from_cpu_way1 = {data_way1[0],data_way1[1],data_way1[2],data_way1[3]};



    initial begin
        //0路第0块数据
        data_way0[0] = {$random} % 32'hffff_ffff;
        data_way0[1] = {$random} % 32'hffff_ffff;
        data_way0[2] = {$random} % 32'hffff_ffff;
        data_way0[3] = {$random} % 32'hffff_ffff;

        //1路第0块数据
        data_way1[0] = {$random} % 32'hffff_ffff;
        data_way1[1] = {$random} % 32'hffff_ffff;
        data_way1[2] = {$random} % 32'hffff_ffff;
        data_way1[3] = {$random} % 32'hffff_ffff;
    end

    always @(posedge clk) begin
        if(rst)begin
            rom_addr_o1 <= 32'b0;
            rom_addr_o2 <= 32'b0;
            dcache_raddr_o <= 32'b0;
            dcache_waddr_o <= 32'b0;
            dcache_wdata_o <= 32'b0;
            dcache_wreq_o <= 32'b0;
            dcache_rreq_o <= 32'b0;
            dcache_sel_o <= 32'b0;
            count <= 4'b0;
            state <= 4'b0;
        end
        else begin
            if(state == 4'b0 && !stallreq_from_dcahce)begin
                //写入0路0块数据
                if(count <= 3)begin
                    dcache_waddr_o <= {addr_way0_block0[31:4],count,addr_way0_block0[1:0]};
                    dcache_wdata_o <= data_way0[count];
                    dcache_wreq_o <= 1'b1;
                    dcache_sel_o <= 4'b1111;
                    count <= count + 1'b1;
                end
                else begin
                    state <= state +1'b1;
                    count <= 4'b0;
                end
            end

            //写入1路0块数据
            else if(state == 4'b0001 && !stallreq_from_dcahce)begin
                if(count <= 3)begin
                    dcache_waddr_o <= {addr_way1_block0[31:4],count,addr_way1_block0[1:0]};
                    dcache_wdata_o <= data_way1[count];
                    dcache_wreq_o <= 1'b1;
                    dcache_sel_o <= 4'b1111;
                    count <= count + 1'b1;
                end
                else begin
                    state <= state +1'b1;
                    count <= 4'b0;
                end
            end

            //读取当前dcache中没有的数据
            else if(state == 4'b0010 && !stallreq_from_dcahce)begin
                dcache_raddr_o <= addr_data_new;
                dcache_rreq_o <= 1'b1;
                state <= state + 1'b1;
            end

            //判断返回数据的正确性
            else if(state == 4'b0011 && !stallreq_from_dcahce)begin
                if(dcache_data_i == data_from_memory[31:0])begin
                    $display("CPU gets the right data!\n");
                    $stop;
                end
                else begin
                    $display("CPU gets the wrong data!\n");
                    $stop;
                end
                state <= state +1'b1;
            end
        end
    end
endmodule