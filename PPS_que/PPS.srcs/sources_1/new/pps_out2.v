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
    input CLK ,                 //100M���ؾ���ʱ��
    input sw_r,                 //sw0��λ
    output pps_modified,         //�����ĵ�1HZ�����ź����JA2
    output pps_origin           //���ڲ鿴FPGA�ڲ�������1HZԭʼ����JA1
    );
    
//100MHZ����1HZ�ķ���
    PPS_out_1hz pps_1hz            
    (
        .CLK(CLK),                              //100MHZʱ��
        .sw_r(sw_r),                            //��λ�ź�
        .pps_out(pps_origin)                    //δ���д���ķ����ź�      
    );
    
//���ݰ���100M�������400MHZ�ļ���Ƶ���ź�
    reg reset = 0;                              //��λ�źŸߵ�ƽ��Ч
    wire locked;                                //400MHZʱ���ȶ��ź�
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
    
//ʹ��400MHZ�ļ���Ƶ�ʵ���pps_origin�źŵ���λ
    pps_adjust_phase pps_adjust
    (
        .clk_400M(clk_400M),
        .reset(reset),
        .locked(locked),
        .pps_origin(pps_origin),                 //input����1PPS�ź�
        .pps_adjust_out(pps_modified)            //output�ѵ�1PPS�ź�
    );
endmodule
