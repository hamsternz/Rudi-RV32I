--###############################################################################
--# register_file.vhd  - The register file
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


entity register_file is
    port ( clk              : in  STD_LOGIC;
           read_port_1_addr : in  STD_LOGIC_VECTOR(4 downto 0);
           read_data_1      : out STD_LOGIC_VECTOR(31 downto 0);       
           read_port_2_addr : in  STD_LOGIC_VECTOR(4 downto 0);
           read_data_2      : out STD_LOGIC_VECTOR(31 downto 0);       
           busy             : in  STD_LOGIC;
           write_port_addr  : in  STD_LOGIC_VECTOR(4 downto 0);       
           write_data       : in  STD_LOGIC_VECTOR(31 downto 0);
           debug_sel        : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data       : out STD_LOGIC_VECTOR(31 downto 0));
end entity;

architecture Behavioral of register_file is
    type a_registers is array(0 to 31) of std_logic_vector(31 downto 0);
    signal registers_1 : a_registers := (others => (others => '0'));  -- NOTE REGISTER 0 *MUST BE KEPT AS ZERO!*
    signal registers_2 : a_registers := (others => (others => '0'));
    signal registers_debug : a_registers := (others => (others => '0'));
begin

    read_data_1 <= registers_1(to_integer(unsigned(read_port_1_addr)));
    read_data_2 <= registers_2(to_integer(unsigned(read_port_2_addr)));
    debug_data  <= registers_debug(to_integer(unsigned(debug_sel)));

write_proc : process(clk)
    begin
        if rising_edge(clk) then
            if write_port_addr /= "00000"  and busy = '0' then
                registers_1(to_integer(unsigned(write_port_addr))) <= write_data;
                registers_2(to_integer(unsigned(write_port_addr))) <= write_data;
                registers_debug(to_integer(unsigned(write_port_addr))) <= write_data;
            end if;
        end if;
    end process;
end Behavioral;
