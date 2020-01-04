H:--###############################################################################
H:--# program_memory.vhd  - A generated HDL memory files
H:--#
H:--# Part of the Rudi-RV32I project
H:--#
H:--# See https://github.com/hamsternz/Rudi-RV32I
H:--#
H:--# MIT License
H:--#
H:--###############################################################################
H:--#
H:--# Copyright (c) 2020 Mike Field
H:--#
H:--# Permission is hereby granted, free of charge, to any person obtaining a copy
H:--# of this software and associated documentation files (the "Software"), to deal
H:--# in the Software without restriction, including without limitation the rights
H:--# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
H:--# copies of the Software, and to permit persons to whom the Software is
H:--# furnished to do so, subject to the following conditions:
H:--#
H:--# The above copyright notice and this permission notice shall be included in all
H:--# copies or substantial portions of the Software.
H:--#
H:--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
H:--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
H:--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
H:--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
H:--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
H:--# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
H:--# SOFTWARE.
H:--#
H:--###############################################################################
H:library IEEE;
H:use IEEE.STD_LOGIC_1164.ALL;
H:use IEEE.numeric_std.all;
H:
H:entity program_memory is
H:  port ( clk        : in  STD_LOGIC;
H:         -- Instruction interface
H:         pc_next    : in  STD_LOGIC_VECTOR(31 downto 0);
H:         instr_reg  : out STD_LOGIC_VECTOR(31 downto 0);
H:         -- CPU Bus interface
H:         bus_busy       : out STD_LOGIC;
H:         bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
H:         bus_enable     : in  STD_LOGIC;
H:         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
H:         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
H:         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
H:end entity;
H:
H:architecture Behavioral of program_memory is
H:    
H:    type a_prog_memory is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
H:    signal prog_memory : a_prog_memory := (
F:         others => "000000000001"      & "00001" & "000" & "00001" & "0010011"   -- r01 <= r01 + 1
F:    );
F:    attribute keep      : string;
F:    attribute ram_style : string;
F:    
F:    signal data_valid : STD_LOGIC := '1';
F:begin
F:
F:------------------------
F:-- PROGRAM ROM INTERFACE
F:------------------------
F:process(clk)
F:    begin
F:        if rising_edge(clk) then
F:            if pc_next(31 downto 12) = x"F0000" then 
F:                instr_reg <= prog_memory(to_integer(unsigned(pc_next(11 downto 2))));
F:            else
F:                instr_reg <= (others => '0');
F:            end if; 
F:        end if;
F:    end process;
F:
F:---------------------------------------------------------
F:-- MAIN SYSTEM BUS INTERFACE
F:---------------------------------------------------------
F:process(bus_enable, bus_write_mask, data_valid)
F:begin
F:    bus_busy <= '0';
F:    if bus_enable = '1' and bus_write_mask = "0000" then
F:        if data_valid = '0' then
F:           bus_busy <= '1';
F:        end if;
F:    end if;
F:end process;
F:
F:process(clk)
F:begin
F:    if rising_edge(clk) then
F:        data_valid <= '0';
F:        if bus_enable = '1' then
F:            -- Writes are ignored
F:
F:            if bus_write_mask = "0000" and data_valid = '0' then
F:                data_valid <= '1';
F:            end if;
F:            bus_read_data <= prog_memory(to_integer(unsigned(bus_addr)));
F:        end if;
F:    end if;
F:end process;
F:
F:end Behavioral;
