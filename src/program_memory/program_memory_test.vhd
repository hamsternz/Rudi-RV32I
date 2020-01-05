--###############################################################################
--# program_memory.vhd  - A generated HDL memory files
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

entity program_memory is
  port ( clk        : in  STD_LOGIC;
         -- Instruction interface
         pc_next    : in  STD_LOGIC_VECTOR(31 downto 0);
         instr_reg  : out STD_LOGIC_VECTOR(31 downto 0);
         -- CPU Bus interface
         bus_busy       : out STD_LOGIC;
         bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
         bus_enable     : in  STD_LOGIC;
         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
end entity;

architecture Behavioral of program_memory is
    
    type a_prog_memory is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
    signal prog_memory : a_prog_memory := (
         0 => x"100015b7",
         1 => x"ffc58113",
         2 => x"154000ef",
         3 => x"ff5ff06f",
         4 => x"ff010113",
         5 => x"00812623",
         6 => x"01010413",
         7 => x"00000013",
         8 => x"100007b7",
         9 => x"0387a783",
         10 => x"0007c783",
         11 => x"0ff7f793",
         12 => x"fe0798e3",
         13 => x"100007b7",
         14 => x"0347a783",
         15 => x"0007c783",
         16 => x"0ff7f793",
         17 => x"00078513",
         18 => x"00c12403",
         19 => x"01010113",
         20 => x"00008067",
         21 => x"fe010113",
         22 => x"00812e23",
         23 => x"02010413",
         24 => x"fea42623",
         25 => x"00000013",
         26 => x"100007b7",
         27 => x"0307a783",
         28 => x"0007c783",
         29 => x"0ff7f793",
         30 => x"fe0798e3",
         31 => x"100007b7",
         32 => x"02c7a783",
         33 => x"fec42703",
         34 => x"0ff77713",
         35 => x"00e78023",
         36 => x"fec42783",
         37 => x"00078513",
         38 => x"01c12403",
         39 => x"02010113",
         40 => x"00008067",
         41 => x"fd010113",
         42 => x"02112623",
         43 => x"02812423",
         44 => x"03010413",
         45 => x"fca42e23",
         46 => x"fe042623",
         47 => x"02c0006f",
         48 => x"fdc42783",
         49 => x"0007c783",
         50 => x"00078513",
         51 => x"f89ff0ef",
         52 => x"fdc42783",
         53 => x"00178793",
         54 => x"fcf42e23",
         55 => x"fec42783",
         56 => x"00178793",
         57 => x"fef42623",
         58 => x"fdc42783",
         59 => x"0007c783",
         60 => x"fc0798e3",
         61 => x"fec42783",
         62 => x"00078513",
         63 => x"02c12083",
         64 => x"02812403",
         65 => x"03010113",
         66 => x"00008067",
         67 => x"fd010113",
         68 => x"02812623",
         69 => x"03010413",
         70 => x"fca42e23",
         71 => x"fe042623",
         72 => x"01c0006f",
         73 => x"fdc42783",
         74 => x"00178793",
         75 => x"fcf42e23",
         76 => x"fec42783",
         77 => x"00178793",
         78 => x"fef42623",
         79 => x"fdc42783",
         80 => x"0007c783",
         81 => x"fe0790e3",
         82 => x"fec42783",
         83 => x"00078513",
         84 => x"02c12403",
         85 => x"03010113",
         86 => x"00008067",
         87 => x"ff010113",
         88 => x"00112623",
         89 => x"00812423",
         90 => x"01010413",
         91 => x"f00007b7",
         92 => x"22478513",
         93 => x"f31ff0ef",
         94 => x"f00007b7",
         95 => x"23878513",
         96 => x"f25ff0ef",
         97 => x"100007b7",
         98 => x"02478513",
         99 => x"f81ff0ef",
         100 => x"00050793",
         101 => x"03078793",
         102 => x"00078513",
         103 => x"eb9ff0ef",
         104 => x"f00007b7",
         105 => x"24478513",
         106 => x"efdff0ef",
         107 => x"100007b7",
         108 => x"02478513",
         109 => x"ef1ff0ef",
         110 => x"100007b7",
         111 => x"02478513",
         112 => x"f4dff0ef",
         113 => x"00050793",
         114 => x"03078793",
         115 => x"00078513",
         116 => x"e85ff0ef",
         117 => x"100007b7",
         118 => x"01078513",
         119 => x"ec9ff0ef",
         120 => x"100007b7",
         121 => x"0407a783",
         122 => x"00010737",
         123 => x"fff70713",
         124 => x"00e7a023",
         125 => x"e1dff0ef",
         126 => x"00050793",
         127 => x"00078513",
         128 => x"e55ff0ef",
         129 => x"100007b7",
         130 => x"03c7a783",
         131 => x"0007a703",
         132 => x"100007b7",
         133 => x"03c7a783",
         134 => x"00170713",
         135 => x"00e7a023",
         136 => x"fd5ff06f",
         137 => x"74737953",
         138 => x"72206d65",
         139 => x"61747365",
         140 => x"0a0d7472",
         141 => x"00000000",
         142 => x"69727453",
         143 => x"6920676e",
         144 => x"00002073",
         145 => x"61686320",
         146 => x"74636172",
         147 => x"20737265",
         148 => x"676e6f6c",
         149 => x"00000a0d",
         others => "000000000001"      & "00001" & "000" & "00001" & "0010011"   -- r01 <= r01 + 1
    );
    attribute keep      : string;
    attribute ram_style : string;
    
    signal data_valid : STD_LOGIC := '1';
begin

------------------------
-- PROGRAM ROM INTERFACE
------------------------
process(clk)
    begin
        if rising_edge(clk) then
            if pc_next(31 downto 12) = x"F0000" then 
                instr_reg <= prog_memory(to_integer(unsigned(pc_next(11 downto 2))));
            else
                instr_reg <= (others => '0');
            end if; 
        end if;
    end process;

---------------------------------------------------------
-- MAIN SYSTEM BUS INTERFACE
---------------------------------------------------------
process(bus_enable, bus_write_mask, data_valid)
begin
    bus_busy <= '0';
    if bus_enable = '1' and bus_write_mask = "0000" then
        if data_valid = '0' then
           bus_busy <= '1';
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        data_valid <= '0';
        if bus_enable = '1' then
            -- Writes are ignored

            if bus_write_mask = "0000" and data_valid = '0' then
                data_valid <= '1';
            end if;
            bus_read_data <= prog_memory(to_integer(unsigned(bus_addr)));
        end if;
    end if;
end process;

end Behavioral;
