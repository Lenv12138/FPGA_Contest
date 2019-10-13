`timescale 1ns / 1ps

//对输入的1HZ方波进行相位调整
module pps_adjust_phase(
    input clk_400M,                     //使用MMCM产生的400MHZ的频率进行计数
    input reset,   
    input locked,                       //判断400MHZ时钟是否稳定 
    input pps_origin,                   //待调相的1HZ原始方波信号            
    output reg pps_adjust_out         //调相后的PPS信号的输出         
    );
   
    reg [30:0] cnt_T=0;                  //400MHZ驱动的计数器,计算周期时间
    reg [30:0] cnt_H=0, cnt_L=0;         //计算高电平时间,低电平时间
    reg [1:0] present_pos=2'b0, next_pos=2'b0;          //判断这个上升沿是第几个上升沿
    parameter NP_NN=2'b00,              //没接收到上升沿和下降沿,原始状态
               YP_NN=2'b01,              //接收到上升沿没有下降沿
               NP_YN=2'b10,              //接收到下降沿没有上升沿
               YP_YN=2'b11;              //接收到上升沿和下降沿,终状态      
    always @(next_pos)
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
    
    
    reg flag_T=1, flag_H=0;                                                 //需要更新高电平和周期时间的标志
    reg [30:0] H_buff=0, T_buff=0;                                          //延时一个clk400M时钟
    always @(posedge clk_400M)
    begin
        if (locked == 1)
        begin
            case(present_pos)
                NP_NN:
                begin
                    flag_T <= 1; flag_H <= 0;                                   //一个周期已经完成需要更新T
                    T_buff <= cnt_T; H_buff <= 0;
                    cnt_T<=0;cnt_H<=0;cnt_L<=0;
                end
                YP_NN:
                begin
                    flag_H <= 0; flag_T <= 0;
                    H_buff <= 0; T_buff <= 0;
                    cnt_H <= cnt_H+1;
                    cnt_T <= cnt_T+1;
                    cnt_L <= 0;
                end
                NP_YN:
                begin
                    flag_T <= 0; flag_H <= 0;
                    H_buff <= 0; T_buff <= 0;
                    cnt_H <= 0;
                    cnt_T <= 0;
                    cnt_L <= 0;
                end
                YP_YN:
                begin
                    flag_H <= 1; flag_T <= 0;                               //高电平时间结束需要更新H
                    H_buff <= cnt_H; T_buff <= 0;
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
    end

    wire flag_T_w, flag_H_w;
    assign {flag_T_w,flag_H_w} = {flag_T,flag_H};
    reg [9:0] index_H_cnt=0,index_T_cnt=0;                                  //用于更新存储周期和高电平时间的位置
    reg [30:0] memory_H[3:0], memory_T[3:0];                                //存储历史的高电平和周期时间 
//仿真时调用
//    integer i=0;
//    initial
//    begin
//        for (i=0;i<4;i=i+1)
//        begin
//            memory_H[i] <= 0;
//            memory_T[i] <= 0;
//        end
//    end
//假如cnt_T清零快于赋值怎么办
    always @(posedge flag_T_w, posedge flag_H_w)                                //只有在上升沿触发之后才更新T和H
    begin
        if (locked == 1)
        begin
            if (flag_T_w == 1)                                                  //更新周期时间
            begin
                if (index_T_cnt > 10'd3)                                       //只存储最近4个的高电平和周期时间
                    index_T_cnt <= 0;
                else
                begin
                    index_T_cnt <= index_T_cnt+1;
                    memory_T[index_T_cnt] <= T_buff;
                end
            end
            if (flag_H_w == 1)                                                //更新高电平时间,为什么这里价格else就会综合不成功,不正常中断
            begin
                if (index_H_cnt > 10'd3)
                    index_H_cnt <= 0;
                else
                begin
                    index_H_cnt <= index_H_cnt+1;
                    memory_H[index_H_cnt] <= H_buff;
                end
            end
        end
    end

//根据cnt_H和cnt_L的值输出高低电平
    reg [30:0] cnt=0;
    reg [9:0] out_index=0;                              //输出信号更新周期和高电平时间的索引
    reg flag_L_out=0, flag_H_out=0;                     //用于更新输出信号高低电平的索引
    always @(posedge clk_400M)
    begin
        if (locked == 1)
        begin
            if (memory_T[out_index] != 0 && memory_H[out_index] !=0)                    //确保存储了一个周期的原始信号的信息
            begin
                if (cnt >=  memory_T[out_index])                //调相后的信号输出完一个周期,索引加一使用下一个周期的时间
                begin
                    cnt <= 0;
                    if (out_index >= 10'd3)
                        out_index <= 0;
                    else
                        out_index <= out_index+1;
                end
                else                                            //调相后的信号正在输出一个周期内的信号
                begin
                    if (cnt <= memory_H[out_index])
                    begin
                        pps_adjust_out <= 1;
                        cnt <= cnt+1;
                    end
                    else if ((memory_H[out_index] < cnt) && (cnt < memory_T[out_index]))
                    begin
                        pps_adjust_out <= 0;
                        cnt <= cnt+1;
                    end
                end
            end
        end
        else
            cnt <= 0;
    end   
endmodule
