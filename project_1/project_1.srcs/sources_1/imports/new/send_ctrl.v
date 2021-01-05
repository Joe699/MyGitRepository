`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/30 13:04:25
// Design Name: 
// Module Name: send_ctrl
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


module send_ctrl    #(
        parameter T_time1ms = 24'd1000  //实际为100000  测试用1000 
    )
    (
	input wire clk_proc,
	input wire rst,
	input wire send_en,
	
	input wire TODH_en,
	input wire TODL_en,
	input wire [23:0]TODH,
	input wire [15:0]TODL,
	output wire dds_freq_en,
	output wire [31:0]dds_freq,
    
    output reg jumpfinish           = 1'b0,   //-------------- fot test
    output reg time_1ms_long        = 1'b0,
    output reg prepare_long         = 1'b0,
    output reg send_head_en         = 1'b0,
    output reg send_data_en         = 1'b0
    );

     localparam JUMPLEN = 10'd1023;
    // --------------------------------------------------------------------
    //     stat
    // --------------------------------------------------------------------
    reg prepare = 1'b0;
    (*mark_debug="true"*)
    reg time_1ms    = 1'b0;
	reg [23:0] TODH_local = 24'd0;
	reg [15:0] TODL_local = 16'd0;
    (*mark_debug="true"*)
    reg [3:0] state_work = 4'b0;
    (*mark_debug="true"*)
    reg [9:0] cnt_jump = 10'd0;   // range: 0~1023 , ----- 1 time frame
    always @(posedge clk_proc)begin
        if(rst)
            state_work 	<= 4'b0;
        else begin
            case(state_work)	
                4'd0:
                    begin // idle
                        if(send_en && (TODH_en & TODL_en))// wait for start/TODH
                            state_work 	<= 4'd3;
                        else if(TODH_en)
                            state_work 	<= 4'd1;
                        else if(TODL_en)
                            state_work 	<= 4'd2;
                        else
                            state_work 	<= 4'd0;
                    end
                4'd1:
                    begin 
                        if(TODL_en)
                            state_work 	<= 4'd3;
                        else
                            state_work 	<= 4'd1;
                    end
                4'd2:
                    begin 
                        if(TODH_en)
                            state_work 	<= 4'd3;
                        else
                            state_work 	<= 4'd2;
                    end
                4'd3:   // ready stat
                    begin 
                        if(TODH_en | TODL_en)
                            state_work 	<= 4'd3;
                        else
                            state_work 	<= 4'd4;
                            //state_work 	<= 4'd5;  // ----------- for test,
                    end
                4'd4:
                    begin
                        if(TODH_en | TODL_en)
                            state_work 	<= 4'd3;
                        else if(time_1ms & cnt_jump[6])  // cnt_jump==64
                            state_work 	<= 4'd5;
                        else
                            state_work 	<= 4'd4;
                    end
                4'd5:
                    begin
                        if(TODH_en | TODL_en)
                            state_work 	<= 4'd3;
                        else if( time_1ms && (cnt_jump==JUMPLEN)) // cnt_jump==1023
                            state_work 	<= 4'd4;
                        else
                            state_work 	<= 4'd5;
                    end
                default:begin
                        state_work 	<= 4'd0;
                end
            endcase
        end
    end
    always @(posedge clk_proc)begin
        if(rst || prepare)
            send_data_en <= 1'b0;
        else
            send_data_en <= (state_work == 4'd5) ? 1'b1 : 1'b0;
    end
    always @(posedge clk_proc)begin
        if(rst || prepare)
            send_head_en <= 1'b0;
        else
            send_head_en <= (state_work == 4'd4) ? 1'b1 : 1'b0;
    end
    reg [6:0]cnt_stay = 7'd0;
    always @(posedge clk_proc)begin
        if(prepare)begin
            cnt_stay <= 7'd0;
            prepare_long <= 1'b1;end
        else if(&cnt_stay)begin
            cnt_stay <= cnt_stay;
            prepare_long <= 1'b0;end
        else begin
            cnt_stay <= cnt_stay + 4'd1;
            prepare_long <= prepare_long;
        end
    end
    always @(posedge clk_proc)begin
        if(rst)
            prepare <= 1'b0;
        else
            prepare <= (state_work == 4'd3) ? 1'b1 : 1'b0;
    end

    always @(posedge clk_proc)begin
        jumpfinish <= (time_1ms && (cnt_jump==JUMPLEN)) ? 1'b1 : 1'b0;
    end
    // --------------------------------------------------------------------
    //     cnt time
    // --------------------------------------------------------------------
    reg [23:0] cnt1ms = 24'd0;
    reg prepare_d = 1'b0;
    reg prepare_d1 = 1'b0;
    wire prepare_down;
    assign prepare_down = prepare_d & (~prepare);
    always @(posedge clk_proc)begin
        if( prepare_down || (cnt1ms == T_time1ms) )begin
            time_1ms <= 1'b1;
            cnt1ms   <= 24'd0;end
        else if((state_work == 4'd4) || (state_work == 4'd5))begin
            time_1ms <= 1'b0;
            cnt1ms   <= cnt1ms + 24'd1;end
        else begin
            time_1ms <= 1'b0;
            cnt1ms   <= 24'd0;
        end
    end
    reg [3:0] cnt_maintain = 4'd0;
    always @(posedge clk_proc)begin
        prepare_d <= prepare;
        prepare_d1 <= prepare_d;
        if(time_1ms | prepare_down)begin
            time_1ms_long   <= 1'b1;
            cnt_maintain    <= 4'd0;end
        else if(cnt_maintain==4'd15)begin 
            time_1ms_long   <= 1'b0;
            cnt_maintain    <= cnt_maintain;end
        else begin
            time_1ms_long   <= time_1ms_long;
            cnt_maintain    <= cnt_maintain + 4'd1;
        end
    end
    // --------------------------------------------------------------------
    //   TODH_local  
    //   TODL_local
    //   get and set freq
    // --------------------------------------------------------------------   
    always @(posedge clk_proc)begin
        if(TODH_en)
            TODH_local <= TODH;
        else if(&TODL_local)
            TODH_local <= TODH_local + 24'd1;
        else
            TODH_local <= TODH_local;
    end
    always @(posedge clk_proc)begin
        if(TODL_en)
            TODL_local <= TODL;
        else if(time_1ms)
            TODL_local <= TODL_local + 24'd1;
        else
            TODL_local <= TODL_local;
    end
    always @(posedge clk_proc)begin
        if((prepare|prepare_d|prepare_d1) || (time_1ms && (cnt_jump==JUMPLEN)))
            cnt_jump <= 10'd0;
        else if(time_1ms && (cnt_jump<JUMPLEN))  // clk_proc
            cnt_jump <= cnt_jump + 10'd1;
        else
            cnt_jump <= cnt_jump;
    end
    reg get_freq_en = 1'b0;
    reg time_1ms_d = 1'b0;
    always @(posedge clk_proc)begin
        time_1ms_d <= time_1ms;
        if(time_1ms_d)  // 寤惰繜涓?涓椂閽熻缃鐜囷紝绛夊緟鍙傛暟璁剧疆
            get_freq_en <= 1'b1;
        else
            get_freq_en <= 1'b0;
    end
    reg [23:0]TODH_cal = 24'd0;
    reg [2:0] cnt_cyc = 3'b111;
    always @(posedge clk_proc)begin
        if(prepare)
            TODH_cal <= TODH;
        else if(cnt_jump<10'd40) // 鍓嶉潰40涓椂闅?0~4棰戠偣寰幆
            TODH_cal <= TODH_local + {21'd0, cnt_cyc[2:0]};//{}表示拼接，将21位的0和cnt_cyc[2:0]拼接成一个24位的数
        else
            TODH_cal <= TODH_local + {14'd0, cnt_jump};  // 绗?41涓捣鏍规嵁cnt_jump璺抽
    end    
    always @(posedge clk_proc)begin
        if(prepare)
            cnt_cyc <= 3'b111;
        else if(time_1ms && (cnt_cyc==3'd4)) // 鍓嶉潰40涓椂闅?0~4棰戠偣寰幆
            cnt_cyc <= 3'd0;
        else if(time_1ms)
            cnt_cyc <= cnt_cyc + 3'd1;
        else
            cnt_cyc <= cnt_cyc;
    end    

    get_freq get_freq_u0(
        .clk_proc       ( clk_proc          ),
        .rst            ( rst               ),
        .get_en         ( get_freq_en       ),
        .TODH_cal       ( TODH_cal          ),
        .freq_en        ( dds_freq_en       ),
        .freq           ( dds_freq          )
    );
endmodule
