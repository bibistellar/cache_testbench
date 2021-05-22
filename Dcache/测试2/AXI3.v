`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 22:28:29
// Design Name: 
// Module Name: AXI3
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


module AXI3(
    input wire clk,
    input wire rst,

    input wire wr_req,
    input wire [127:0] wr_data,
    input wire [31:0] wr_addr,
    output reg wr_rdy,

    output reg rd_rdy,
    input wire rd_req,
    input wire rd_addr,

    output reg ret_valid,
    output reg [127:0] ret_data,

    input wire [127:0] data_from_cpu0,
    input wire [127:0] data_from_cpu1
    );
    reg [31:0] data [3:0];
    reg [3:0] state;
    reg [3:0] count;
    initial begin
        data[0] = {$random}%32'hffff_ffff;
        data[1] = {$random}%32'hffff_ffff;
        data[2] = {$random}%32'hffff_ffff;
        data[3] = {$random}%32'hffff_ffff;
    end
    always @(posedge clk) begin
        if(rst)begin
            wr_rdy <= 1'b1;
            ret_valid <= 1'b0;
            ret_data <= 'b0;
            state <= 1'b0;
            count <= 4'b0;
        end
        else begin
            if(state == 4'b0000 && wr_req && wr_rdy)begin
                if(data_from_cpu0 == wr_data || data_from_cpu1 == wr_data)begin
                    $display("AXI gets the right data.\n");
                end
                else begin
                    $display("AXI gets the wrong data.\n");
                end
                rd_rdy <= 1'b1;
                state <= 4'b0001;
            end
            else if(state == 4'b0001 && rd_req && rd_rdy)begin
                case (count)
                    4'b0000:begin
                        ret_data[31:0] <= data[0];
                        count <= count + 1'b1;
                    end
                    4'b0001:begin
                        ret_data[63:32] <= data[1];
                        count <= count + 1'b1;
                    end
                    4'b0010:begin
                        ret_data[95:64] <= data[2];
                        count <= count + 1'b1;
                    end
                    4'b0011:begin
                        ret_data[127:96] <= data[3];
                        count <= count + 1'b1;
                    end
                    4'b0100:begin
                        state <= state + 1'b1;
                    end
                    default:begin
                        
                    end
                endcase
            end
            else if(state == 4'b0010)begin
                ret_valid <= 1'b1;
                state <= state +1'b1;
            end
        end
    end
endmodule
