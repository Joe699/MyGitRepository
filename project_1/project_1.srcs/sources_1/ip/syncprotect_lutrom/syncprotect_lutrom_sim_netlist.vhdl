-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Tue Oct 13 21:03:06 2020
-- Host        : yjw running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               E:/sync_project/project_1/project_1.srcs/sources_1/ip/syncprotect_lutrom/syncprotect_lutrom_sim_netlist.vhdl
-- Design      : syncprotect_lutrom
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7vx485tffg1157-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity syncprotect_lutrom_spram is
  port (
    spo : out STD_LOGIC_VECTOR ( 1 downto 0 );
    clk : in STD_LOGIC;
    d : in STD_LOGIC_VECTOR ( 1 downto 0 );
    we : in STD_LOGIC;
    a : in STD_LOGIC_VECTOR ( 5 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of syncprotect_lutrom_spram : entity is "spram";
end syncprotect_lutrom_spram;

architecture STRUCTURE of syncprotect_lutrom_spram is
  signal qspo_int : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of qspo_int : signal is "true";
  signal \^spo\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute KEEP : string;
  attribute KEEP of \qspo_int_reg[0]\ : label is "yes";
  attribute equivalent_register_removal : string;
  attribute equivalent_register_removal of \qspo_int_reg[0]\ : label is "no";
  attribute KEEP of \qspo_int_reg[1]\ : label is "yes";
  attribute equivalent_register_removal of \qspo_int_reg[1]\ : label is "no";
begin
  spo(1 downto 0) <= \^spo\(1 downto 0);
\qspo_int_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \^spo\(0),
      Q => qspo_int(0),
      R => '0'
    );
\qspo_int_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \^spo\(1),
      Q => qspo_int(1),
      R => '0'
    );
ram_reg_0_63_0_0: unisim.vcomponents.RAM64X1S
    generic map(
      INIT => X"0000005555555555"
    )
        port map (
      A0 => a(0),
      A1 => a(1),
      A2 => a(2),
      A3 => a(3),
      A4 => a(4),
      A5 => a(5),
      D => d(0),
      O => \^spo\(0),
      WCLK => clk,
      WE => we
    );
