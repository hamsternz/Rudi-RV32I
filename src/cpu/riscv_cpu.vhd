--###############################################################################
--# riscv_cpu.vhd  - The core cpu
--#
--# Part of the Rudi-RV32I project
--#
--# See https://github.com/hamsternz/Rudi-RV32I
--#
--# MIT License
--#
--###############################################################################
--#
--# Copyright (c) 2020 Mike Field
--#
--# Permission is hereby granted, free of charge, to any person obtaining a copy
--# of this software and associated documentation files (the "Software"), to deal
--# in the Software without restriction, including without limitation the rights
--# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--# copies of the Software, and to permit persons to whom the Software is
--# furnished to do so, subject to the following conditions:
--#
--# The above copyright notice and this permission notice shall be included in all
--# copies or substantial portions of the Software.
--#
--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--# SOFTWARE.
--#
--###############################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity riscv_cpu is
  port ( clk           : in  STD_LOGIC;
         pc_next       : out STD_LOGIC_VECTOR(31 downto 0);
         instr_reg     : in  STD_LOGIC_VECTOR(31 downto 0);

         reset         : in  STD_LOGIC;
         minimize_size : in  STD_LOGIC := '0';

         bus_busy      : in  STD_LOGIC;
         bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
         bus_width     : out STD_LOGIC_VECTOR(1 downto 0);  
         bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
         bus_write     : out STD_LOGIC;
         bus_enable    : out STD_LOGIC;
         bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);

         debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
         debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
         debug_data    : out STD_LOGIC_VECTOR(31 downto 0));
end entity;


