`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/04 22:02:41
// Design Name: 
// Module Name: pps_tb
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


module pps_tb();
    wire pps_out;
    reg CLK=0, sw_r=0;

//产生10ns周期信号
    parameter period = 10;
    initial
    forever
    begin
        #(period/2) CLK <= ~CLK;            //<=和=号有什么区别,如果这里用=号那么clk和sw_r就一直是Z的状态
    end

//测试100M产生待调的1HZ方波信号
    PPS_out_1hz pps_test                    
    (
        .CLK(CLK),                      //100M(10ns)的时钟
        .sw_r(sw_r),
        .pps_out(pps_out)               //产生的待调1HZ方波信号
    );
    
//测试100M产生400MHZ计数频率
    wire clk_400M;
    reg reset=0;
    wire locked;
    clk_wiz_0 CLK_400_test
    (
        // Clock out ports
        .clk_400M(clk_400M),          // output clk_400M(2.5ns)
        // Status and control signals
        .reset(reset),                // input reset
        .locked(locked),              // output locked
        // Clock in ports
        .clk_in1(CLK)                 // input clk_in1
    );      
  
//测试400M计数频率,相位调整模块
    wire pps_modified;
    pps_adjust_phase pps_adjust_test
    (
        .clk_400M(clk_400M),                               //输入计数频率400MHZ时钟     
        .reset(reset),               
        .locked(locked),
        .pps_origin(pps_out),                              //输入待调相1HZ方波信号
        .pps_adjust_out(pps_modified)                      //输出调相后1HZ方波信号
    );
    
    initial
    begin
        #60000 $finish;
    end
    
    
endmodule
