`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/14 21:24:39
// Design Name: 
// Module Name: test_recv_new
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


module test_recv_new(

    );

    
    reg SoC_PL_SCLK1 = 1'b0;
    reg send_en = 1'b1;
    reg TODH_en = 1'b1;
    reg TODL_en = 1'b1;
    reg netinfo_en = 1'b1;
    reg receive_en = 1'b1;
    reg [23:0]TODH = 24'd24;
    reg [15:0]TODL = 16'd12;
    reg [23:0]R_TODH = 24'd24;
    reg [15:0]R_TODL = 16'd12;
    reg [15:0]netinfo = 16'd8;//组网信息
    
    initial
    begin
        #70000 TODH_en = 1'b0; TODL_en = 1'b0;
    end
    
    always #5 SoC_PL_SCLK1 = ~SoC_PL_SCLK1;//100MHz
    //---------------------------------------------------------------
    //  clk & rst
    //---------------------------------------------------------------
   // send clk
    wire clk_recv_fir       ;
    wire clk_recv_proc           ;
    wire clk_3M             ;
    // recv clk
    wire data_quan_clk      ;           // 杈撳叆IQ鏁版嵁鐨勬椂閽?       clk
	wire rd_clk             ;           // data_quan_clk鐨?4鍊?     clk*4
	wire out_clk            ;           // rd_clk 鐨?2鍊?           clk*8
	wire rsdec1513_outclk   ;           // out_clk鐨?2鍊?           clk*16
	// rst
    wire rst                ;
    // 
    wire clk_60M           ;
    wire clk_120M           ;
    wire clk_100M           ;
    assign clk_recv_proc = rsdec1513_outclk;
    assign clk_recv_fir = clk_100M;
    clk_ctrl clk_ctrl_u0(
        .SoC_PL_SCLK1   ( SoC_PL_SCLK1      ),
        .clk_120M       ( clk_120M          ),
        .clk_3M         ( clk_3M            ),
        .clk_12M        ( data_quan_clk     ),
        .clk_96M        ( out_clk           ),
        .clk_48M        ( rd_clk            ),
        .clk_192M       ( rsdec1513_outclk  ),
        .clk_100M       ( clk_100M          ),
        .clk_60M        ( clk_60M           ),
        .rst            ( rst               )
    );
    
    
    wire dds_freq_en;
    wire [31:0]dds_freq_send;  
    wire jumpfinish;   //-------------- fot test
    wire time_1ms;
    wire prepare;
    wire send_head_en;
    wire send_data_en;
    send_ctrl send_ctrl_u0(
        .clk_proc         (clk_100M         ),
        .rst              (rst              ),
        .send_en          (send_en          ), 
        .TODH_en          (TODH_en          ),
        .TODL_en          (TODL_en          ),
        .TODH             (TODH             ),
        .TODL             (TODL             ),
        .dds_freq_en      (dds_freq_en      ),
        .dds_freq         (dds_freq_send    ),
        .jumpfinish       (jumpfinish       ), 
        .time_1ms_long    (time_1ms         ),
        .prepare_long     (prepare          ),
        .send_head_en     (send_head_en     ),
        .send_data_en     (send_data_en     )
     );   
    
    wire output_en;
    wire [15:0]output_i;
    wire [15:0]output_q;
    sync_head_send sync_head_send_u0(
         .clk_120M                  (clk_100M     ),
         .rst                       (rst          ),
         .netinfo_en                (netinfo_en   ),
         .netinfo                   (netinfo      ),//组网信息
         .TODL_en                   (TODL_en      ),
         .TODL                      (TODL         ),
         .prepare                   (prepare      ),
         .send_head_en              (send_head_en ),
         .time_1ms                  (time_1ms     ),
         .output_en                 (output_en    ),
         .output_i                  (output_i     ),
         .output_q                  (output_q     )
    );
        
    wire corr_vld;
    wire [4:0]corr_vld_walsh;
    wire [11:0]peak_addr_d;
    //wire signed[15:0]input_i = $signed(16'b0) + $signed(output_i);
    //wire signed[15:0]input_q = $signed(16'b0) + $signed(output_q);
    wire freq_same;
    wire [15:0]recv_synci;
    wire [15:0]recv_syncq;
    assign freq_same = (dds_freq_recv==dds_freq_send)? 1'b1 : 1'b0;
    assign recv_synci_en = freq_same ? output_en : 1'b0;
    assign recv_syncq_en = freq_same ? output_en : 1'b0;
    assign recv_synci = freq_same ? output_i  : 0;
    assign recv_syncq = freq_same ? output_q  : 0;   
    
    cor_sync cor_sync_uO(
        .clk_recv_fir   (clk_recv_fir    ),
        .clk_proc       (clk_100M        ),
        .rst            (rst             ),
        .receive_en     (receive_en      ),   
        .input_i_en     (recv_synci_en   ),
        .input_q_en     (recv_syncq_en   ),
        .input_i        (recv_synci      ),
        .input_q        (recv_syncq      ),    
        .corr_vld       (corr_vld        ),
        .corr_vld_walsh (corr_vld_walsh  ),
        .peak_addr_d    (peak_addr_d     )
    );
    
    wire dds_freq_en_recv;
    wire [31:0]dds_freq_recv;     
    wire [15:0]netinfo_recv;
    wire [15:0] TODL_recv;
    wire netinfo_recv_vld;
    wire TODL_recv_vld;
    recv_ctrl recv_ctrl_u0(
        .clk_proc         (clk_100M        ),
        .rst              (rst             ),
        .receive_en       (receive_en      ),        
        .TODH_en          (TODH_en         ),
        .TODL_en          (TODL_en         ),
        .TODH             (R_TODH          ),
        .TODL             (R_TODL          ),
        .corr_vld         (corr_vld        ),
        .corr_vld_walsh   (corr_vld_walsh  ),     
        .peak_addr_d      (peak_addr_d     ),        
        .dds_freq_en      (dds_freq_en_recv),
        .dds_freq         (dds_freq_recv   ),      
        .netinfo_recv     (netinfo_recv    ),
        .TODL_recv        (TODL_recv       ),
        .netinfo_recv_vld (netinfo_recv_vld),
        .TODL_recv_vld    (TODL_recv_vld   )
    );
         
endmodule
