`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/30 16:41:00
// Design Name: 
// Module Name: led
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


module led(
    input CLK,
    output reg [7:0] LED_L = 0,
    output reg [7:0] LED_H = 0,
    input [15:0] sw
    );
//三八译码器
    always @(posedge CLK)
    begin 
        case(sw)
            3'd0: LED_L <= 8'b0000_0001;
            3'd1: LED_L <= 8'b0000_0010;
            3'd2: LED_L <= 8'b0000_0100;
            3'd3: LED_L <= 8'b0000_1000;
            3'd4: LED_L <= 8'b0001_0000;
            3'd5: LED_L <= 8'b0010_0000;
            3'd6: LED_L <= 8'b0100_0000;
            3'd7: LED_L <= 8'b1000_0000;
        endcase
    end
//测试时钟模块400MHZ
/*
    输入子模块的input参数可以是wire或reg,但是output必须是wire类型.
*/
    wire CLK_400M;
    wire reset;                    
    wire locked;                 //置位代表时钟稳定                   
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
    reg clk_1s = 0;                                 //400M to 1s
    reg [30:0] counter = 0;                         //400M计数器
    always @(posedge CLK_400M_BUFG,posedge reset)        //2.5ns触发一次
    begin 
        if (reset == 1)                             //复位
        begin
            counter <= 0;
            clk_1s = 1'b0;
        end
        else
        begin
            if (locked == 1)                        //400M时钟已经稳定.
            begin 
                counter <= counter+1;
                if (counter == 30'd5)     //1s
                begin
                    clk_1s <= 1'b1;
                    counter <= 0;
                end
                else
                    clk_1s <= 1'b0;
            end
            else
            begin
                counter <= counter;
                clk_1s <= clk_1s;
            end
        end
    end
//1s钟流水灯操作
    reg [7:0] count_1s = 0;
    wire clk_1s_w;                                  //把这个定义放在热狗后面会造成多驱动严重警告,然后生成不了比特流
    assign clk_1s_w = clk_1s;           
    always @(posedge clk_1s_w)                      //检测到1s钟信号
    begin
        count_1s <= count_1s + 1;
        if (count_1s == 8)
            count_1s <= 0;
        else
        begin
            LED_H <= 8'b01 << count_1s; 
        end
    end
    
//测试BUFG原语,好像没有用
    wire CLK_400M_BUFG;
    BUFG init_clk_bufg
    (
        .I (CLK_400M),
        .O (CLK_400M_BUFG)
    );

endmodule
