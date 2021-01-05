// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Oct 13 21:03:06 2020
// Host        : yjw running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/sync_project/project_1/project_1.srcs/sources_1/ip/syncprotect_lutrom/syncprotect_lutrom_stub.v
// Design      : syncprotect_lutrom
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_9,Vivado 2015.4" *)
module syncprotect_lutrom(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[5:0],d[1:0],clk,we,spo[1:0]" */;
  input [5:0]a;
  input [1:0]d;
  input clk;
  input we;
  output [1:0]spo;
endmodule
