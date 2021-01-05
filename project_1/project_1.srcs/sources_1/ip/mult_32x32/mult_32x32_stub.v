// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Fri Oct 16 09:10:23 2020
// Host        : yjw running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/sync_project/project_1/project_1.srcs/sources_1/ip/mult_32x32/mult_32x32_stub.v
// Design      : mult_32x32
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *)
module mult_32x32(CLK, A, B, CE, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[15:0],B[15:0],CE,P[31:0]" */;
  input CLK;
  input [15:0]A;
  input [15:0]B;
  input CE;
  output [31:0]P;
endmodule
