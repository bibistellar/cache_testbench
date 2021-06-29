`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 15:47:40
// Design Name: 
// Module Name: tlb
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


module tlb
#(
    parameter TLBNUM = 16
)
(
    input wire clk,
    input wire rst,

    //search port 0
    input wire [18:0]               s0_vpn2,
    input wire                      s0_odd_page,
    input wire[7:0]                 s0_asid,
    output wire                      s0_found,
    output wire [$clog2(TLBNUM)-1:0] s0_index,
    output wire [19:0]               s0_pfn,
    output wire [2:0]                s0_c,
    output wire                      s0_d,
    output wire                      s0_v,

    //search port 1
    input wire [18:0]               s1_vpn2,
    input wire                      s1_odd_page,
    input wire[7:0]                 s1_asid,
    output wire                      s1_found,
    output wire [$clog2(TLBNUM)-1:0] s1_index,
    output wire [19:0]               s1_pfn,
    output wire [2:0]                s1_c,
    output wire                      s1_d,
    output wire                      s1_v,

    //write port 
    input wire we,
    input wire [$clog2(TLBNUM)-1:0] w_index,
    input wire [18:0]               w_vpn2, 
    input wire [7:0]                w_asid,
    input wire                      w_g,
    input wire [19:0]               w_pfn0,
    input wire [2:0]                w_c0,
    input wire                      w_d0,
    input wire                      w_v0,
    input wire [19:0]               w_pfn1,
    input wire [2:0]                w_c1,
    input wire                      w_d1,
    input wire                      w_v1,

    //read port
    input wire [$clog2(TLBNUM)-1:0] r_index,
    output wire [18:0]               r_vpn2, 
    output wire [7:0]                r_asid,
    output wire                      r_g,
    output wire [19:0]               r_pfn0,
    output wire [2:0]                r_c0,
    output wire                      r_d0,
    output wire                      r_v0,
    output wire [19:0]               r_pfn1,
    output wire [2:0]                r_c1,
    output wire                      r_d1,
    output wire                      r_v1
);
    reg [18:0] tlb_vpn2 [TLBNUM-1:0];
    reg [7:0] tlb_asid [TLBNUM-1:0];
    reg tlb_g [TLBNUM-1:0];
    reg [19:0] tlb_pfn0 [TLBNUM-1:0];
    reg [2:0] tlb_c0 [TLBNUM-1:0];
    reg tlb_d0 [TLBNUM-1:0];
    reg tlb_v0 [TLBNUM-1:0];
    reg [19:0] tlb_pfn1 [TLBNUM-1:0];
    reg [2:0] tlb_c1 [TLBNUM-1:0];
    reg tlb_d1 [TLBNUM-1:0];
    reg tlb_v1 [TLBNUM-1:0];

    wire [15:0] match0;
    wire [$clog2(TLBNUM)-1:0] match0_index;
    wire [15:0] match1;
    wire [$clog2(TLBNUM)-1:0] match1_index;

    wire kseg0_addr0;
    wire kseg1_addr0;
    wire kseg0_addr1;
    wire kseg1_addr1;

    //初始化
    genvar i;
    generate
        for (i=0; i<TLBNUM; i=i+1)
        begin: tlb_initial
            always @(posedge clk) begin
                if(rst)begin
                    tlb_vpn2[i] <= 19'b0;
                    tlb_asid[i] <= 8'b0;
                    tlb_g[i] <= 1'b0;
                    tlb_pfn0[i] <= 20'b0;
                    tlb_c0[i] <= 3'b0;
                    tlb_d0[i] <= 1'b0;
                    tlb_v0[i] <= 1'b0;
                    tlb_pfn1[i] <= 20'b0;
                    tlb_c1[i] <= 3'b0;
                    tlb_d1[i] <= 1'b0;
                    tlb_v1[i] <= 1'b0;
                end
            end
        end
    endgenerate

    //查找TLB
    //port0 & port1 命中结果
    generate
        for(i = 0; i < TLBNUM; i = i+1)
        begin:port0_search
            assign match0[i:i] = ((s0_vpn2 == tlb_vpn2[i]) && ((s0_asid == tlb_asid[i]) || tlb_g[i])) ? 1'b1 : 1'b0;
            assign match1[i:i] = ((s1_vpn2 == tlb_vpn2[i]) && ((s1_asid == tlb_asid[i]) || tlb_g[i])) ? 1'b1 : 1'b0;
        end
    endgenerate

    //port0命中结果译码为单元编号
    assign match0_index = (match0[0:0] == 1'b1) ? 0 :
                          (match0[1:1] == 1'b1) ? 1 :
                          (match0[2:2] == 1'b1) ? 2 :
                          (match0[3:3] == 1'b1) ? 3 :
                          (match0[4:4] == 1'b1) ? 4 :
                          (match0[5:5] == 1'b1) ? 5 :
                          (match0[6:6] == 1'b1) ? 6 :
                          (match0[7:7] == 1'b1) ? 7 :
                          (match0[8:8] == 1'b1) ? 8 :
                          (match0[9:9] == 1'b1) ? 9 :
                          (match0[10:10] == 1'b1) ? 10 :
                          (match0[11:11] == 1'b1) ? 11 :
                          (match0[12:12] == 1'b1) ? 12 :
                          (match0[13:13] == 1'b1) ? 13 :
                          (match0[14:14] == 1'b1) ? 14 :
                          (match0[15:15] == 1'b1) ? 15 :16;
    //port1命中结果编码为单元编号
    assign match1_index = (match1[0:0] == 1'b1) ? 0 :
                          (match1[1:1] == 1'b1) ? 1 :
                          (match1[2:2] == 1'b1) ? 2 :
                          (match1[3:3] == 1'b1) ? 3 :
                          (match1[4:4] == 1'b1) ? 4 :
                          (match1[5:5] == 1'b1) ? 5 :
                          (match1[6:6] == 1'b1) ? 6 :
                          (match1[7:7] == 1'b1) ? 7 :
                          (match1[8:8] == 1'b1) ? 8 :
                          (match1[9:9] == 1'b1) ? 9 :
                          (match1[10:10] == 1'b1) ? 10 :
                          (match1[11:11] == 1'b1) ? 11 :
                          (match1[12:12] == 1'b1) ? 12 :
                          (match1[13:13] == 1'b1) ? 13 :
                          (match1[14:14] == 1'b1) ? 14 :
                          (match1[15:15] == 1'b1) ? 15 :16;

    //输出命中结果
    assign kseg0_addr0 = (s0_vpn2 >= 32'h8000_0000 && s0_vpn2 < 32'hA000_0000);
    assign kseg1_addr0 = (s0_vpn2 >= 32'hA000_0000 && s0_vpn2 < 32'hC000_0000);
    assign kseg0_addr1=  (s1_vpn2 >= 32'h8000_0000 && s1_vpn2 < 32'hA000_0000);
    assign kseg1_addr1 = (s1_vpn2 >= 32'hA000_0000 && s1_vpn2 < 32'hC000_0000);

    //输出port0查找结果
    assign s0_found = (kseg0_addr0 || kseg1_addr0) ? 1'b1 :
                        | match0 ? 1'b1 :
                        1'b0;
    assign s0_index = (kseg0_addr0 || kseg1_addr0) ? 4'b0 :
                        | match0 ? match0_index :
                        4'b0;
    assign s0_pfn = (kseg0_addr0) ? s0_vpn2 - 32'h8000_0000 :
                    (kseg1_addr0) ? s0_vpn2 - 32'hA000_0000 :
                    (|match0 && s0_odd_page == 1'b0) ? tlb_pfn0[match0_index] :
                    (|match0 && s0_odd_page == 1'b1) ? tlb_pfn1[match0_index] :
                    20'b0; 
    assign s0_c = (|match0 && s0_odd_page == 1'b0) ? tlb_c0[match0_index] :
                  (|match0 && s0_odd_page == 1'b1) ? tlb_c1[match0_index] :
                  3'b0;
    assign s0_d = (|match0 && s0_odd_page == 1'b0) ? tlb_d0[match0_index] :
                  (|match0 && s0_odd_page == 1'b1) ? tlb_d1[match0_index] :
                  3'b0;
    assign s0_v = (|match0 && s0_odd_page == 1'b0) ? tlb_v0[match0_index] :
                  (|match0 && s0_odd_page == 1'b1) ? tlb_v1[match0_index] :
                  3'b0;

    //输出port1查找结果
    assign s1_found = (kseg0_addr1 || kseg1_addr1) ? 1'b1 :
                        | match1 ? 1'b1 :
                        1'b0;
    assign s1_index = (kseg0_addr1 || kseg1_addr1) ? 4'b0 :
                        | match1 ? match1_index :
                        4'b0;
    assign s1_pfn = (kseg0_addr0) ? s1_vpn2 - 32'h8000_0000 :
                    (kseg1_addr0) ? s1_vpn2 - 32'hA000_0000 :
                    (|match1 && s1_odd_page == 1'b0) ? tlb_pfn0[match1_index] :
                    (|match1 && s1_odd_page == 1'b1) ? tlb_pfn1[match1_index] :
                    20'b0; 
    assign s1_c = (|match1 && s1_odd_page == 1'b0) ? tlb_c0[match1_index] :
                  (|match1 && s1_odd_page == 1'b1) ? tlb_c1[match1_index] :
                  3'b0;
    assign s1_d = (|match1 && s1_odd_page == 1'b0) ? tlb_d0[match1_index] :
                  (|match1 && s1_odd_page == 1'b1) ? tlb_d1[match1_index] :
                  3'b0;
    assign s1_v = (|match1 && s1_odd_page == 1'b0) ? tlb_v0[match1_index] :
                  (|match1 && s1_odd_page == 1'b1) ? tlb_v1[match1_index] :
                  3'b0;


    //读TLB
    assign r_vpn2 = tlb_vpn2[r_index]; 
    assign r_asid = tlb_asid[r_index];
    assign r_g    = tlb_g   [r_index];
    assign r_pfn0 = tlb_pfn0[r_index];
    assign r_c0   = tlb_c0  [r_index];
    assign r_d0   = tlb_d0  [r_index];
    assign r_v0   = tlb_v0  [r_index];
    assign r_pfn1 = tlb_pfn1[r_index];
    assign r_c1   = tlb_c1  [r_index];
    assign r_d1   = tlb_d1  [r_index];
    assign r_v1   = tlb_v1  [r_index];

    //写TLB
    always @(posedge clk) begin
        if(we)begin
            tlb_vpn2[w_index] <= w_vpn2;
            tlb_asid[w_index] <= w_asid;
            tlb_g[w_index] <= w_g;
            tlb_pfn0[w_index] <= w_pfn0;
            tlb_c0[w_index] <= w_c0;
            tlb_d0[w_index] <= w_d0;
            tlb_v0[w_index] <= w_v0;
            tlb_pfn1[w_index] <= w_pfn1;
            tlb_c1[w_index] <= w_c1;
            tlb_d1[w_index] <= w_d1;
            tlb_v1[w_index] <= w_v1;
        end
    end
endmodule
