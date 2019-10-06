`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/05 10:45:31
// Design Name: 
// Module Name: pps_adjust_phase
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


//�������1HZ����������λ����
module pps_adjust_phase(
    input clk_400M,                     //ʹ��MMCM������400MHZ��Ƶ�ʽ��м���
    input reset,   
    input locked,                       //�ж�400MHZʱ���Ƿ��ȶ� 
    input pps_origin,                   //�������1HZԭʼ�����ź�            
    output reg pps_adjust_out=0         //������PPS�źŵ����         
    );
    
    `define Pi 3.14                      //Ԥ��������λ
    
    reg [30:0] cnt_T=0;                  //400MHZ�����ļ�����,��������ʱ��
    reg [30:0] cnt_H=0, cnt_L=0;         //����ߵ�ƽʱ��,�͵�ƽʱ��
    reg [1:0] present_pos=2'b0, next_pos=2'b0;          //�ж�����������ǵڼ���������
    parameter NP_NN=2'b00,              //û���յ������غ��½���,ԭʼ״̬
               YP_NN=2'b01,              //���յ�������û���½���
               NP_YN=2'b10,              //���յ��½���û��������
               YP_YN=2'b11;              //���յ������غ��½���,��״̬
    reg [1:0] pos_flag=0;
      
    always @(posedge clk_400M)
    begin
        if (next_pos != NP_NN)
            present_pos <= next_pos;
        else
            present_pos <= 0;
    end
                
    always @(posedge clk_400M,posedge pps_origin,negedge pps_origin)
    begin
        if (locked == 1)                 //400Mʱ���ȶ�
        begin
            case (present_pos)
                NP_NN:                  //û�м�⵽�����غ��½���
                begin
                    if (pps_origin == 1)
                        next_pos <= YP_NN;
                    else if (pps_origin == 0)
                        next_pos <= NP_YN;
                    else
                        next_pos <= NP_NN;
                end  
                YP_NN:                  //�м�⵽������û��⵽�½���
                begin
                    if (pps_origin == 0)
                        next_pos <= YP_YN;
                    else
                        next_pos <= YP_NN;
                end
                NP_YN:
                begin
                    if (pps_origin == 1)
                        next_pos <= YP_YN;
                    else
                        next_pos <= NP_YN;
                end
                YP_YN:                  //�м�⵽�����غ��½���,���������һ������
                begin
                    if (pps_origin == 1)
                        next_pos <= NP_NN;
                    else
                        next_pos <= YP_YN;
                end
                default: next_pos <= next_pos;
            endcase
        end
    end
    
    always @(posedge clk_400M)
    begin
        case(present_pos)
            NP_NN:
            begin
                cnt_T<=0;cnt_H<=0;cnt_L<=0;
            end
            YP_NN:
            begin
                cnt_H <= cnt_H+1;
                cnt_T <= cnt_T+1;
                cnt_L <= 0;
            end
            NP_YN:
            begin
                cnt_H <= 0;
                cnt_T <= 0;
                cnt_L <= 0;
            end
            YP_YN:
            begin
                cnt_H <= 0;
                cnt_T <= cnt_T+1;
                cnt_L <= cnt_L+1;
            end
            default:
            begin
                cnt_T<=cnt_T; cnt_H<=cnt_H; cnt_L<=cnt_L;
            end
        endcase
    end

//����cnt_H��cnt_L��ֵ����ߵ͵�ƽ
    always @(posedge clk_400M)
    begin
        if (cnt_H != 0)
            pps_adjust_out <= 1;
        else if (cnt_L != 0)
            pps_adjust_out <= 0;
        else
            pps_adjust_out <= pps_adjust_out;
    end
endmodule
