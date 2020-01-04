H:--###############################################################################
H:--# ram_memory.vhd  - A generated HDL memory files
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
H:entity ram_memory is
H:  port ( clk            : in  STD_LOGIC;
H:         bus_busy       : out STD_LOGIC;
H:         bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
H:         bus_enable     : in  STD_LOGIC;
H:         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
H:         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
H:         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
H:end entity;
H: 
H:architecture Behavioral of ram_memory is
H:    type a_memory is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
H:    signal memory : a_memory := (
F:       others => (others=>'0'));
F:    signal data_valid : STD_LOGIC := '1';
F:begin
F:
F:
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
F:            if bus_write_mask(0) = '1' then
F:                memory(to_integer(unsigned(bus_addr)))( 7 downto  0) <= bus_write_data( 7 downto  0);
F:            end if;
F:            if bus_write_mask(1) = '1' then
F:                memory(to_integer(unsigned(bus_addr)))(15 downto  8) <= bus_write_data(15 downto  8);
F:            end if;
F:            if bus_write_mask(2) = '1' then
F:                memory(to_integer(unsigned(bus_addr)))(23 downto 16) <= bus_write_data(23 downto 16);
F:            end if;
F:            if bus_write_mask(3) = '1' then
F:                memory(to_integer(unsigned(bus_addr)))(31 downto 24) <= bus_write_data(31 downto 24);
F:            end if;
F:
F:            if bus_write_mask = "0000" and data_valid = '0' then
F:                data_valid <= '1';
F:            end if; 
F:            bus_read_data <= memory(to_integer(unsigned(bus_addr)));
F:        end if;
F:    end if;
F:end process;
F:
F:end Behavioral;
