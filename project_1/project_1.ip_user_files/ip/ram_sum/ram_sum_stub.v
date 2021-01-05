// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Fri Oct 16 09:09:24 2020
// Host        : yjw running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/sync_project/project_1/project_1.srcs/sources_1/ip/ram_sum/ram_sum_stub.v
// Design      : ram_sum
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_1,Vivado 2015.4" *)
module ram_sum(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[11:0],dina[17:0],douta[17:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [11:0]addra;
  input [17:0]dina;
  output [17:0]douta;
endmodule
