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


//对输入的1HZ方波进行相位调整
module pps_adjust_phase(
    input clk_400M,                     //使用MMCM产生的400MHZ的频率进行计数
    input reset,   
    input locked,                       //判断400MHZ时钟是否稳定 
    input pps_origin,                   //待调相的1HZ原始方波信号            
    output reg pps_adjust_out=0         //调相后的PPS信号的输出         
    );
    
    `define Pi 3.14                      //预留调整相位
    
    reg [30:0] cnt_T=0;                  //400MHZ驱动的计数器,计算周期时间
    reg [30:0] cnt_H=0, cnt_L=0;         //计算高电平时间,低电平时间
    reg [1:0] present_pos=2'b0, next_pos=2'b0;          //判断这个上升沿是第几个上升沿
    parameter NP_NN=2'b00,              //没接收到上升沿和下降沿,原始状态
               YP_NN=2'b01,              //接收到上升沿没有下降沿
               NP_YN=2'b10,              //接收到下降沿没有上升沿
               YP_YN=2'b11;              //接收到上升沿和下降沿,终状态
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
        if (locked == 1)                 //400M时钟稳定
        begin
            case (present_pos)
                NP_NN:                  //没有检测到上升沿和下降沿
                begin
                    if (pps_origin == 1)
                        next_pos <= YP_NN;
                    else if (pps_origin == 0)
                        next_pos <= NP_YN;
                    else
                        next_pos <= NP_NN;
                end  
                YP_NN:                  //有检测到上升沿没检测到下降沿
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
                YP_YN:                  //有检测到上升沿和下降沿,即检测完了一个周期
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

//根据cnt_H和cnt_L的值输出高低电平
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
