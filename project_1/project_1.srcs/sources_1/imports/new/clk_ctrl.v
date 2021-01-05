`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/08 16:02:15
// Design Name: 
// Module Name: clk_ctrl
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
// `define test
// `define work

module clk_ctrl(
    input wire SoC_PL_SCLK1,
    // enc
    output wire clk_120M,
    output wire clk_3M,
    // dec
    output wire clk_12M,
    output wire clk_96M,
    output wire clk_48M,
    output wire clk_192M,
    output wire clk_100M,
    output wire clk_60M,
    
    output reg rst = 1'b0
    );
    reg [9:0] Reset_Count   = 10'd0;
    reg       Reset_CLK_DCM = 1'b0;
    always @(posedge SoC_PL_SCLK1)begin
        if(Reset_Count< 10'd10)begin
        // if(Reset_Count< 10'd1000)begin
            Reset_CLK_DCM   <= 1'b1;
            Reset_Count     <= Reset_Count+10'd1;end
        else begin
            Reset_CLK_DCM   <= 1'b0;
            Reset_Count     <= Reset_Count;
        end
    end
    wire pll_locked;
    `ifdef work
    clk_wiz_0 clk_wiz_0_u0(
        .clk_in1    ( SoC_PL_SCLK1  ),      // input    
        .clk_out1   ( clk_120M      ),      // output  CLK_OUT1___120.000 
        .clk_out2   ( clk_12M       ),      // output  CLK_OUT2____12.000 
        .clk_out3   ( clk_96M       ),      // output  CLK_OUT3____96.000 
        .clk_out4   ( clk_48M       ),      // output  CLK_OUT4____48.000 
        .clk_out5   ( clk_192M      ),      // output  CLK_OUT5____192.000 
        .clk_out6   ( clk_100M      ),      // output  CLK_OUT5____100.000 
        .clk_out7   ( clk_60M       ),      // output  CLK_OUT5____100.000 
        .reset      ( Reset_CLK_DCM ),      // input     
        .locked     ( pll_locked    )       // output    
    );
    `else
    clk_wiz_1 clk_wiz_0_u1(
        .clk_in1    ( SoC_PL_SCLK1  ),      // input    
        .clk_out1   ( clk_120M      ),      // output  CLK_OUT1___120.000 
        .clk_out2   ( clk_12M       ),      // output  CLK_OUT2____12.000 
        .clk_out3   ( clk_96M       ),      // output  CLK_OUT3____24.000 
        .clk_out4   ( clk_48M       ),      // output  CLK_OUT4____48.000 
        .clk_out5   ( clk_192M      ),      // output  CLK_OUT5____192.000 
        .clk_out6   ( clk_100M      ),      // output  CLK_OUT5____100.000 
        .clk_out7   ( clk_60M       ),      // output  CLK_OUT5____100.000 
        .reset      ( Reset_CLK_DCM ),      // input     
        .locked     ( pll_locked    )       // output    
    );
    `endif
    reg [1:0]cnt_3M = 2'b0;
    reg clk_3M_tmp = 1'b0;
    always @(posedge clk_12M)begin
        if(~pll_locked)
            cnt_3M  <= 2'b00;
        else
            cnt_3M  <= cnt_3M + 2'b01;
    end
    always @(posedge clk_12M)begin
        if(cnt_3M==2'b0)
            clk_3M_tmp  <= 1'b1;
        else if(cnt_3M==2'b10)
            clk_3M_tmp  <= 1'b0;
        else
            clk_3M_tmp <= clk_3M_tmp;
    end
    BUFG  BUFG_clk3M(
        .I ( clk_3M_tmp     ),
        .O ( clk_3M         )
    );//BUFG是全局缓冲，它的输入是IBUFG的输出或者普通信号，BUFG的输出到达FPGA内部的IOB、CLB、选择性块RAM的时钟延迟和抖动最小。
    
    
    reg [15:0] cnt_rst = 16'd0;
    `ifdef work
    always @(posedge clk_3M)begin
        if(~pll_locked)  //时钟核输出的lock信号，一开始为低电平，时钟稳定后会拉高
            cnt_rst <= 16'd1;
        else if(&cnt_rst)//对cnt_rst进行按位与运算
            cnt_rst <= 16'hffff;
        else
            cnt_rst <= cnt_rst + 16'd1;
    end
    always @(posedge clk_3M)begin
        if(~pll_locked)
            rst <= 1'b0;
        else if(cnt_rst<16'hffff)
            rst <= 1'b1;
        else
            rst <= 1'b0;
    end
    `else
    always @(posedge clk_3M)begin
        if(~pll_locked)
            cnt_rst <= 16'd0;
        else if(&cnt_rst)//缩量与运算，自身的各个位进行与运算，第一位和第二位，产生的结果再和第三位，直至最后一位
            cnt_rst <= 16'hffff;
        else
            cnt_rst <= cnt_rst + 16'd1;
    end
    always @(posedge clk_3M)begin
        if(~pll_locked)
            rst <= 1'b0;
        else if(cnt_rst<16'd100)
            rst <= 1'b1;
        else
            rst <= 1'b0;
    end
    `endif
    
endmodule
