`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/30 20:00:52
// Design Name: 
// Module Name: led_tb
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


module led_tb();
    reg  [15:0] sw;             //改变的输入的变量
    wire [7:0] LED_L, LED_H;
    reg CLK=0;
    reg [7:0] counter=0;
//调用LED.v
    led My_test
    (                   //调用前面写好的led模块
        .CLK(CLK),
        .LED_L(LED_L),      //子模块调用时传进去给output变量的参数必须是wire类型,input可以是wire也可以是reg
        .LED_H(LED_H),
        .sw(sw)         //My_test通过输入的sw变量控制LED
    );
//调用PLL的时钟IP核
    wire CLK_400M;
    wire reset;
    wire locked;        
    clk_wiz_0 MY_CLK_400M
     (
      // Clock out ports
      .clk_out1(CLK_400M),      // output clk_out1
      // Status and control signals
      .reset(reset),            // input reset
      .locked(locked),          // output locked
     // Clock in ports
      .clk_in1(CLK)
      );  
//测试三八译码器
    initial
    begin
        sw = 16'b0;
        #100 sw <= 3'b001;
        #100 sw <= 3'b010;
        #100 sw <= 3'b011;
        #100 sw <= 3'b100;  
        #100 sw <= 3'b101;   
        #100 sw <= 3'b110;  
        #100 sw <= 3'b111;    
    end
//测试PLL
    always @(posedge CLK_400M)      //2.5ns counter+1
    begin
        counter <= counter+1;
    end
//产生100MHZ的CLK
    parameter clockperiod = 10;
    initial
    begin
        forever
        begin
            #(clockperiod/2) CLK = ~CLK;        //占空比为50%高电平持续5ns
        end   
    end
    
    initial 
    begin
        $monitor($time,,,"CLK_400M:%d,LOCKED:%d,CLK:%d",CLK_400M,locked,CLK);
        #1000 $finish;
    end
endmodule
