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
    reg  [15:0] sw;             //�ı������ı���
    wire [7:0] LED_L, LED_H;
    reg CLK=0;
    reg [7:0] counter=0;
//����LED.v
    led My_test
    (                   //����ǰ��д�õ�ledģ��
        .CLK(CLK),
        .LED_L(LED_L),      //��ģ�����ʱ����ȥ��output�����Ĳ���������wire����,input������wireҲ������reg
        .LED_H(LED_H),
        .sw(sw)         //My_testͨ�������sw��������LED
    );
//����PLL��ʱ��IP��
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
//��������������
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
//����PLL
    always @(posedge CLK_400M)      //2.5ns counter+1
    begin
        counter <= counter+1;
    end
//����100MHZ��CLK
    parameter clockperiod = 10;
    initial
    begin
        forever
        begin
            #(clockperiod/2) CLK = ~CLK;        //ռ�ձ�Ϊ50%�ߵ�ƽ����5ns
        end   
    end
    
    initial 
    begin
        $monitor($time,,,"CLK_400M:%d,LOCKED:%d,CLK:%d",CLK_400M,locked,CLK);
        #1000 $finish;
    end
endmodule
