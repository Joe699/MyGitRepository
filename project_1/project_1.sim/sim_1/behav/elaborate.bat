@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto f5a0df1320994e459de06066fa9bc256 -m64 --debug typical --relax --mt 2 -L xbip_utils_v3_0_5 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xil_defaultlib -L dist_mem_gen_v8_0_9 -L blk_mem_gen_v8_3_1 -L unisims_ver -L unimacro_ver -L secureip --snapshot test_recv_new_behav xil_defaultlib.test_recv_new xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
