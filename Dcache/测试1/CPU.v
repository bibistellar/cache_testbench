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
// Description: 本测试模块用于测试Dcache的顺序写入命中和顺序写出命中功能。随机生成16组数据写入Dcache中，然后随机读取16次这些数据。
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
    output reg[3:0] dcache_wsel_o
    );

    reg [31:0] count;//当前测试次数
    reg [31:0] count_end;//测试终止次数
    reg [2:0]state;//0为写状态，1为读状态
    reg [2:0]read_excute_state;//0为连续读取准备状态，1为连续读取状态

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
            dcache_wsel_o <= 32'b0;
            count <= 32'b0;
            state <= 1'b0;
            read_excute_state <= 1'b0;
        end
        else if(state == 3'b000 && count!=count_end)begin
            //写入数据
            dcache_wdata_o <= data[count];
            dcache_waddr_o <= count;
            dcache_wreq_o <= 1'b1;
            dcache_wsel_o <= 4'b1111;
            count <= count +1'b1;
        end
        //写入数据完成，计数器归零
        else if(state == 3'b000 && count == count_end)begin
            state = 3'b001;
            count <= 3'b000;
        end
        else if(state == 3'b001 && count != count_end)begin
            //连续读取前的准备阶段，先发送第一个数据的地址和使能信号
            if(read_excute_state == 3'b000)begin
                dcache_raddr_o <= {26'b0,{$random}%16};
                read_excute_state <= 3'b001;
                dcache_rreq_o <= 1'b1;
                count <= count +1'b1;
            end
            //对比返回的数据，并发送下一个数据的地址
            else if(read_excute_state == 3'b001)begin
                dcache_raddr_o <= {26'b0,{$random}%16};
                read_excute_state <= 3'b001;
                dcache_rreq_o <= 1'b1;
                count <= count +1'b1;

                if(data[dcache_raddr_o[3:0]]==dcache_data_i)begin
                    $display("test%d succeeds!\n",count);
                end
                else begin
                    $display("test%d faile!\n",count);
                    $stop;
                end
            end
        end
        else begin
            $display("all data test succeeds!\n");
            $stop;
        end
    end
endmodule