architecture Behavioral of riscv_cpu is
--  signal instr_reg             : STD_LOGIC_VECTOR(31 downto 0);
    
    component data_bus_mux_a is
    port ( bus_select     : in  STD_LOGIC_VECTOR( 0 downto 0);
           zero           : in  STD_LOGIC_VECTOR( 0 downto 0);
           reg_read_port  : in  STD_LOGIC_VECTOR(31 downto 0);
           pc             : in  STD_LOGIC_VECTOR(31 downto 0);
           data_bus       : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;


    component sign_extender is
      port ( sign_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0);
         sign_ex_width : in  STD_LOGIC_VECTOR(1 downto 0);
         a             : in  STD_LOGIC_VECTOR(31 downto 0);
         b             : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal sign_extended : STD_LOGIC_VECTOR(31 downto 0);

    component data_bus_mux_b is
    port ( bus_select     : in  STD_LOGIC_VECTOR( 0 downto 0);
           zero           : in  STD_LOGIC_VECTOR( 0 downto 0);
           reg_read_port  : in  STD_LOGIC_VECTOR(31 downto 0);
           immedediate    : in  STD_LOGIC_VECTOR(31 downto 0);
           data_bus       : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;

    component result_bus_mux is
        port ( res_src          : in  STD_LOGIC_VECTOR( 1 downto 0);
               res_alu          : in  STD_LOGIC_VECTOR(31 downto 0);
               res_shifter      : in  STD_LOGIC_VECTOR(31 downto 0);
               res_pc_plus_four : in  STD_LOGIC_VECTOR(31 downto 0);
               res_memory       : in  STD_LOGIC_VECTOR(31 downto 0);
               res_bus          : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;
        
    signal a_bus                 : STD_LOGIC_VECTOR(31 downto 0);
    signal b_bus                 : STD_LOGIC_VECTOR(31 downto 0);
    signal c_bus                 : STD_LOGIC_VECTOR(31 downto 0);
    signal pc                    : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_four          : STD_LOGIC_VECTOR(31 downto 0);

    component decoder is
      port ( reset               : in  STD_LOGIC;
             minimize_size       : in  STD_LOGIC := '0';
             instr               : in  STD_LOGIC_VECTOR(31 downto 0);             
             out_immed           : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         

             out_reg_a           : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
             out_select_a        : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
             out_zero_a          : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

             out_reg_b           : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
             out_select_b        : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
             out_zero_b          : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

             out_bus_width       : out STD_LOGIC_VECTOR(1 downto 0);  
             out_bus_write       : out STD_LOGIC;
             out_bus_enable      : out STD_LOGIC;
             
             out_pc_mode          : out STD_LOGIC_VECTOR(1 downto 0) := "00";
             out_pc_jump_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             out_pc_branch_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             out_loadstore_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');     
             out_alu_mode           : out STD_LOGIC_VECTOR(2 downto 0) := "000";
             out_branch_test_mode   : out STD_LOGIC_VECTOR(2 downto 0) := "000";
             out_branch_test_enable : out STD_LOGIC := '0';
             out_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0) := "00";

             out_sign_ex_mode    : out STD_LOGIC_VECTOR(0 downto 0) := "0";
             out_sign_ex_width   : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
             out_result_src      : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
             out_rdest           : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0'));
    end component;
    
    signal decode_immed           : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
    signal decode_register_a      : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_register_b      : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_select_a        : STD_LOGIC_VECTOR(0 downto 0);
    signal decode_select_b        : STD_LOGIC_VECTOR(0 downto 0);
    signal decode_zero_a          : STD_LOGIC_VECTOR(0 downto 0);
    signal decode_zero_b          : STD_LOGIC_VECTOR(0 downto 0);
             
    signal decode_pc_mode          : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decode_pc_jump_offset   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal decode_pc_branch_offset : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal decode_loadstore_offset : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal decode_alu_mode         : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal decode_branch_test_mode : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal decode_branch_test_enable : STD_LOGIC := '0';
    signal decode_shift_mode       : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decode_bus_write        : STD_LOGIC;
    signal decode_bus_enable       : STD_LOGIC;
    signal decode_bus_width        : STD_LOGIC_VECTOR(1 downto 0);

    signal decode_sign_ex_mode    : STD_LOGIC_VECTOR(0 downto 0);
    signal decode_sign_ex_width   : STD_LOGIC_VECTOR(1 downto 0);
    
    signal decode_result_src      : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
    signal decode_register_dest   : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

    component alu is
      port ( alu_mode        : in  STD_LOGIC_VECTOR(2 downto 0);
             a               : in  STD_LOGIC_VECTOR(31 downto 0);
             b               : in  STD_LOGIC_VECTOR(31 downto 0);
             c               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
    end component;
    signal c_alu               : STD_LOGIC_VECTOR(31 downto 0);


    component shifter is
        port ( shift_mode    : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
               minimize_size : in  STD_LOGIC;
               a             : in  STD_LOGIC_VECTOR(31 downto 0);
               b             : in  STD_LOGIC_VECTOR(31 downto 0);
               c             : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
    end component;
    signal c_shifter         : STD_LOGIC_VECTOR(31 downto 0);
    
    component register_file is
        port ( clk              : in  STD_LOGIC;
               busy             : in  STD_LOGIC;
               read_port_1_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
               read_data_1      : out STD_LOGIC_VECTOR(31 downto 0);       
               read_port_2_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
               read_data_2      : out STD_LOGIC_VECTOR(31 downto 0);       
               write_port_addr  : in  STD_LOGIC_VECTOR( 4 downto 0);       
               write_data       : in  STD_LOGIC_VECTOR(31 downto 0); 
               debug_sel        : in  STD_LOGIC_VECTOR(4 downto 0);
               debug_data       : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal reg_read_data_a      : STD_LOGIC_VECTOR(31 downto 0);       
    signal reg_read_data_b      : STD_LOGIC_VECTOR(31 downto 0); 

    component branch_test is
    port ( branch_test_mode : in  STD_LOGIC_VECTOR(2 downto 0);
           branch_test_enable : in  STD_LOGIC;
           minimize_size      : in  STD_LOGIC;
           a                  : in  STD_LOGIC_VECTOR(31 downto 0);
           b                  : in  STD_LOGIC_VECTOR(31 downto 0);
           take_branch        : out STD_LOGIC);
    end component;

    signal take_branch : std_logic;
    
    component program_counter is
    port ( clk              : in  STD_LOGIC; 
           busy             : in  STD_LOGIC;
           minimize_size    : in  STD_LOGIC;
           
           pc_mode          : in  STD_LOGIC_VECTOR(1 downto 0);
           take_branch      : in  STD_LOGIC;
           pc_jump_offset   : in  STD_LOGIC_VECTOR(31 downto 0);
           pc_branch_offset : in  STD_LOGIC_VECTOR(31 downto 0);
           pc_jumpreg_offset: in  STD_LOGIC_VECTOR(31 downto 0);

           a                : in  STD_LOGIC_VECTOR(31 downto 0);
           
           pc               : out STD_LOGIC_VECTOR(31 downto 0);
           pc_next          : out STD_LOGIC_VECTOR(31 downto 0);
           pc_plus_four     : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;
          

begin
    debug_pc <= pc;
    
    -- Set up the RAM address
    bus_write   <= decode_bus_write;
    bus_enable  <= decode_bus_enable;
    bus_width   <= decode_bus_width;
    bus_dout    <= reg_read_data_b;

process(minimize_size, decode_loadstore_offset, reg_read_data_a, c_alu, decode_immed)
    begin
       if minimize_size = '1' then
           bus_addr  <= c_alu;
       else
           bus_addr  <= std_logic_vector(unsigned(reg_read_data_a)+unsigned(decode_loadstore_offset));
           -- bus_addr  <= std_logic_vector(unsigned(reg_read_data_a)+unsigned(decode_immed));
       end if;
    end process;

i_decoder: decoder port map (
      instr                => instr_reg,
      minimize_size        => minimize_size,
      reset                => reset,

      out_bus_write        => decode_bus_write,
      out_bus_enable       => decode_bus_enable,
      out_bus_width        => decode_bus_width,

      out_immed            => decode_immed,         

      out_reg_a            => decode_register_a,
      out_select_a         => decode_select_a,
      out_zero_a           => decode_zero_a,

      out_reg_b            => decode_register_b,
      out_select_b         => decode_select_b,
      out_zero_b           => decode_zero_b,
      
      out_pc_mode          => decode_pc_mode,
      out_pc_jump_offset   => decode_pc_jump_offset,
      out_pc_branch_offset => decode_pc_branch_offset,
      out_loadstore_offset => decode_loadstore_offset,
    
      out_alu_mode         => decode_alu_mode,
      out_branch_test_mode => decode_branch_test_mode,
      out_branch_test_enable => decode_branch_test_enable,
      out_shift_mode       => decode_shift_mode,
    
      out_result_src       => decode_result_src,         
     
      out_sign_ex_mode     => decode_sign_ex_mode,
      out_sign_ex_width    => decode_sign_ex_width,

      out_rdest            => decode_register_dest);

i_alu: alu port map (
      alu_mode        => decode_alu_mode,
      a               => a_bus,
      b               => b_bus,
      c               => c_alu); 

i_shifter: shifter port map (
      shift_mode      => decode_shift_mode,
      minimize_size   => minimize_size,
      a               => reg_read_data_a, --a_bus,
      b               => b_bus,
      c               => c_shifter); 

i_sign_extender: sign_extender  PORT MAP (
      sign_ex_mode  => decode_sign_ex_mode,
      sign_ex_width => decode_sign_ex_width,
      a             => bus_din,
      b             => sign_extended);

i_result_bus_mux: result_bus_mux port map (
      res_src          => decode_result_src,
      res_alu          => c_alu,
      res_shifter      => c_shifter,
      res_pc_plus_four => pc_plus_four,
      res_memory       => sign_extended,
      res_bus          => c_bus); 

i_register_file: register_file port map (
      clk              => clk,
      read_port_1_addr => decode_register_a,
      read_data_1      => reg_read_data_a,
      read_port_2_addr => decode_register_b,
      read_data_2      => reg_read_data_b,       

      write_port_addr  => decode_register_dest,       
      write_data       => c_bus,
      busy             => bus_busy,

      debug_sel        => debug_sel,
      debug_data       => debug_data);

i_data_bus_mux_a: data_bus_mux_a port map (
      bus_select     => decode_select_a,
      zero           => decode_zero_a,
      reg_read_port  => reg_read_data_a,
      pc             => pc,
      data_bus       => a_bus); 

i_data_bus_mux_b: data_bus_mux_b port map (
      bus_select     => decode_select_b,
      zero           => decode_zero_b,
      reg_read_port  => reg_read_data_b,
      immedediate    => decode_immed,
      data_bus       => b_bus); 

i_branch_test: branch_test port map (
       branch_test_mode   => decode_branch_test_mode,
       branch_test_enable => decode_branch_test_enable,
       minimize_size      => minimize_size,
       a                  => reg_read_data_a,
       b                  => reg_read_data_b,
       take_branch        => take_branch);

i_program_counter: program_counter port map (
       clk              => clk, 
       busy             => bus_busy,
       minimize_size    => minimize_size,
       
       pc_mode          => decode_pc_mode,
       take_branch      => take_branch,
       pc_jump_offset   => decode_pc_jump_offset,
       pc_branch_offset => decode_pc_branch_offset,
       pc_jumpreg_offset=> decode_immed, 
       a                => reg_read_data_a,
       -- outputs
       pc           => pc,
       pc_next      => pc_next,
       pc_plus_four => pc_plus_four); 

end Behavioral;
