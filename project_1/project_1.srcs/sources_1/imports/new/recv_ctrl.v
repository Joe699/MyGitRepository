`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/22 10:51:51
// Design Name: 
// Module Name: recv_ctrl
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


module recv_ctrl #(
        parameter T_time1ms = 16'd1000,//原来用的是50 这里我改为1000 与发送端保持一致
        parameter T_timeONEsync = 16'd50,
        parameter T_timesync = 16'd50
    ) (
	input wire clk_proc,
	input wire rst,
	input wire receive_en,
    
    input wire TODH_en,
	input wire TODL_en,
	input wire [23:0]TODH,
	input wire [15:0]TODL,
	input wire       corr_vld,
	input wire [4:0] corr_vld_walsh,     // 鐩稿叧宄帮紝璁＄畻TODH鍋忓樊
	input wire [11:0] peak_addr_d,        // 鎺у埗1ms鏃堕棿闀跨煭锛屼笌鍙戠瀵瑰簲
	output wire       dds_freq_en,
	output wire [31:0]dds_freq,
    
    output reg [15:0] netinfo_recv = 16'd0,
    output reg [15:0] TODL_recv = 16'd0,
    output reg netinfo_recv_vld = 1'b0,
    output reg TODL_recv_vld    = 1'b0
    );
    reg time_1250ns = 1'b0;  // 1 sample time
    reg time_1ms = 1'b0;
    reg time_6ms = 1'b0;
    reg jump_follow = 1'b0;
    reg time_frame_end = 1'b0;
    reg [3:0] state_work = 4'b0;
    always @(posedge clk_proc)begin
        if(rst)
            state_work 	<= 4'b0;
        else begin
            case(state_work)	
                4'd0:
                    begin // idle
                        if(receive_en && TODH_en)// wait for start/TODH
                            state_work 	<= 4'd1;
                        else
                            state_work 	<= 4'd0;
                    end
                4'd1:
                    begin  // prepare
                        if(TODH_en)
                            state_work 	<= 4'd1;
                        else
                            state_work 	<= 4'd2;
                     end
                4'd2:
                    begin // search   0~5 every 6ms
                        if(TODH_en)
                            state_work 	<= 4'd1;
                        else if(jump_follow)
                            state_work 	<= 4'd4;
                        else
                            state_work 	<= 4'd2;
                    end
                4'd4:
                    begin // jump   n every 1ms
                        if(TODH_en)
                            state_work 	<= 4'd1;
                        else if(time_frame_end)
                            state_work 	<= 4'd8;
                        else
                            state_work 	<= 4'd4;
                    end
                4'd8:
                    begin 
                        if(TODH_en)
                            state_work 	<= 4'd1;
                        else
                            state_work 	<= 4'd2;
                    end
                default:begin
                        state_work 	<= 4'd0;
                end
            endcase
        end
    end

    reg prepare = 1'b0;
    always @(posedge clk_proc)begin
        if( state_work==4'd1)
            prepare <= 1'd1;
        else
            prepare <= 1'b0;
    end
    // search stat, 寰幆6ms璁℃暟0~5
    reg [4:0]cnt_search = 5'd0;   // 0~5 every 6ms
    always @(posedge clk_proc)begin
        if(prepare|time_frame_end)
            cnt_search <= 5'd0;//5进制慢跳计数器 0~4
        else if((state_work==4'd2) && time_6ms && (cnt_search == 5'd4))
            cnt_search <= 5'd0;
        else if((state_work==4'd2) && time_6ms)
            cnt_search <= cnt_search + 5'd1;
        else
            cnt_search <= cnt_search;
    end
    // jump stat
    reg [9:0]cnt_jump   = 10'd0;    // 0~5 every 6ms
    always @(posedge clk_proc)begin
        if(time_1ms && (state_work==4'd4))
            cnt_jump <= cnt_jump + 10'd1;
        else if((state_work!=4'd4))
            cnt_jump <= 10'd40;
        else
            cnt_jump <= cnt_jump;
    end
    // time frame
    always @(posedge clk_proc)begin
        if((state_work==4'd4) && (cnt_jump==10'd10))
            time_frame_end <= 1'b1;
        else
            time_frame_end <= 1'b0;
    end
    // --------------------------------------------------------------------
    //     jump stat
    // --------------------------------------------------------------------
    reg [3:0] jump_stat = 4'd0;
    reg [3:0] jump_len = 4'd0;
    always @(posedge clk_proc)begin
        if(prepare)begin
            jump_stat 	<= 4'b0;
            jump_len 	<= 4'b0;end
        else begin
            case(jump_stat)	
                    4'd0:begin // idle
                        if(corr_vld && (corr_vld_walsh == 5'd22))begin  // 22琛ㄧずwalsh5锛屽嵆甯у悓姝?
                            jump_stat 	<= 4'd1;
                            jump_len 	<= 4'd4 - cnt_search;end
                        else begin
                            jump_stat 	<= 4'd0;
                            jump_len <= 4'd0;end
                    end
                    4'd1:begin 
                        if(time_1ms)
                            jump_len <= jump_len - 4'd1;
                        else
                            jump_len <= jump_len;
                        if(jump_len==4'd0)
                            jump_stat 	<= 4'd2;
                        else
                            jump_stat 	<= 4'd1;
                    end
                    4'd2:begin
                        jump_len <= 4'd0;
                        if(jump_follow)
                            jump_stat 	<= 4'd0;
                        else
                            jump_stat 	<= 4'd2;
                     end
                    default:begin
                         jump_stat 	<= 4'b0;
                         jump_len 	<= 4'b0;
                    end
            endcase
        end
    end
    
    always @(posedge clk_proc)begin
        if(time_1ms && (jump_stat == 4'd2))  // clk_proc
            jump_follow <= 1'b1;
        else
            jump_follow <= 1'b0;
    end
    reg searching = 1'b0;
    always @(posedge clk_proc)begin
        if( (state_work==4'd2) && (jump_stat==4'd0))
            searching <= 1'd1;
        else
            searching <= 1'b0;
    end
    // --------------------------------------------------------------------
    //     time
    // --------------------------------------------------------------------
    reg [23:0] cnt_1ms = 24'd0;
    reg [3:0]  cnt_6ms = 4'd0;
    reg corr_vld_d = 1'b0; 
    reg time_1ms_pre = 1'b0;
    always @(posedge clk_proc)begin
        time_1ms <= time_1ms_pre;
        if(prepare)begin
            time_1ms_pre <= 1'b0;
            cnt_1ms      <= 16'd0;end
        else if(corr_vld)begin     // 鏍规嵁宄板?间綅缃紝鍒ゆ柇涓嬩竴娆¤烦棰戠偣
            time_1ms_pre <= 1'b0;
            cnt_1ms      <= T_timesync + peak_addr_d*T_timeONEsync;end
        else if(cnt_1ms == T_time1ms)begin  // clk_proc
            time_1ms_pre <= 1'b1;
            cnt_1ms      <= 16'd0;end
        else begin
            time_1ms_pre <= 1'b0;
            cnt_1ms      <= cnt_1ms + 16'd1;
        end
    end
    always @(posedge clk_proc)begin
        if(prepare)begin
            time_6ms    <= 1'b0;
            cnt_6ms     <= 4'd0;end
        else if(time_1ms && (cnt_6ms == 4'd5))begin  // clk_proc
            time_6ms    <= 1'b1;
            cnt_6ms     <= 4'd0;end
        else if(time_1ms)begin
            time_6ms    <= 1'b0;
            cnt_6ms     <= cnt_6ms + 4'd1;end
        else begin
            time_6ms    <= 1'b0;
            cnt_6ms     <= cnt_6ms;
        end
    end

    // --------------------------------------------------------------------
    //     dds freq
    // --------------------------------------------------------------------
    reg signed [23:0] TODH_cal = 24'd0;
    reg signed [23:0] TODH_bias = 24'd0;
    reg get_freq_en = 1'b0;
    reg [23:0]TODH_local = 24'd0;
    reg [15:0]TODL_local = 24'd0;
    always @(posedge clk_proc)begin
        if(prepare)
            TODH_local <= TODH;
        else if(&TODL_local)
            TODH_local <= TODH_local + 24'd1;
        else
            TODH_local <= TODH_local;
    end
    always @(posedge clk_proc)begin
        if(prepare)
            TODL_local <= TODL;
        else if(time_1ms)
            TODL_local <= TODL_local + 24'd1;
        else
            TODL_local <= TODL_local;
    end
    reg time_6ms_d = 1'b0;
    reg time_6ms_dd = 1'b0;
    reg time_1ms_d = 1'b0;
    reg time_1ms_dd = 1'b0;
    always @(posedge clk_proc)begin
        time_6ms_d <= time_6ms;
        time_6ms_dd <= time_6ms_d;
        time_1ms_d <= time_1ms;
        time_1ms_dd <= time_1ms_d;
        if(prepare)
            get_freq_en <= 1'b1;
        else if(time_1ms_dd && (jump_stat == 4'd2))
            get_freq_en <= 1'b1;
        else if((state_work==4'd2) && time_6ms_dd)
            get_freq_en <= 1'b1;
        else if((state_work==4'd4) && time_1ms_dd)
            get_freq_en <= 1'b1;
        else
            get_freq_en <= 1'b0;
    end
    always @(posedge clk_proc)begin
        corr_vld_d <= corr_vld;
        if(prepare)
            TODH_bias <= 24'd0;
        else if((state_work!=4'd4 ) && (corr_vld_d & (~corr_vld)))
            if(searching)
                TODH_bias <= $signed(TODH_bias) + $signed({ 19'd0, cnt_search}) - $signed({19'd0, corr_vld_walsh}) + $signed(24'd17);
            else
                TODH_bias <= $signed(TODH_bias);
        else
            TODH_bias <= TODH_bias;
    end
    always @(posedge clk_proc)begin
        if((state_work==4'd1) || prepare)
            TODH_cal <= TODH;
        else if ((state_work==4'd2) && time_6ms_dd)
            TODH_cal <= $signed(TODH_local) + $signed({{19'd0,cnt_search[4:0]}}) + $signed(TODH_bias);
        else if(jump_follow || ((state_work==4'd4) && time_1ms_dd))
            TODH_cal <= $signed(TODH_local) + $signed(TODH_bias) + $signed({{14'd0,cnt_jump[9:0]}});
        else
            TODH_cal <= TODH_cal;
    end    
    
    get_freq get_freq_urecv(
        .clk_proc       ( clk_proc          ),
        .rst            ( rst               ),
        .get_en         ( get_freq_en       ),
        .TODH_cal       ( TODH_cal          ),
        .freq_en        ( dds_freq_en       ),
        .freq           ( dds_freq          )
    );
endmodule
