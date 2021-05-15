`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/14 00:53:01
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 本测试模块用于测试Dcache的顺序写入命中和顺序写出命中功能。随机生成16组数据，然后顺序写入Dcache中，写一个读一个。
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input wire clk,
    input wire rst,
    input wire rom_valid_i1,
    input wire rom_valid_i2,
    input wire[31:0] rom_data_i1,
    input wire[31:0] rom_data_i2,
    output reg[31:0] rom_addr_o1,
    output reg[31:0] rom_addr_o2,

    input wire[31:0] dcache_data_i,
    output reg[31:0] dcache_raddr_o,
    output reg[31:0] dcache_waddr_o,
    output reg[31:0] dcache_wdata_o,
    output reg dcache_wreq_o,
    output reg dcache_rreq_o,
    output reg[3:0] dcache_sel_o
    );

    reg [31:0] count;//当前测试次数
    reg [31:0] count_end;//测试终止次数
    reg [2:0]state;//0为写状态，1为读状态

    reg [31:0] data [15:0];//16个32位寄存器，用于存储数据
    initial begin
        count_end <= 15;
        data[0] = {$random} %32'hffff;
        data[1] = {$random} %32'hffff;
        data[2] = {$random} %32'hffff;
        data[3] = {$random} %32'hffff;
        data[4] = {$random} %32'hffff;
        data[5] = {$random} %32'hffff;
        data[6] = {$random} %32'hffff;
        data[7] = {$random} %32'hffff;
        data[8] = {$random} %32'hffff;
        data[9] = {$random} %32'hffff;
        data[10] = {$random} %32'hffff;
        data[11] = {$random} %32'hffff;
        data[12] = {$random} %32'hffff;
        data[13] = {$random} %32'hffff;
        data[14] = {$random} %32'hffff;
        data[15] = {$random} %32'hffff;
    end//初始化数据

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
            count <= 32'b0;
            state <= 1'b0;
        end
        else if(count!=count_end)begin
            //写入一个数据，每个数据的地址都是0路第count存储单元第0块
            if(state == 3'b000)begin
                dcache_wdata_o <= data[count];
                dcache_waddr_o <= {20'b0,count[7:0],4'b0000};
                dcache_wreq_o <= 1'b1;
                dcache_sel_o <= 4'b1111;
                state <= state+1'b1;
            end
            //读出一个数据
            else if(state == 3'b001)begin
                dcache_raddr_o <= {20'b0,count[7:0],4'b0000};
                dcache_rreq_o <= 1'b1;
                dcache_sel_o <= 4'b1111;
                state <= state+1'b1;
            end
            //对比状态
            else if(state == 3'b010)begin
                if(dcache_data_i==data[count])begin
                    $display("%d data succeeds.\n",$count);
                    state <= 3'b000;
                    count <= count+1'b1;
                end
                else begin
                    $display("%d data fails.\n",$count);
                    $stop;
                    state <= 3'b000;
                    count <= count+1'b1;
                end
            end
        end
        else begin
            $display("all data test succeeds!\n");
            $stop;
        end
    end
endmodule

