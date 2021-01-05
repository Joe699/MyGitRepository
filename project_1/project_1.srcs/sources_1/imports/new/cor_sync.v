`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/12 11:57:05
// Design Name: 
// Module Name: cor_sync
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
module cor_sync #(
    parameter WIDTH_DATA_RECV = 16
    )(
	input wire clk_recv_fir,
	input wire clk_proc,
	input wire rst,
	input wire receive_en,

	input wire input_i_en,
	input wire input_q_en,
	input wire signed[WIDTH_DATA_RECV-1:0]input_i,
	input wire signed[WIDTH_DATA_RECV-1:0]input_q,

	output reg          corr_vld        = 1'b0,
	output reg [4:0]    corr_vld_walsh  = 5'b11111,
	output reg [11:0]   peak_addr_d     = 12'd0
    );
	localparam GAP_WALSHLENxRATE = 32; // 32*1   1 is sample rate
	//////////////////////////////////////////////////////////////////////////////
	////     store input(i,q) to ram
	//////////////////////////////////////////////////////////////////////////////
	wire [11:0]ram_i_addr;
    wire [11:0]ram_q_addr;
    reg  [11:0]rd_addr = 12'd0;
    reg  [11:0]wr_i_addr = 12'd0;
    reg  [11:0]wr_q_addr = 12'd0;
    wire [WIDTH_DATA_RECV-1:0]rd_i_data;
    wire [WIDTH_DATA_RECV-1:0]rd_q_data;
    always @(posedge clk_recv_fir)begin
		if(input_i_en & receive_en)
			wr_i_addr <= wr_i_addr + 12'd1;
		else
			wr_i_addr <= wr_i_addr;
	end 
	always @(posedge clk_recv_fir)begin
		if(input_q_en & receive_en)
			wr_q_addr <= wr_q_addr + 12'd1;
		else
			wr_q_addr <= wr_q_addr;
	end  	

    assign ram_i_addr = input_i_en ? wr_i_addr : rd_addr;
    assign ram_q_addr = input_q_en ? wr_q_addr : rd_addr;
	ram_2port_0 receive_symb_i(
		.clka            				( clk_recv_fir			                ),   
		.ena              				( 1'b1			                        ),
		.wea              				( input_i_en			                ),
		.addra           			    ( ram_i_addr			                ),
		.dina            				( input_i[WIDTH_DATA_RECV-1:0]			),
		.douta           			    ( rd_i_data				                )
	);
        
	ram_2port_0 receive_symb_q(
		.clka              				( clk_recv_fir			                ),   
		.ena                			( 1'b1			                        ),
		.wea                			( input_q_en			                ),
		.addra             				( ram_q_addr			                ),
		.dina              				( input_q[WIDTH_DATA_RECV-1:0]			),
		.douta             				( rd_q_data				                )
	);  	
	//////////////////////////////////////////////////////////////////////////////
	////     store input_sum5(i,q) to ram
	//////////////////////////////////////////////////////////////////////////////
	reg input_wren_d1   = 1'b0;
	reg input_wren_d2   = 1'b0;
	reg input_wren_d3   = 1'b0;
	reg cal_corr_str    = 1'b0;
	reg rd_en           = 1'b0;
	
	reg [11:0]	wr_i_addr_tmp1  = 12'd0;
	reg [11:0]	wr_i_addr_tmp2  = 12'd0;
	reg [2:0]	cnt_rd_input    = 3'd0;
	reg 			rd_en_d1    = 1'b0;
	reg 			rd_en_d2    = 1'b0;
	
	reg 			wr_sum5_en = 1'b0;
	reg [11:0] 		wr_sum5_addr = 12'd0;
	reg signed[WIDTH_DATA_RECV+1:0] wr_sum5i_data = {{WIDTH_DATA_RECV+2}{1'b0}};
	reg signed[WIDTH_DATA_RECV+1:0] wr_sum5q_data = {{WIDTH_DATA_RECV+2}{1'b0}};
	// start 
	always @(posedge clk_proc)begin
		input_wren_d1 	<= input_i_en & receive_en;				// cross clock proc
		input_wren_d2 	<= input_wren_d1;
		input_wren_d3 	<= input_wren_d2;
		cal_corr_str 	<= (~input_wren_d2) & input_wren_d3;
	end
	// rd data every 32*4 point
	always @(posedge clk_proc)begin
		wr_i_addr_tmp1 	<= wr_i_addr;					// cross clock proc
		wr_i_addr_tmp2 	<= wr_i_addr_tmp1;				// cross clock proc
	end
	always @(posedge clk_proc)begin
		if(cal_corr_str)
			rd_addr <= wr_i_addr_tmp2 - 12'd1;
		else if(rd_en)
			rd_addr <= rd_addr - GAP_WALSHLENxRATE; // 32*采样倍数
		else
			rd_addr <= rd_addr;
	end
	always @(posedge clk_proc)begin
		if(cal_corr_str)
			rd_en <= 1'b1;
		else if(cnt_rd_input==3'd4)   // 取5个数累加
			rd_en <= 1'b0;
		else
			rd_en <= rd_en;
	end
    always @(posedge clk_proc)begin
		if(cal_corr_str)
			cnt_rd_input <= 3'd0;
		else if(rd_en)
			cnt_rd_input <= cnt_rd_input + 3'b1;
		else 
			cnt_rd_input <= cnt_rd_input;
	end
	always @(posedge clk_proc)begin
        rd_en_d1 <= rd_en;
        rd_en_d2 <= rd_en_d1;
		wr_sum5_en <= rd_en_d2 & (~rd_en_d1); 
	end
	always @(posedge clk_proc)begin
        if(wr_sum5_en)
			wr_sum5_addr <= wr_sum5_addr + 12'd1;
		else
			wr_sum5_addr <= wr_sum5_addr;
	end
	always @(posedge clk_proc)begin
		if(cal_corr_str)
			wr_sum5i_data <= {{WIDTH_DATA_RECV+2}{1'b0}};
		else if(rd_en_d1)
			wr_sum5i_data <= $signed(wr_sum5i_data) + $signed({{2{rd_i_data[WIDTH_DATA_RECV-1]}}, rd_i_data});
		else
			wr_sum5i_data <= wr_sum5i_data;
	end
	always @(posedge clk_proc)begin
		if(cal_corr_str)
			wr_sum5q_data <= {{WIDTH_DATA_RECV+2}{1'b0}};
		else if(rd_en_d1)
			wr_sum5q_data <= $signed(wr_sum5q_data) + $signed({{2{rd_q_data[WIDTH_DATA_RECV-1]}}, rd_q_data});
		else
			wr_sum5q_data <= wr_sum5q_data;
	end

	reg rd_sum5i_en = 1'b0;
	reg rd_sum5q_en = 1'b0;
	wire [11:0]sum5_addr;
	reg  [11:0]rd_sum5_addr = 12'b0;
	wire signed[WIDTH_DATA_RECV+1:0]rd_sum5i_data;
	wire signed[WIDTH_DATA_RECV+1:0]rd_sum5q_data;
	assign sum5_addr = wr_sum5_en ? wr_sum5_addr : rd_sum5_addr;
	// 存放5个数累加后的序列，后续只需要取这个序列计算相关峰即可，每次取32个
	ram_sum ram_sum_i_u0(
		.clka 	( clk_proc		    ),
		.ena 	( 1'b1			    ),
		.wea 	( wr_sum5_en	    ),
		.addra 	( sum5_addr		    ),
		.dina 	( wr_sum5i_data	    ),
		.douta 	( rd_sum5i_data	    )
	);
	ram_sum ram_sum_q_u0(
		.clka 	( clk_proc		    ),
		.ena 	( 1'b1			    ),
		.wea 	( wr_sum5_en		),
		.addra 	( sum5_addr		    ),
		.dina 	( wr_sum5q_data	    ),
		.douta 	( rd_sum5q_data	    )
	);
	//////////////////////////////////////////////////////////////////////////////
	////     cal corr
	//////////////////////////////////////////////////////////////////////////////
	reg signed[31:0] cor_i = 32'd0;
	reg signed[31:0] cor_q = 32'd0;
	
	reg [5:0] cnt_cor	= 6'd0;
	reg  rd_cor_vld		= 1'b0;
	reg  rd_cor_vld_d1	= 1'b0;
    //取一个walsh码长做相关
	always @(posedge clk_proc)begin
		if(wr_sum5_en)
            cnt_cor <= 6'd32;
		else if(|cnt_cor)
			cnt_cor <= cnt_cor - 6'd1;
		else
			cnt_cor <= cnt_cor;
	end
	always @(posedge clk_proc)begin
		rd_cor_vld_d1 <= rd_cor_vld;
		rd_cor_vld <= (|cnt_cor);
	end
	always @(posedge clk_proc)begin
		if(wr_sum5_en)
			rd_sum5_addr <= wr_sum5_addr;
		else if(|cnt_cor)
			rd_sum5_addr <= rd_sum5_addr - 12'd1;
		else
			rd_sum5_addr <= rd_sum5_addr;
	end
    // 存器拷贝，防止扇出过大
	reg signed [WIDTH_DATA_RECV+1:0]rd_sum5i_data_copy1 = {{WIDTH_DATA_RECV+2}{1'b0}}; reg signed [WIDTH_DATA_RECV+1:0]rd_sum5q_data_copy1 = {{WIDTH_DATA_RECV+2}{1'b0}};
	reg signed [WIDTH_DATA_RECV+1:0]rd_sum5i_data_copy2 = {{WIDTH_DATA_RECV+2}{1'b0}}; reg signed [WIDTH_DATA_RECV+1:0]rd_sum5q_data_copy2 = {{WIDTH_DATA_RECV+2}{1'b0}};
	reg signed [WIDTH_DATA_RECV+1:0]rd_sum5i_data_copy3 = {{WIDTH_DATA_RECV+2}{1'b0}}; reg signed [WIDTH_DATA_RECV+1:0]rd_sum5q_data_copy3 = {{WIDTH_DATA_RECV+2}{1'b0}};
	reg signed [WIDTH_DATA_RECV+1:0]rd_sum5i_data_copy4 = {{WIDTH_DATA_RECV+2}{1'b0}}; reg signed [WIDTH_DATA_RECV+1:0]rd_sum5q_data_copy4 = {{WIDTH_DATA_RECV+2}{1'b0}};
	always @(posedge clk_proc)begin
        rd_sum5i_data_copy1 <= rd_sum5i_data; rd_sum5q_data_copy1 <= rd_sum5q_data;
        rd_sum5i_data_copy2 <= rd_sum5i_data; rd_sum5q_data_copy2 <= rd_sum5q_data;
        rd_sum5i_data_copy3 <= rd_sum5i_data; rd_sum5q_data_copy3 <= rd_sum5q_data;
        rd_sum5i_data_copy4 <= rd_sum5i_data; rd_sum5q_data_copy4 <= rd_sum5q_data;
	end

	wire [11:0] peak_addr_d_walsh0; wire [11:0] peak_addr_d_walsh10;
	wire [11:0] peak_addr_d_walsh1; wire [11:0] peak_addr_d_walsh11;
	wire [11:0] peak_addr_d_walsh2; wire [11:0] peak_addr_d_walsh12;
	wire [11:0] peak_addr_d_walsh3; wire [11:0] peak_addr_d_walsh13;
	wire [11:0] peak_addr_d_walsh4; wire [11:0] peak_addr_d_walsh14;
	wire [11:0] peak_addr_d_walsh5; wire [11:0] peak_addr_d_walsh15;
	wire [11:0] peak_addr_d_walsh6; wire [11:0] peak_addr_d_walsh16;
	wire [11:0] peak_addr_d_walsh7; wire [11:0] peak_addr_d_walsh17;
	wire [11:0] peak_addr_d_walsh8; wire [11:0] peak_addr_d_walsh18;
	wire [11:0] peak_addr_d_walsh9; wire [11:0] peak_addr_d_walsh19;
    wire [11:0] peak_addr_d_walsh20;wire [11:0] peak_addr_d_walsh21;
	wire corr_vld_walsh0;           wire corr_vld_walsh10; 
	wire corr_vld_walsh1;           wire corr_vld_walsh11; 
	wire corr_vld_walsh2;           wire corr_vld_walsh12; 
	wire corr_vld_walsh3;           wire corr_vld_walsh13; 
	wire corr_vld_walsh4;           wire corr_vld_walsh14; 
	wire corr_vld_walsh5;           wire corr_vld_walsh15; 
	wire corr_vld_walsh6;           wire corr_vld_walsh16; 
	wire corr_vld_walsh7;           wire corr_vld_walsh17; 
	wire corr_vld_walsh8;           wire corr_vld_walsh18; 
	wire corr_vld_walsh9;           wire corr_vld_walsh19; 
    wire corr_vld_walsh20;          wire corr_vld_walsh21;
    reg [21:0] corr_vld_walsh_tmp = 22'd0;
	always @(posedge clk_proc)begin
        corr_vld_walsh_tmp <= {corr_vld_walsh21,corr_vld_walsh20,corr_vld_walsh19,corr_vld_walsh18,corr_vld_walsh17,corr_vld_walsh16,
                        corr_vld_walsh15,corr_vld_walsh14,corr_vld_walsh13,corr_vld_walsh12,corr_vld_walsh11,corr_vld_walsh10,
                        corr_vld_walsh9,corr_vld_walsh8,corr_vld_walsh7,corr_vld_walsh6,corr_vld_walsh5,corr_vld_walsh4,
                        corr_vld_walsh3,corr_vld_walsh2,corr_vld_walsh1,corr_vld_walsh0};
	end
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),// 接收数据位宽，AD DA均16位，此处是为了灵活
		.WALSH_WORD         ( 32'hC33C3CC3		    ) // 本地wlsh码，和发送walshtable里面的walsh码一一对应
		//.THRESHOLD 	        ( 32'd25000000			)// 相关值阈值，需要根据实际情况调整
	) cor_walsh0(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh0		),
		.corr_vld 	( corr_vld_walsh0		)
    );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hAAAAAAAA		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh1(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh1		),
		.corr_vld 	( corr_vld_walsh1		)
    );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hCCCCCCCC		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh2(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh2		),
		.corr_vld 	( corr_vld_walsh2		)
    );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'h99999999		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh3(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh3		),
		.corr_vld 	( corr_vld_walsh3		)
    );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hF0F0F0F0		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh4(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh4		),
		.corr_vld 	( corr_vld_walsh4		)
    );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hA5A5A5A5		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh5(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy1	),
		.mk_q		( rd_sum5q_data_copy1	),
	
		.peak_addr_d( peak_addr_d_walsh5		),
		.corr_vld 	( corr_vld_walsh5		)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hC3C3C3C3		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh6(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh6		),
		.corr_vld 	( corr_vld_walsh6			)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'h96969696		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh7(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh7		),
		.corr_vld 	( corr_vld_walsh7			)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hFF00FF00		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh8(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh8		),
		.corr_vld 	( corr_vld_walsh8			)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hAA55AA55		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh9(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh9		),
		.corr_vld 	( corr_vld_walsh9			)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hCC33CC33		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh10(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh10		),
		.corr_vld 	( corr_vld_walsh10			)
       );	
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'h99669966		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh11(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy2	),
		.mk_q		( rd_sum5q_data_copy2	),
	
		.peak_addr_d( peak_addr_d_walsh11		),
		.corr_vld 	( corr_vld_walsh11			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hF00FF00F		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh12(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh12		),
		.corr_vld 	( corr_vld_walsh12			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hA55AA55A		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh13(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh13		),
		.corr_vld 	( corr_vld_walsh13			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hC33CC33C		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh14(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh14		),
		.corr_vld 	( corr_vld_walsh14			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'h96699669		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh15(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh15		),
		.corr_vld 	( corr_vld_walsh15			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hFFFF0000		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh16(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh16		),
		.corr_vld 	( corr_vld_walsh16			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hAAAA5555		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh17(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy3	),
		.mk_q		( rd_sum5q_data_copy3	),
	
		.peak_addr_d( peak_addr_d_walsh17		),
		.corr_vld 	( corr_vld_walsh17			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hCCCC3333		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh18(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy4	),
		.mk_q		( rd_sum5q_data_copy4	),
	
		.peak_addr_d( peak_addr_d_walsh18		),
		.corr_vld 	( corr_vld_walsh18			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'h99996666		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh19(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy4	),
		.mk_q		( rd_sum5q_data_copy4	),
	
		.peak_addr_d( peak_addr_d_walsh19		),
		.corr_vld 	( corr_vld_walsh19			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hF0F00F0F		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh20(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy4	),
		.mk_q		( rd_sum5q_data_copy4	),
	
		.peak_addr_d( peak_addr_d_walsh20		),
		.corr_vld 	( corr_vld_walsh20			)
       );
	cor_walsh #(
		.WIDTH_DATA_RECV    ( WIDTH_DATA_RECV		),
		.WALSH_WORD  ( 32'hA5A55A5A		)
		//.THRESHOLD 	( 32'd25000000			)
	) cor_walsh21(
		.clk_proc	( clk_proc				),
		.rst		( rst					),
		.addr		( wr_sum5_addr			),
		.mk_en		( rd_cor_vld_d1			),
		.mk_str		( wr_sum5_en				),
		.mk_i		( rd_sum5i_data_copy4	),
		.mk_q		( rd_sum5q_data_copy4	),
	
		.peak_addr_d( peak_addr_d_walsh21		),
		.corr_vld 	( corr_vld_walsh21			)
    );
	// 将多个相关结果作一个封装，方便控制模块处理
    always @(posedge clk_proc)begin
		if(rst)begin
            corr_vld_walsh  <= 5'd0;
			peak_addr_d     <= 12'b0;end
		else
            case(corr_vld_walsh_tmp)
                22'b0000_0000_0000_0000_0000_01: begin corr_vld_walsh <= 5'd1; peak_addr_d <= peak_addr_d_walsh0;end
                22'b0000_0000_0000_0000_0000_10: begin corr_vld_walsh <= 5'd2; peak_addr_d <= peak_addr_d_walsh1;end
                22'b0000_0000_0000_0000_0001_00: begin corr_vld_walsh <= 5'd3; peak_addr_d <= peak_addr_d_walsh2;end
                22'b0000_0000_0000_0000_0010_00: begin corr_vld_walsh <= 5'd4; peak_addr_d <= peak_addr_d_walsh3;end
                22'b0000_0000_0000_0000_0100_00: begin corr_vld_walsh <= 5'd5; peak_addr_d <= peak_addr_d_walsh4;end
                22'b0000_0000_0000_0000_1000_00: begin corr_vld_walsh <= 5'd6; peak_addr_d <= peak_addr_d_walsh5;end
                22'b0000_0000_0000_0001_0000_00: begin corr_vld_walsh <= 5'd7; peak_addr_d <= peak_addr_d_walsh6;end
                22'b0000_0000_0000_0010_0000_00: begin corr_vld_walsh <= 5'd8; peak_addr_d <= peak_addr_d_walsh7;end
                22'b0000_0000_0000_0100_0000_00: begin corr_vld_walsh <= 5'd9; peak_addr_d <= peak_addr_d_walsh8;end
                22'b0000_0000_0000_1000_0000_00: begin corr_vld_walsh <= 5'd10;peak_addr_d <= peak_addr_d_walsh9;end
                22'b0000_0000_0001_0000_0000_00: begin corr_vld_walsh <= 5'd11; peak_addr_d <= peak_addr_d_walsh10;end
                22'b0000_0000_0010_0000_0000_00: begin corr_vld_walsh <= 5'd12; peak_addr_d <= peak_addr_d_walsh11;end
                22'b0000_0000_0100_0000_0000_00: begin corr_vld_walsh <= 5'd13; peak_addr_d <= peak_addr_d_walsh12;end
                22'b0000_0000_1000_0000_0000_00: begin corr_vld_walsh <= 5'd14; peak_addr_d <= peak_addr_d_walsh13;end
                22'b0000_0001_0000_0000_0000_00: begin corr_vld_walsh <= 5'd15; peak_addr_d <= peak_addr_d_walsh14;end
                22'b0000_0010_0000_0000_0000_00: begin corr_vld_walsh <= 5'd16; peak_addr_d <= peak_addr_d_walsh15;end
                22'b0000_0100_0000_0000_0000_00: begin corr_vld_walsh <= 5'd17; peak_addr_d <= peak_addr_d_walsh16;end
                22'b0000_1000_0000_0000_0000_00: begin corr_vld_walsh <= 5'd18; peak_addr_d <= peak_addr_d_walsh17;end
                22'b0001_0000_0000_0000_0000_00: begin corr_vld_walsh <= 5'd19; peak_addr_d <= peak_addr_d_walsh18;end
                22'b0010_0000_0000_0000_0000_00: begin corr_vld_walsh <= 5'd20; peak_addr_d <= peak_addr_d_walsh19;end
                22'b0100_0000_0000_0000_0000_00: begin corr_vld_walsh <= 5'd21; peak_addr_d <= peak_addr_d_walsh20;end
                22'b1000_0000_0000_0000_0000_00: begin corr_vld_walsh <= 5'd22; peak_addr_d <= peak_addr_d_walsh21;end
                default: begin corr_vld_walsh <= corr_vld_walsh; peak_addr_d <= peak_addr_d;end
            endcase
	end
	 always @(posedge clk_proc)begin
		if(rst)
            corr_vld  <= 1'b0;
		else
            corr_vld <= |corr_vld_walsh_tmp;
	end
	
endmodule
