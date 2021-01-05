`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/29 23:07:53
// Design Name: 
// Module Name: sync_head_send
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


module sync_head_send #(
    parameter T_time200k    = 16'd4,//原来为50 后改为600  4
    parameter WIDTH_DATA    = 16,
    parameter inte_one      = 16'd28,
    parameter inte_minusone = -16'd28
    )(
	input wire clk_120M,
	input wire rst,
    input wire netinfo_en,
	input wire [15:0]netinfo,//组网信息
	input wire TODL_en,
	input wire [15:0]TODL,
    
    input wire prepare,
	input wire send_head_en,
	input wire time_1ms,
	output reg output_en =1'b0,
	output reg signed[WIDTH_DATA-1:0]output_i={WIDTH_DATA{1'b0}},
	output reg signed[WIDTH_DATA-1:0]output_q={WIDTH_DATA{1'b0}}
    );
    // --------------------------------------------------------------------
    //     cnt time
    // --------------------------------------------------------------------
    wire time_1ms_local;
    reg time_1ms_local1 = 1'b0;
    reg time_1ms_local2 = 1'b0;
    reg time_1ms_local3 = 1'b0;
    //产生1ms脉冲信号，每个脉冲持续1/120us,间隔1ms
    assign time_1ms_local = ~time_1ms_local3 & time_1ms_local2;
    always @(posedge clk_120M)begin
        time_1ms_local1 <= time_1ms;
        time_1ms_local2 <= time_1ms_local1;
        time_1ms_local3 <= time_1ms_local2;
    end
    wire prepare_local;
    reg prepare_local1 = 1'b0;
    reg prepare_local2 = 1'b0;
    reg prepare_local3 = 1'b0;
    assign prepare_local = ~prepare_local3 & prepare_local2;
    always @(posedge clk_120M)begin
        prepare_local1 <= prepare;
        prepare_local2 <= prepare_local1;
        prepare_local3 <= prepare_local2;
    end
    // 5000ns
    reg [15:0] cnt1 = 16'd0;
    reg time200k = 1'b0;
    always @(posedge clk_120M)begin
        if((cnt1 == T_time200k) || (rst | prepare_local | time_1ms_local))
            cnt1 <= 16'd0;
        else
            cnt1 <= send_head_en ? (cnt1 + 16'd1) : cnt1;
    end
    always @(posedge clk_120M)begin
        if(rst | prepare_local)
            time200k <= 1'b0;
        else if(time_1ms_local || (cnt1 == T_time200k))
            time200k <= 1'b1;//5us  每个比特的持续时间 脉冲信号 1ms共200bit 即200个5us
        else
            time200k <= 1'b0;
    end
    // 0~199
    reg [7:0] cnt_symbol = 8'd0;
    reg time_1ms_local_d = 1'b0;
    always @(posedge clk_120M)begin
        time_1ms_local_d <= time_1ms_local;
        if(rst | time_1ms_local_d)
            cnt_symbol <= 8'd0;
        else if(time200k)
            cnt_symbol <= cnt_symbol + 8'd1;
        else
            cnt_symbol <= cnt_symbol;//比特数
    end
    // 鍙戦?佹椂闅欒鏁? 0~63  
    reg [5:0] sended_slice_cnt = 6'b111111;  //跳数
    always @(posedge clk_120M)begin
        if(rst | prepare_local)
            sended_slice_cnt <= 6'b111111;
        else if(time_1ms_local_d && send_head_en)
            sended_slice_cnt <= sended_slice_cnt + 6'd1;
        else
            sended_slice_cnt <= sended_slice_cnt;
    end
    // --------------------------------------------------------------------
    //     rd walsh
    // --------------------------------------------------------------------
    reg [5:0]   rd_walsh_addr   = 6'd0;
    reg [15:0]  net_addr        = 16'd0;
    reg [15:0]  TODL_addr       = 16'd0;
    reg [19:0]  tmp_addr        = 20'd0;
    reg [3:0]   cnt_repeat5     = 4'd0;
    // rd addr
    always @(posedge clk_120M)begin
        if(sended_slice_cnt<8'd40)  //35跳相关序列和5跳帧同步
            rd_walsh_addr <= 6'd16 + sended_slice_cnt[5:0]; // 16~(16+40)
        else if(sended_slice_cnt<8'd60)
            case(cnt_repeat5)  // change after 1 slice / 5 times every info
                4'd1:   rd_walsh_addr <= {1'b0, tmp_addr[3:0]  };
                4'd2:   rd_walsh_addr <= {1'b0, tmp_addr[7:4]  };
                4'd3:   rd_walsh_addr <= {1'b0, tmp_addr[11:8] };
                4'd4:   rd_walsh_addr <= {1'b0, tmp_addr[15:12]};
                default:rd_walsh_addr <= {1'b0, tmp_addr[19:16]};
            endcase
        else
            rd_walsh_addr <= rd_walsh_addr;
    end
    always @(posedge clk_120M)begin
        if(sended_slice_cnt<8'd50)
            tmp_addr <= {4'd0, net_addr};  //传输组网信息的地址
        else if(sended_slice_cnt<8'd60)
            tmp_addr <= {4'd0, TODL_addr}; //传输TODL信息的地址
        else
            tmp_addr <= tmp_addr;
    end
    reg [7:0]cnt_symbol_d = 8'd0;
    always @(posedge clk_120M)begin
        cnt_symbol_d <= cnt_symbol;
        if(sended_slice_cnt<8'd40)
            cnt_repeat5 <= 4'd0;
        else if((cnt_symbol==8'd10) && time200k) //change at 10 or others / change every slice
            if(cnt_repeat5 == 4'd4)
                cnt_repeat5 <= 4'd0;
            else
                cnt_repeat5 <= cnt_repeat5 + 4'd1;
        else
            cnt_repeat5 <= cnt_repeat5;
    end
    always @(posedge clk_120M)begin
        if(netinfo_en)
            net_addr <= netinfo;
        else
            net_addr <= net_addr;
    end  
    always @(posedge clk_120M)begin
        if(TODL_en)
            TODL_addr <= TODL;
        else
            TODL_addr <= TODL_addr;
    end  
    // 
    wire[31:0]rd_walsh_data;
    reg [31:0]walsh_data = 32'b0;
    always @(posedge clk_120M)begin
        if(cnt_symbol==8'd23)  //前24bit为保护比特
            walsh_data <= rd_walsh_data;
        else if(output_en)
            walsh_data <= {walsh_data[0], walsh_data[31:1]};
        else
            walsh_data <= walsh_data;
    end  
    /* walsh_store walsh_store_u0(
        .clka   ( clk_120M      ),    //  : IN STD_LOGIC;
        .ena    ( 1'b1          ),    //  : IN STD_LOGIC;
        .addra  ( rd_walsh_addr ),    // : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        .douta  ( rd_walsh_data )     // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    ); */
    
    walshtable walshtable_u0(
        .a         ( rd_walsh_addr  ),    //IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        //.d         (                ),
        .clk       ( clk_120M       ) ,   //: IN STD_LOGIC;
        //.we        (                ),
        .spo       ( rd_walsh_data  )      //OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    // --------------------------------------------------------------------
    //     protect gap
    // --------------------------------------------------------------------
    reg [5:0] addr_rdprotect = 6'd0;
    wire [1:0] rdata_protect;
    always @(posedge clk_120M)begin
        if(prepare_local | time_1ms_local)
            addr_rdprotect <= 6'd0;
        else if(output_en && ((cnt_symbol<16'd24) || (cnt_symbol>16'd183)))
            addr_rdprotect <= addr_rdprotect + 6'd1;
        else
            addr_rdprotect <= addr_rdprotect;
    end
/*     srom_syncprotect srom_syncprotect_u0(
        .clka   ( clk_120M          ),        // IN STD_LOGIC;
        .ena    ( 1'b1              ),        // IN STD_LOGIC;
        .addra  ( addr_rdprotect    ),        // IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        .douta  ( rdata_protect     )         // OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    ); */
    syncprotect_lutrom syncprotect_lutrom_u0(
        .a             ( addr_rdprotect ),    //: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        //.d             (                ),
        .clk           ( clk_120M       ) ,   //: IN STD_LOGIC;
        //.we            (                ),
        .spo           ( rdata_protect  )    //: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
    // --------------------------------------------------------------------
    //     output
    // --------------------------------------------------------------------
    reg time_1ms_local_d1 = 1'b0;
    reg time_1ms_local_d2 = 1'b0;
    reg T_time200k_d = 1'b0;
    reg T_time200k_d2 = 1'b0;
    reg T_time200k_d3 = 1'b0;
    reg T_time200k_d4 = 1'b0;
    always @(posedge clk_120M)begin
        time_1ms_local_d1 <= time_1ms_local;
        time_1ms_local_d2 <= time_1ms_local_d1;
        
        T_time200k_d  <= time200k;
        T_time200k_d2 <= T_time200k_d;
        T_time200k_d3 <= T_time200k_d2;
        T_time200k_d4 <= T_time200k_d3;
    end
    always @(posedge clk_120M)begin
        if(T_time200k_d2)
            output_en <= 1'b1;
        else
            output_en <= 1'b0;
    end    
    always @(posedge clk_120M)begin
        if((time_1ms_local_d2 | T_time200k_d2) && send_head_en )begin
            if((cnt_symbol<16'd24) || (cnt_symbol>16'd183))begin
                output_i <= rdata_protect[0] ? inte_one : inte_minusone;
                output_q <= rdata_protect[1] ? inte_one : inte_minusone;end
            else begin
                output_i <= walsh_data[0] ? inte_one : inte_minusone;
                output_q <= walsh_data[0] ? inte_one : inte_minusone;
            end
        end
        else begin
            output_i <= output_i;
            output_q <= output_q;
        end
    end    
    
endmodule
