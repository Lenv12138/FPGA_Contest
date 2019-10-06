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

//����10ns�����ź�
    parameter period = 10;
    initial
    forever
    begin
        #(period/2) CLK <= ~CLK;            //<=��=����ʲô����,���������=����ôclk��sw_r��һֱ��Z��״̬
    end

//����100M����������1HZ�����ź�
    PPS_out_1hz pps_test                    
    (
        .CLK(CLK),                      //100M(10ns)��ʱ��
        .sw_r(sw_r),
        .pps_out(pps_out)               //�����Ĵ���1HZ�����ź�
    );
    
//����100M����400MHZ����Ƶ��
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
  
//����400M����Ƶ��,��λ����ģ��
    wire pps_modified;
    pps_adjust_phase pps_adjust_test
    (
        .clk_400M(clk_400M),                               //�������Ƶ��400MHZʱ��     
        .reset(reset),               
        .locked(locked),
        .pps_origin(pps_out),                              //���������1HZ�����ź�
        .pps_adjust_out(pps_modified)                      //��������1HZ�����ź�
    );
    
    initial
    begin
        #60000 $finish;
    end
    
    
endmodule
