`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/27 21:02:33
// Design Name: 
// Module Name: corr_sync_new
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


module corr_sync_new(
	input wire clk_recv_fir,
	input wire clk_procc,
	input wire rst,
	input wire proc_str,
	input wire rd_vld,
	input wire rd_vld_d,
    
    input wire [7:0] reg_sign,
    input wire [7:0] ref_tmp_i,
    input wire [7:0] ref_tmp_q,
    
    output reg signed[9:0] corr_res = 10'd0
    );
    
    reg signed[6:0] corr_1_q = 7'd0;
    reg signed[6:0] corr_2_q = 7'd0;
    reg signed[6:0] corr_3_q = 7'd0;
    reg signed[6:0] corr_4_q = 7'd0;
    reg signed[6:0] corr_5_q = 7'd0;
    reg signed[6:0] corr_6_q = 7'd0;
    reg signed[6:0] corr_7_q = 7'd0;
    reg signed[6:0] corr_8_q = 7'd0;
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_1_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[0]))
            corr_1_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[0]))
            corr_1_q <= 7'd0;
        else 
            case({ref_tmp_i[0], ref_tmp_q[0]})
                2'b00:corr_1_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_1_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_1_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_1_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_2_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[1]))
            corr_2_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[1]))
            corr_2_q <= 7'd0;
        else 
            case({ref_tmp_i[1], ref_tmp_q[1]})
                2'b00:corr_2_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_2_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_2_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_2_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_3_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[2]))
            corr_3_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[2]))
            corr_3_q <= 7'd0;
        else 
            case({ref_tmp_i[2], ref_tmp_q[2]})
                2'b00:corr_3_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_3_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_3_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_3_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_4_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[3]))
            corr_4_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[3]))
            corr_4_q <= 7'd0;
        else 
            case({ref_tmp_i[3], ref_tmp_q[3]})
                2'b00:corr_4_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_4_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_4_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_4_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_5_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[4]))
            corr_5_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[4]))
            corr_5_q <= 7'd0;
        else 
            case({ref_tmp_i[4], ref_tmp_q[4]})
                2'b00:corr_5_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_5_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_5_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_5_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_6_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[5]))
            corr_6_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[5]))
            corr_6_q <= 7'd0;
        else 
            case({ref_tmp_i[5], ref_tmp_q[5]})
                2'b00:corr_6_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_6_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_6_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_6_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_7_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[6]))
            corr_7_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[6]))
            corr_7_q <= 7'd0;
        else 
            case({ref_tmp_i[6], ref_tmp_q[6]})
                2'b00:corr_7_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_7_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_7_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_7_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_8_q <= 7'd0;
        else if((~rd_vld_d) & rd_vld (~reg_sign[7]))
            corr_8_q <= 7'd0;
        else if((~rd_vld) & rd_vld_d (reg_sign[7]))
            corr_8_q <= 7'd0;
        else 
            case({ref_tmp_i[7], ref_tmp_q[7]})
                2'b00:corr_8_i <= -$signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b01:corr_8_i <= -$signed({rd_datai[5], rd_datai[5:0]}) - $signed({rd_dataq[5], rd_dataq[5:0]});
                2'b10:corr_8_i <=  $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
                default:corr_8_i <= $signed({rd_datai[5], rd_datai[5:0]}) + $signed({rd_dataq[5], rd_dataq[5:0]});
            endcase
    end
    
    reg signed[7:0] corr2_1_q = 8'd0;
    reg signed[7:0] corr2_2_q = 8'd0;
    reg signed[7:0] corr2_3_q = 8'd0;
    reg signed[7:0] corr2_4_q = 8'd0;
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr2_1_q <= 8'd0;
        else 
            corr2_1_q <= $signed({corr_1_q[7], corr_1_q}) + $signed({corr_2_q[7], corr_2_q});
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr2_2_q <= 8'd0;
        else 
            corr2_2_q <= $signed({corr_3_q[7], corr_3_q}) + $signed({corr_4_q[7], corr_4_q});
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr2_3_q <= 8'd0;
        else 
            corr2_3_q <= $signed({corr_6_q[7], corr_6_q}) + $signed({corr_5_q[7], corr_5_q});
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr2_4_q <= 8'd0;
        else 
            corr2_4_q <= $signed({corr_8_q[7], corr_8_q}) + $signed({corr_7_q[7], corr_7_q});
    end
    reg signed[8:0] corr3_1_q = 9'd0;
    reg signed[8:0] corr3_2_q = 9'd0;
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr3_1_q <= 9'd0;
        else 
            corr3_1_q <= $signed({corr2_1_q[7], corr2_1_q}) + $signed({corr2_2_q[7], corr2_2_q});
    end
    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr3_2_q <= 9'd0;
        else 
            corr3_2_q <= $signed({corr2_3_q[7], corr2_3_q}) + $signed({corr2_4_q[7], corr2_4_q});
    end

    always @(posedge clk_procc)begin
        if(rst | proc_str)
            corr_res <= 9'd0;
        else 
            corr_res <= $signed({corr3_1_q[7], corr3_1_q}) + $signed({corr3_2_q[7], corr3_2_q});
    end
    
endmodule
