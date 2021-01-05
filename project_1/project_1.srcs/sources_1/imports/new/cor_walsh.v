`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/15 17:53:06
// Design Name: 
// Module Name: cor_walsh
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


module cor_walsh #(
    parameter WIDTH_DATA_RECV = 16,
	parameter [31:0]WALSH_WORD = 32'hF0F0F0F0,
	parameter [31:0]THRESHOLD = 32'd25000
	)(
	input wire clk_proc,
	input wire rst,
	input wire [11:0]addr,
	input wire signed [WIDTH_DATA_RECV+1:0] mk_i,
	input wire mk_en,
	input wire mk_str,
	input wire signed [WIDTH_DATA_RECV+1:0] mk_q,

	output reg signed[11:0] peak_addr_d = 12'd0,
	output reg corr_vld = 1'b0
    );
	reg signed[31:0] corr_i = 32'd0;
	reg signed[31:0] corr_q = 32'd0;
	reg [4:0] cnt_cor = 5'd0;
	reg mk_en_d1 = 1'b0;
	wire signed [31:0] corr_i_2;
	wire signed [31:0] corr_q_2;
	always @(posedge clk_proc)begin
		if(mk_str)
			cnt_cor <=  5'd0;
		else if(mk_en)
			cnt_cor <= cnt_cor + 5'd1;
		else
			cnt_cor <= cnt_cor;
	end
	always @(posedge clk_proc)begin
		if(mk_str)
			corr_i <= 32'd0;
		else if(mk_en)
			if(WALSH_WORD[5'd31 - cnt_cor])
				corr_i <= $signed(corr_i) + $signed(mk_i);
			else
				corr_i <= $signed(corr_i) - $signed(mk_i);
		else
			corr_i <= corr_i;
	end
	always @(posedge clk_proc)begin
		if(mk_str)
			corr_q <= 32'd0;
		else if(mk_en)
			if(WALSH_WORD[5'd31 - cnt_cor])
				corr_q <= $signed(corr_q) + $signed(mk_q);
			else
				corr_q <= $signed(corr_q) - $signed(mk_q);
		else
			corr_q <= corr_q;
	end
    wire corr_cal_vld;
    assign corr_cal_vld = mk_en_d1 & (~mk_en);  // corr和�?�有效时间点
	always @(posedge clk_proc)begin
        mk_en_d1 <= mk_en;
	end
	mult_32x32 mult_32x32_u1(
		.CLK	( clk_proc			),
		.A 		( corr_i[15:0]		),
		.B 		( corr_i[15:0]		),
		.P 		( corr_i_2			),
		.CE		( 1'b1		        )
	);
	mult_32x32 mult_32x32_u2(
		.CLK	( clk_proc			),
		.A 		( corr_q[15:0]		),
		.B 		( corr_q[15:0]		),
		.P 		( corr_q_2			),
		.CE		( 1'b1		        )
	);

	reg [8:0]cnt_mult = 9'd0;
	always @(posedge clk_proc)begin
		if(corr_cal_vld)
			cnt_mult <= 9'd1;
		else
			cnt_mult <= {cnt_mult[7:0], 1'b0};
	end
	reg signed[31:0]corr_cal_value=32'd0;
	always @(posedge clk_proc)begin
		if(corr_cal_vld)
			corr_cal_value <= 32'b0;
		else if(cnt_mult[6])  // 乘法器运算时间为6个时�?
			corr_cal_value <= $signed(corr_i_2) + $signed(corr_q_2);
		else
			corr_cal_value <= corr_cal_value;
	end
	reg peak_vld = 1'b0;
	always @(posedge clk_proc)begin
		if(cnt_mult[7])
			peak_vld <= (corr_cal_value >= THRESHOLD)  ? 1'b1 : 1'b0;
		else
			peak_vld <= peak_vld;
	end
	reg [11:0]peak_addr = 12'd0;
	reg [31:0]corr_cal_value_max = 32'd0;
	always @(posedge clk_proc)begin
		if(peak_vld)begin
			if(corr_cal_value > corr_cal_value_max)begin
				peak_addr	 		<= addr;
				corr_cal_value_max 	<= corr_cal_value;end
			else begin
				peak_addr 			<= peak_addr;
				corr_cal_value_max 	<= corr_cal_value_max;end
			end
		else begin
			peak_addr 			<= peak_addr;
			corr_cal_value_max <= 32'd0;
		end
	end
	reg peak_vld_d = 1'b0;
	reg peak_vld_dd = 1'b0;
	reg peak_vld_ddd = 1'b0;
	always @(posedge clk_proc)begin
        peak_vld_d <= peak_vld;
        peak_vld_dd <= peak_vld_d;
        peak_vld_ddd <= peak_vld_dd;
		if((~peak_vld_dd & peak_vld_ddd) || (~peak_vld_d & peak_vld_dd))begin  // 保持两个周期
            corr_vld  <= 1'b1;          // 下降沿确定偏移位�?,延迟�?个时钟，等待peak_addr赋�??
			peak_addr_d <= $signed(addr) - $signed(peak_addr);end//$signed()  �з�����������
		else begin
            corr_vld  <= 1'b0;
             end
	end
	
endmodule
