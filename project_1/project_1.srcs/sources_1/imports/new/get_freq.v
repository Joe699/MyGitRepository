`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/22 11:46:25
// Design Name: 
// Module Name: get_freq
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


module get_freq(
	input wire clk_proc,
	input wire rst,
    
    input wire get_en,
    input wire [23:0] TODH_cal,
    output reg        freq_en = 1'b0,
    output reg [31:0] freq    = 32'd0
    );
    
    always @(posedge clk_proc)begin
		if(rst)
			freq <= 1'b0;
		else if(get_en)
			freq <= TODH_cal[8:0];
        else
            freq <= freq;
	end
    always @(posedge clk_proc)begin
		if(rst)
			freq_en <= 1'b0;
		else if(get_en)
			freq_en <= 1'b1;
        else
            freq_en <= 1'b0;
	end
    
endmodule
