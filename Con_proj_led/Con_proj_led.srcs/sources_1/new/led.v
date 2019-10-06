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
//����������
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
//����ʱ��ģ��400MHZ
/*
    ������ģ���input����������wire��reg,����output������wire����.
*/
    wire CLK_400M;
    wire reset;                    
    wire locked;                 //��λ����ʱ���ȶ�                   
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
    reg [30:0] counter = 0;                         //400M������
    always @(posedge CLK_400M_BUFG,posedge reset)        //2.5ns����һ��
    begin 
        if (reset == 1)                             //��λ
        begin
            counter <= 0;
            clk_1s = 1'b0;
        end
        else
        begin
            if (locked == 1)                        //400Mʱ���Ѿ��ȶ�.
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
//1s����ˮ�Ʋ���
    reg [7:0] count_1s = 0;
    wire clk_1s_w;                                  //�������������ȹ��������ɶ��������ؾ���,Ȼ�����ɲ��˱�����
    assign clk_1s_w = clk_1s;           
    always @(posedge clk_1s_w)                      //��⵽1s���ź�
    begin
        count_1s <= count_1s + 1;
        if (count_1s == 8)
            count_1s <= 0;
        else
        begin
            LED_H <= 8'b01 << count_1s; 
        end
    end
    
//����BUFGԭ��,����û����
    wire CLK_400M_BUFG;
    BUFG init_clk_bufg
    (
        .I (CLK_400M),
        .O (CLK_400M_BUFG)
    );

endmodule
