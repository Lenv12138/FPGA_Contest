`timescale 1ns / 1ps

//�������1HZ����������λ����
module pps_adjust_phase(
    input clk_400M,                     //ʹ��MMCM������400MHZ��Ƶ�ʽ��м���
    input reset,   
    input locked,                       //�ж�400MHZʱ���Ƿ��ȶ� 
    input pps_origin,                   //�������1HZԭʼ�����ź�            
    output reg pps_adjust_out         //������PPS�źŵ����         
    );
   
    reg [30:0] cnt_T=0;                  //400MHZ�����ļ�����,��������ʱ��
    reg [30:0] cnt_H=0, cnt_L=0;         //����ߵ�ƽʱ��,�͵�ƽʱ��
    reg [1:0] present_pos=2'b0, next_pos=2'b0;          //�ж�����������ǵڼ���������
    parameter NP_NN=2'b00,              //û���յ������غ��½���,ԭʼ״̬
               YP_NN=2'b01,              //���յ�������û���½���
               NP_YN=2'b10,              //���յ��½���û��������
               YP_YN=2'b11;              //���յ������غ��½���,��״̬      
    always @(next_pos)
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
    
    
    reg flag_T=1, flag_H=0;                                                 //��Ҫ���¸ߵ�ƽ������ʱ��ı�־
    reg [30:0] H_buff=0, T_buff=0;                                          //��ʱһ��clk400Mʱ��
    always @(posedge clk_400M)
    begin
        if (locked == 1)
        begin
            case(present_pos)
                NP_NN:
                begin
                    flag_T <= 1; flag_H <= 0;                                   //һ�������Ѿ������Ҫ����T
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
                    flag_H <= 1; flag_T <= 0;                               //�ߵ�ƽʱ�������Ҫ����H
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
    reg [9:0] index_H_cnt=0,index_T_cnt=0;                                  //���ڸ��´洢���ں͸ߵ�ƽʱ���λ��
    reg [30:0] memory_H[3:0], memory_T[3:0];                                //�洢��ʷ�ĸߵ�ƽ������ʱ�� 
//����ʱ����
//    integer i=0;
//    initial
//    begin
//        for (i=0;i<4;i=i+1)
//        begin
//            memory_H[i] <= 0;
//            memory_T[i] <= 0;
//        end
//    end
//����cnt_T������ڸ�ֵ��ô��
    always @(posedge flag_T_w, posedge flag_H_w)                                //ֻ���������ش���֮��Ÿ���T��H
    begin
        if (locked == 1)
        begin
            if (flag_T_w == 1)                                                  //��������ʱ��
            begin
                if (index_T_cnt > 10'd3)                                       //ֻ�洢���4���ĸߵ�ƽ������ʱ��
                    index_T_cnt <= 0;
                else
                begin
                    index_T_cnt <= index_T_cnt+1;
                    memory_T[index_T_cnt] <= T_buff;
                end
            end
            if (flag_H_w == 1)                                                //���¸ߵ�ƽʱ��,Ϊʲô����۸�else�ͻ��ۺϲ��ɹ�,�������ж�
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

//����cnt_H��cnt_L��ֵ����ߵ͵�ƽ
    reg [30:0] cnt=0;
    reg [9:0] out_index=0;                              //����źŸ������ں͸ߵ�ƽʱ�������
    reg flag_L_out=0, flag_H_out=0;                     //���ڸ�������źŸߵ͵�ƽ������
    always @(posedge clk_400M)
    begin
        if (locked == 1)
        begin
            if (memory_T[out_index] != 0 && memory_H[out_index] !=0)                    //ȷ���洢��һ�����ڵ�ԭʼ�źŵ���Ϣ
            begin
                if (cnt >=  memory_T[out_index])                //�������ź������һ������,������һʹ����һ�����ڵ�ʱ��
                begin
                    cnt <= 0;
                    if (out_index >= 10'd3)
                        out_index <= 0;
                    else
                        out_index <= out_index+1;
                end
                else                                            //�������ź��������һ�������ڵ��ź�
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
