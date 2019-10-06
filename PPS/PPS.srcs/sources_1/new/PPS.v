`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/04 21:56:53
// Design Name: 
// Module Name: PPS
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

//100MHZ时钟产生1HZ方波
module PPS_out_1hz(                         
    input CLK ,
    input sw_r,
    output reg pps_out = 0          //仿真初始化
    );
    parameter period = 100_000_000;
    reg [25:0] counter = 0;
    reg clk_1s = 0;
    always @(posedge CLK,posedge sw_r)
    begin
        if (sw_r == 1)
            counter <= 0;
        else if (counter == period/2)
        begin
            counter <= 0;
            clk_1s <= 1'b1;
        end
        else
        begin
            counter <= counter+1;
            clk_1s <= 1'b0;
        end
    end
    
    wire clk_1s_w;
    assign clk_1s_w = clk_1s;
    always @(posedge clk_1s_w)
    begin
        pps_out <= ~pps_out;
    end
    
endmodule
