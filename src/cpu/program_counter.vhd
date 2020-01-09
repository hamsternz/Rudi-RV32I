--###############################################################################
--# program_counter.vhd  - Management of the program counter and related signals
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


entity program_counter is
    port ( clk                : in  STD_LOGIC; 
           busy               : in  STD_LOGIC;
           minimize_size      : in  STD_LOGIC;
           
           pc_mode            : in  STD_LOGIC_VECTOR(1 downto 0);
           take_branch        : in  STD_LOGIC;
           pc_jump_offset     : in  STD_LOGIC_VECTOR(31 downto 0);
           pc_branch_offset   : in  STD_LOGIC_VECTOR(31 downto 0);
           pc_jumpreg_offset  : in  STD_LOGIC_VECTOR(31 downto 0);
           a                  : in  STD_LOGIC_VECTOR(31 downto 0);
           
           pc                 : out STD_LOGIC_VECTOR(31 downto 0);
           pc_next            : out STD_LOGIC_VECTOR(31 downto 0);
           pc_plus_four       : out STD_LOGIC_VECTOR(31 downto 0)); 
end entity;

architecture Behavioral of program_counter is
   signal current_pc   : unsigned(31 downto 0) := x"FFFFFFF0";
   signal next_instr   : unsigned(31 downto 0);
   signal test_is_true : STD_LOGIC;
   
   constant PC_JMP_RELATIVE             : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant PC_JMP_REG_RELATIVE         : STD_LOGIC_VECTOR(1 downto 0) := "01";
   constant PC_JMP_RELATIVE_CONDITIONAL : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant PC_RESET_STATE              : STD_LOGIC_VECTOR(1 downto 0) := "11";

   constant BRANCH_TEST_EQ                     : STD_LOGIC_VECTOR(2 downto 0) := "000";
   constant BRANCH_TEST_NE                     : STD_LOGIC_VECTOR(2 downto 0) := "001";
   constant BRANCH_TEST_TRUE                   : STD_LOGIC_VECTOR(2 downto 0) := "010";
   constant BRANCH_TEST_FALSE                  : STD_LOGIC_VECTOR(2 downto 0) := "011";
   constant BRANCH_TEST_LT                     : STD_LOGIC_VECTOR(2 downto 0) := "100";
   constant BRANCH_TEST_GE                     : STD_LOGIC_VECTOR(2 downto 0) := "101";
   constant BRANCH_TEST_LTU                    : STD_LOGIC_VECTOR(2 downto 0) := "110";
   constant BRANCH_TEST_GEU                    : STD_LOGIC_VECTOR(2 downto 0) := "111";

   constant RESET_VECTOR                       : STD_LOGIC_VECTOR(31 downto 0) := x"F0000000";

begin

    pc           <= std_logic_vector(current_pc);
    pc_plus_four <= std_logic_vector(current_pc + 4);


process(next_instr, busy,current_pc)
    begin
       if busy = '1' then
           pc_next      <= std_logic_vector(current_pc);
       else
           pc_next      <= std_logic_vector(next_instr);
       end if;
    end process;

process(pc_mode, current_pc, a, pc_branch_offset, pc_jump_offset, take_branch, minimize_size)
    variable add_LHS      : unsigned(31 downto 0);
    variable add_RHS      : unsigned(31 downto 0);
    begin
        if minimize_size = '1' then
            --  Uses 74 LUTs   
            case pc_mode is
                when PC_JMP_RELATIVE_CONDITIONAL => add_LHS := unsigned(current_pc);
                when PC_JMP_RELATIVE             => add_LHS := unsigned(current_pc);
                when PC_JMP_REG_RELATIVE         => add_LHS := unsigned(a);
                when others                      => add_LHS := unsigned(RESET_VECTOR);
            end case;

            case pc_mode is
                when PC_JMP_RELATIVE_CONDITIONAL => 
                    if take_branch = '1' then
                        add_RHS := unsigned(pc_branch_offset);
                    else
                        add_RHS := to_unsigned(4,32);
                    end if;
                when PC_JMP_RELATIVE             => add_RHS := unsigned(pc_jump_offset);
                when PC_JMP_REG_RELATIVE         => add_RHS := unsigned(pc_jumpreg_offset);
                when others                      => add_RHS := x"00000000";
            end case;
            next_instr <= (add_LHS  + add_RHS) AND x"FFFFFFFC";
        else
            --  Uses 155 LUTs   
            if take_branch = '1' then
                next_instr <= (unsigned(current_pc)  + unsigned(pc_branch_offset)) AND x"FFFFFFFC";
            else
                case pc_mode is
                    when PC_JMP_RELATIVE_CONDITIONAL => next_instr <= current_pc + 4;
                    when PC_JMP_RELATIVE             => next_instr <= (unsigned(current_pc)  + unsigned(pc_jump_offset)) AND x"FFFFFFFC";
                    when PC_JMP_REG_RELATIVE         => next_instr <= (unsigned(a)           + unsigned(pc_jumpreg_offset)) AND x"FFFFFFFC";
                    when PC_RESET_STATE              => next_instr <= x"F0000000";
                    when others                      => next_instr <= x"F0000000";
                end case;
            end if;
        end if;
    end process;


process(clk) 
    begin
        if rising_edge(clk) then
            if busy = '0' then
                current_pc <= next_instr;
            end if;
        end if;
    end process;

end Behavioral;