ram_reg_0_63_1_1: unisim.vcomponents.RAM64X1S
    generic map(
      INIT => X"0000005555555555"
    )
        port map (
      A0 => a(0),
      A1 => a(1),
      A2 => a(2),
      A3 => a(3),
      A4 => a(4),
      A5 => a(5),
      D => d(1),
      O => \^spo\(1),
      WCLK => clk,
      WE => we
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity syncprotect_lutrom_dist_mem_gen_v8_0_9_synth is
  port (
    spo : out STD_LOGIC_VECTOR ( 1 downto 0 );
    clk : in STD_LOGIC;
    d : in STD_LOGIC_VECTOR ( 1 downto 0 );
    we : in STD_LOGIC;
    a : in STD_LOGIC_VECTOR ( 5 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of syncprotect_lutrom_dist_mem_gen_v8_0_9_synth : entity is "dist_mem_gen_v8_0_9_synth";
end syncprotect_lutrom_dist_mem_gen_v8_0_9_synth;

architecture STRUCTURE of syncprotect_lutrom_dist_mem_gen_v8_0_9_synth is
begin
\gen_sp_ram.spram_inst\: entity work.syncprotect_lutrom_spram
     port map (
      a(5 downto 0) => a(5 downto 0),
      clk => clk,
      d(1 downto 0) => d(1 downto 0),
      spo(1 downto 0) => spo(1 downto 0),
      we => we
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity syncprotect_lutrom_dist_mem_gen_v8_0_9 is
  port (
    a : in STD_LOGIC_VECTOR ( 5 downto 0 );
    d : in STD_LOGIC_VECTOR ( 1 downto 0 );
    dpra : in STD_LOGIC_VECTOR ( 5 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    i_ce : in STD_LOGIC;
    qspo_ce : in STD_LOGIC;
    qdpo_ce : in STD_LOGIC;
    qdpo_clk : in STD_LOGIC;
    qspo_rst : in STD_LOGIC;
    qdpo_rst : in STD_LOGIC;
    qspo_srst : in STD_LOGIC;
    qdpo_srst : in STD_LOGIC;
    spo : out STD_LOGIC_VECTOR ( 1 downto 0 );
    dpo : out STD_LOGIC_VECTOR ( 1 downto 0 );
    qspo : out STD_LOGIC_VECTOR ( 1 downto 0 );
    qdpo : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute C_ADDR_WIDTH : integer;
  attribute C_ADDR_WIDTH of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 6;
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is "0";
  attribute C_DEPTH : integer;
  attribute C_DEPTH of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 64;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is "./";
  attribute C_FAMILY : string;
  attribute C_FAMILY of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is "virtex7";
  attribute C_HAS_CLK : integer;
  attribute C_HAS_CLK of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_HAS_D : integer;
  attribute C_HAS_D of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_HAS_DPO : integer;
  attribute C_HAS_DPO of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_DPRA : integer;
  attribute C_HAS_DPRA of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_I_CE : integer;
  attribute C_HAS_I_CE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QDPO : integer;
  attribute C_HAS_QDPO of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QDPO_CE : integer;
  attribute C_HAS_QDPO_CE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QDPO_CLK : integer;
  attribute C_HAS_QDPO_CLK of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QDPO_RST : integer;
  attribute C_HAS_QDPO_RST of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QDPO_SRST : integer;
  attribute C_HAS_QDPO_SRST of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QSPO : integer;
  attribute C_HAS_QSPO of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QSPO_CE : integer;
  attribute C_HAS_QSPO_CE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QSPO_RST : integer;
  attribute C_HAS_QSPO_RST of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_QSPO_SRST : integer;
  attribute C_HAS_QSPO_SRST of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_HAS_SPO : integer;
  attribute C_HAS_SPO of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_HAS_WE : integer;
  attribute C_HAS_WE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_MEM_INIT_FILE : string;
  attribute C_MEM_INIT_FILE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is "syncprotect_lutrom.mif";
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_PARSER_TYPE : integer;
  attribute C_PARSER_TYPE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_PIPELINE_STAGES : integer;
  attribute C_PIPELINE_STAGES of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_QCE_JOINED : integer;
  attribute C_QCE_JOINED of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_QUALIFY_WE : integer;
  attribute C_QUALIFY_WE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_READ_MIF : integer;
  attribute C_READ_MIF of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_REG_A_D_INPUTS : integer;
  attribute C_REG_A_D_INPUTS of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_REG_DPRA_INPUT : integer;
  attribute C_REG_DPRA_INPUT of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 0;
  attribute C_SYNC_ENABLE : integer;
  attribute C_SYNC_ENABLE of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 1;
  attribute C_WIDTH : integer;
  attribute C_WIDTH of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is 2;
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of syncprotect_lutrom_dist_mem_gen_v8_0_9 : entity is "dist_mem_gen_v8_0_9";
end syncprotect_lutrom_dist_mem_gen_v8_0_9;

architecture STRUCTURE of syncprotect_lutrom_dist_mem_gen_v8_0_9 is
  signal \<const0>\ : STD_LOGIC;
begin
  dpo(1) <= \<const0>\;
  dpo(0) <= \<const0>\;
  qdpo(1) <= \<const0>\;
  qdpo(0) <= \<const0>\;
  qspo(1) <= \<const0>\;
  qspo(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
\synth_options.dist_mem_inst\: entity work.syncprotect_lutrom_dist_mem_gen_v8_0_9_synth
     port map (
      a(5 downto 0) => a(5 downto 0),
      clk => clk,
      d(1 downto 0) => d(1 downto 0),
      spo(1 downto 0) => spo(1 downto 0),
      we => we
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity syncprotect_lutrom is
  port (
    a : in STD_LOGIC_VECTOR ( 5 downto 0 );
    d : in STD_LOGIC_VECTOR ( 1 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    spo : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of syncprotect_lutrom : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of syncprotect_lutrom : entity is "syncprotect_lutrom,dist_mem_gen_v8_0_9,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of syncprotect_lutrom : entity is "syncprotect_lutrom,dist_mem_gen_v8_0_9,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=dist_mem_gen,x_ipVersion=8.0,x_ipCoreRevision=9,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_FAMILY=virtex7,C_ADDR_WIDTH=6,C_DEFAULT_DATA=0,C_DEPTH=64,C_HAS_CLK=1,C_HAS_D=1,C_HAS_DPO=0,C_HAS_DPRA=0,C_HAS_I_CE=0,C_HAS_QDPO=0,C_HAS_QDPO_CE=0,C_HAS_QDPO_CLK=0,C_HAS_QDPO_RST=0,C_HAS_QDPO_SRST=0,C_HAS_QSPO=0,C_HAS_QSPO_CE=0,C_HAS_QSPO_RST=0,C_HAS_QSPO_SRST=0,C_HAS_SPO=1,C_HAS_WE=1,C_MEM_INIT_FILE=syncprotect_lutrom.mif,C_ELABORATION_DIR=./,C_MEM_TYPE=1,C_PIPELINE_STAGES=0,C_QCE_JOINED=0,C_QUALIFY_WE=0,C_READ_MIF=1,C_REG_A_D_INPUTS=0,C_REG_DPRA_INPUT=0,C_SYNC_ENABLE=1,C_WIDTH=2,C_PARSER_TYPE=1}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of syncprotect_lutrom : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of syncprotect_lutrom : entity is "dist_mem_gen_v8_0_9,Vivado 2015.4";
end syncprotect_lutrom;

architecture STRUCTURE of syncprotect_lutrom is
  signal NLW_U0_dpo_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_U0_qdpo_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_U0_qspo_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_FAMILY : string;
  attribute C_FAMILY of U0 : label is "virtex7";
  attribute C_HAS_CLK : integer;
  attribute C_HAS_CLK of U0 : label is 1;
  attribute C_HAS_D : integer;
  attribute C_HAS_D of U0 : label is 1;
  attribute C_HAS_DPO : integer;
  attribute C_HAS_DPO of U0 : label is 0;
  attribute C_HAS_DPRA : integer;
  attribute C_HAS_DPRA of U0 : label is 0;
  attribute C_HAS_QDPO : integer;
  attribute C_HAS_QDPO of U0 : label is 0;
  attribute C_HAS_QDPO_CE : integer;
  attribute C_HAS_QDPO_CE of U0 : label is 0;
  attribute C_HAS_QDPO_CLK : integer;
  attribute C_HAS_QDPO_CLK of U0 : label is 0;
  attribute C_HAS_QDPO_RST : integer;
  attribute C_HAS_QDPO_RST of U0 : label is 0;
  attribute C_HAS_QDPO_SRST : integer;
  attribute C_HAS_QDPO_SRST of U0 : label is 0;
  attribute C_HAS_WE : integer;
  attribute C_HAS_WE of U0 : label is 1;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of U0 : label is 1;
  attribute C_QCE_JOINED : integer;
  attribute C_QCE_JOINED of U0 : label is 0;
  attribute C_REG_DPRA_INPUT : integer;
  attribute C_REG_DPRA_INPUT of U0 : label is 0;
  attribute c_addr_width : integer;
  attribute c_addr_width of U0 : label is 6;
  attribute c_default_data : string;
  attribute c_default_data of U0 : label is "0";
  attribute c_depth : integer;
  attribute c_depth of U0 : label is 64;
  attribute c_elaboration_dir : string;
  attribute c_elaboration_dir of U0 : label is "./";
  attribute c_has_i_ce : integer;
  attribute c_has_i_ce of U0 : label is 0;
  attribute c_has_qspo : integer;
  attribute c_has_qspo of U0 : label is 0;
  attribute c_has_qspo_ce : integer;
  attribute c_has_qspo_ce of U0 : label is 0;
  attribute c_has_qspo_rst : integer;
  attribute c_has_qspo_rst of U0 : label is 0;
  attribute c_has_qspo_srst : integer;
  attribute c_has_qspo_srst of U0 : label is 0;
  attribute c_has_spo : integer;
  attribute c_has_spo of U0 : label is 1;
  attribute c_mem_init_file : string;
  attribute c_mem_init_file of U0 : label is "syncprotect_lutrom.mif";
  attribute c_parser_type : integer;
  attribute c_parser_type of U0 : label is 1;
  attribute c_pipeline_stages : integer;
  attribute c_pipeline_stages of U0 : label is 0;
  attribute c_qualify_we : integer;
  attribute c_qualify_we of U0 : label is 0;
  attribute c_read_mif : integer;
  attribute c_read_mif of U0 : label is 1;
  attribute c_reg_a_d_inputs : integer;
  attribute c_reg_a_d_inputs of U0 : label is 0;
  attribute c_sync_enable : integer;
  attribute c_sync_enable of U0 : label is 1;
  attribute c_width : integer;
  attribute c_width of U0 : label is 2;
begin
U0: entity work.syncprotect_lutrom_dist_mem_gen_v8_0_9
     port map (
      a(5 downto 0) => a(5 downto 0),
      clk => clk,
      d(1 downto 0) => d(1 downto 0),
      dpo(1 downto 0) => NLW_U0_dpo_UNCONNECTED(1 downto 0),
      dpra(5 downto 0) => B"000000",
      i_ce => '1',
      qdpo(1 downto 0) => NLW_U0_qdpo_UNCONNECTED(1 downto 0),
      qdpo_ce => '1',
      qdpo_clk => '0',
      qdpo_rst => '0',
      qdpo_srst => '0',
      qspo(1 downto 0) => NLW_U0_qspo_UNCONNECTED(1 downto 0),
      qspo_ce => '1',
      qspo_rst => '0',
      qspo_srst => '0',
      spo(1 downto 0) => spo(1 downto 0),
      we => we
    );
end STRUCTURE;
