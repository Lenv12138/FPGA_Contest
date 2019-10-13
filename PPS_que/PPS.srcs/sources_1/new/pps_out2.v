`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/05 10:27:14
// Design Name: 
// Module Name: pps_out2
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


module pps_out2(
    input CLK ,                 //100M板载晶振时钟
    input sw_r,                 //sw0复位
    output pps_modified,         //调相后的的1HZ方波信号输出JA2
    output pps_origin           //用于查看FPGA内部产生的1HZ原始方波JA1
    );
    
//100MHZ产生1HZ的方波
    PPS_out_1hz pps_1hz            
    (
        .CLK(CLK),                              //100MHZ时钟
        .sw_r(sw_r),                            //复位信号
        .pps_out(pps_origin)                    //未进行处理的方波信号      
    );
    
//根据板载100M晶振产生400MHZ的计数频率信号
    reg reset = 0;                              //复位信号高电平有效
    wire locked;                                //400MHZ时钟稳定信号
    wire clk_400M;
    clk_wiz_0 CLK_400_out
    (
        // Clock out ports
        .clk_400M(clk_400M),            // output clk_400M
        // Status and control signals
        .reset(reset),                  // input reset
        .locked(locked),                // output locked
        // Clock in ports
        .clk_in1(CLK)                   // input clk_in1
    );    
    
//使用400MHZ的计数频率调整pps_origin信号的相位
    pps_adjust_phase pps_adjust
    (
        .clk_400M(clk_400M),
        .reset(reset),
        .locked(locked),
        .pps_origin(pps_origin),                 //input待调1PPS信号
        .pps_adjust_out(pps_modified)            //output已调1PPS信号
    );
endmodule
