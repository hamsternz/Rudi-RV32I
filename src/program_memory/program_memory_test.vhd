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
         2 => x"11c000ef",
         3 => x"ff5ff06f",
         4 => x"fd010113",
         5 => x"02812623",
         6 => x"03010413",
         7 => x"fca42e23",
         8 => x"e00007b7",
         9 => x"fef42623",
         10 => x"e00007b7",
         11 => x"00478793",
         12 => x"fef42423",
         13 => x"00000013",
         14 => x"fe842783",
         15 => x"0007c783",
         16 => x"0ff7f793",
         17 => x"fe079ae3",
         18 => x"fdc42783",
         19 => x"0ff7f713",
         20 => x"fec42783",
         21 => x"00e78023",
         22 => x"fdc42783",
         23 => x"00078513",
         24 => x"02c12403",
         25 => x"03010113",
         26 => x"00008067",
         27 => x"fd010113",
         28 => x"02112623",
         29 => x"02812423",
         30 => x"03010413",
         31 => x"fca42e23",
         32 => x"fe042623",
         33 => x"02c0006f",
         34 => x"fdc42783",
         35 => x"0007c783",
         36 => x"00078513",
         37 => x"f7dff0ef",
         38 => x"fdc42783",
         39 => x"00178793",
         40 => x"fcf42e23",
         41 => x"fec42783",
         42 => x"00178793",
         43 => x"fef42623",
         44 => x"fdc42783",
         45 => x"0007c783",
         46 => x"fc0798e3",
         47 => x"fec42783",
         48 => x"00078513",
         49 => x"02c12083",
         50 => x"02812403",
         51 => x"03010113",
         52 => x"00008067",
         53 => x"fd010113",
         54 => x"02812623",
         55 => x"03010413",
         56 => x"fca42e23",
         57 => x"fe042623",
         58 => x"01c0006f",
         59 => x"fdc42783",
         60 => x"00178793",
         61 => x"fcf42e23",
         62 => x"fec42783",
         63 => x"00178793",
         64 => x"fef42623",
         65 => x"fdc42783",
         66 => x"0007c783",
         67 => x"fe0790e3",
         68 => x"fec42783",
         69 => x"00078513",
         70 => x"02c12403",
         71 => x"03010113",
         72 => x"00008067",
         73 => x"ff010113",
         74 => x"00112623",
         75 => x"00812423",
         76 => x"01010413",
         77 => x"f00007b7",
         78 => x"1ac78513",
         79 => x"f31ff0ef",
         80 => x"f00007b7",
         81 => x"1c078513",
         82 => x"f25ff0ef",
         83 => x"100007b7",
         84 => x"02478513",
         85 => x"f81ff0ef",
         86 => x"00050793",
         87 => x"03078793",
         88 => x"00078513",
         89 => x"eadff0ef",
         90 => x"f00007b7",
         91 => x"1cc78513",
         92 => x"efdff0ef",
         93 => x"100007b7",
         94 => x"02478513",
         95 => x"ef1ff0ef",
         96 => x"100007b7",
         97 => x"02478513",
         98 => x"f4dff0ef",
         99 => x"00050793",
         100 => x"03078793",
         101 => x"00078513",
         102 => x"e79ff0ef",
         103 => x"100007b7",
         104 => x"01078513",
         105 => x"ec9ff0ef",
         106 => x"f99ff06f",
         107 => x"74737953",
         108 => x"72206d65",
         109 => x"61747365",
         110 => x"0a0d7472",
         111 => x"00000000",
         112 => x"69727453",
         113 => x"6920676e",
         114 => x"00002073",
         115 => x"61686320",
         116 => x"74636172",
         117 => x"20737265",
         118 => x"676e6f6c",
         119 => x"00000a0d",
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
