--###############################################################################
--# tb_riscv.vhd  - Testbench the basic RV32I instrucions function.
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

entity tb_riscv is
end tb_riscv;

architecture Behavioral of tb_riscv is

    constant bus_bridge_use_clk   : std_logic := '0'; 
    constant bus_expander_use_clk : std_logic := '0'; 

    component top_level_expanded is
    generic ( clock_freq           : natural   := 50000000;
              bus_bridge_use_clk   : std_logic := '1';
              bus_expander_use_clk : std_logic := '1';
              cpu_minimize_size    : std_logic := '1');
    port ( clk              : in  STD_LOGIC;
           uart_rxd_out     : out STD_LOGIC := '1';
           uart_txd_in      : in  STD_LOGIC;
           gpio             : inout std_logic_vector(15 downto 0);
           debug_sel        : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data       : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    signal clk             : std_logic := '0';
    signal uart_rxd_out    : STD_LOGIC;
    signal uart_txd_in     : STD_LOGIC;
    signal debug_sel       : STD_LOGIC_VECTOR( 4 downto 0) := "00001";
    signal debug_data      : STD_LOGIC_VECTOR(31 downto 0); 
    signal cache_last_addr : std_logic := '0';
    signal gpio            : STD_LOGIC_VECTOR(15 downto 0); 

    constant period     : time := 10 ns;
    signal   wr_period : time := 10 ns;
    signal   rd_period : time := 10 ns;
begin

process
   begin
       wait for period/2;
       clk <= '0';
       wait for period/2;
       clk <= '1';
   end process;
   
process
   begin
     if 1 = 1 then 
       if bus_bridge_use_clk = '1' then
           rd_period <= period * 3;
           wr_period <= period * 2;
       else
           rd_period <= period * 2;
           wr_period <= period * 1;
       end if;

       wait for 5*period; -- to come out of reset
       debug_sel  <= "00001";
       wait for 0.5 ns;

       report "0: XOR r01 r01 => r01";
       assert debug_data = x"00000000" report "register r01 not 0x0" severity FAILURE;

       debug_sel  <= "00010";
       wait for  period;
       report "1: XOR r02 r02 => r02";
       assert debug_data = x"00000000" report "register r02 not 0x0" severity FAILURE;
       
       debug_sel  <= "00001";
       wait for  period;
       report "2: ADDI r01 1 => r01";
       assert debug_data = x"00000001" report "register r01 not 0x1" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "3: ADD r01 r01 => r02";
       assert debug_data = x"00000002" report "FAIL: register r02 not 0x2" severity FAILURE;
      
       debug_sel   <= "00010";
       wait for  period;
       report "4: ADD r01 r02 => r02";
       assert debug_data = x"00000003" report "FAIL: register r02 not 0x3" severity FAILURE;
      
       debug_sel   <= "00010";
       wait for  period;
       report "5: ADDI r02 r01 => r02";
       assert debug_data = x"00000004" report "FAIL: register r02 not 0x4" severity FAILURE;
      
       debug_sel   <= "00010";
       wait for  period;
       report "6: LUI FFFFF000 => r02";
       assert debug_data = x"FFFFF000" report "FAIL: register r02 not 0xFFFFF000" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "7: SRAI r02, 2 => r02";
       assert debug_data = x"FFFFFC00" report "FAIL: register r02 not 0xFFFFFC00" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "8: SRLI r02, 4 => r02";
       assert debug_data = x"0FFFFFC0" report "FAIL: register r02 not 0x0FFFFFC0" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report " 9: SLLI r02, 2 => r02";
       assert debug_data = x"3FFFFF00" report "FAIL: register r02 not 0x3FFFFF00" severity FAILURE;

-- MEMORY ACCESS INSTRUCTIONS
      
       debug_sel   <= "00010";
       wait for  period;
       report "10: AUPCI 0x12345000 => r02";
       assert debug_data = x"02345028" report "FAIL: register r02 not 0x02345028" severity FAILURE;

       debug_sel   <= "00111";
       wait for  period;
       report "11: LUI   0x10000000 => r07";
       assert debug_data = x"10000000" report "FAIL: register r02 not 0x10000000" severity FAILURE;

       debug_sel   <= "00010";
       wait for  wr_period;
       report "12: SB r02, 0 - not checked yet";

       debug_sel   <= "00010";
       wait for  wr_period;
       report "13: SB r02, 1 - not checked yet";

       debug_sel   <= "00010";
       wait for  wr_period;
       report "14: SB r02, 2 - not checked yet";

       debug_sel   <= "00010";
       wait for  wr_period;
       report "15: SB r02, 3 - not checked yet";
     
       debug_sel   <= "00011";
       wait for  rd_period;
       report "16: LW 0, r03";
       assert debug_data = x"28282828" report "FAIL: register r03 not 0x28282828" severity FAILURE;

       debug_sel   <= "00010";
       wait for  wr_period;
       report "17: SH r02, 0 - not checked yet";

       debug_sel   <= "00010";
       wait for  wr_period;
       report "18: SH r02, 2 - not checked yet";

       debug_sel   <= "00011";
       wait for  rd_period;
       report "19: LW 0, r03";
       assert debug_data = x"50285028" report "FAIL: register r03 not 0x50285028" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "20: LUI 0x89ABD000 => r02";
       assert debug_data = x"89ABD000" report "FAIL: register r02 not 0x89ABD000" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "21: ADDI r02, 0xFFFFFDEF => r02";
       assert debug_data = x"89ABCDEF" report "FAIL: register r02 not 0x89ABCDEF" severity FAILURE;

       debug_sel   <= "00010";
       wait for  wr_period;
       report "22: SW r02, 0 - not checked yet";

       debug_sel   <= "00011";
       wait for  rd_period;
       report "23: LW 0, r03";
       assert debug_data = x"89ABCDEF" report "FAIL: register r03 not 0x89ABCDEF" severity FAILURE;

-- SIGNED lOADS
       debug_sel   <= "00010";
       wait for  rd_period;
       report "24: LH 0, r02";
       assert debug_data = x"FFFFCDEF" report "FAIL: register r02 not 0xFFFFCDEF" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "25: LH 2, r02";
       assert debug_data = x"FFFF89AB" report "FAIL: register r02 not 0xFFFF89AB" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "26: LB 0, r02";
       assert debug_data = x"FFFFFFEF" report "FAIL: register r02 not 0xFFFFFFEF" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "27: LB 1, r02";
       assert debug_data = x"FFFFFFCD" report "FAIL: register r02 not 0xFFFFFFCD" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "28: LB 2, r02";
       assert debug_data = x"FFFFFFAB" report "FAIL: register r02 not 0xFFFFFFAB" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "29: LB 3, r02";
       assert debug_data = x"FFFFFF89" report "FAIL: register r02 not 0xFFFFFF89" severity FAILURE;

-- UNSIGNED lOADS
       debug_sel   <= "00010";
       wait for  rd_period;
       report "30: LHU 0, r02";
       assert debug_data = x"0000CDEF" report "FAIL: register r02 not 0x0000CDEF" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "31: LHU 2, r02";
       assert debug_data = x"000089AB" report "FAIL: register r02 not 0x000089AB" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "32: LBU 0, r02";
       assert debug_data = x"000000EF" report "FAIL: register r02 not 0x000000EF" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "33: LBU 1, r02";
       assert debug_data = x"000000CD" report "FAIL: register r02 not 0x000000CD" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "34: LBU 2, r02";
       assert debug_data = x"000000AB" report "FAIL: register r02 not 0x000000AB" severity FAILURE;

       debug_sel   <= "00010";
       wait for  rd_period;
       report "35: LBU 3, r02";
       assert debug_data = x"00000089" report "FAIL: register r02 not 0x00000089" severity FAILURE;
---- ALU OPERATIONS 
       debug_sel   <= "00010";
       wait for  period;
       report "36: LUI r02, 0x66666000";
       assert debug_data = x"66666000" report "FAIL: register r02 not 0x66666000" severity FAILURE;

       debug_sel   <= "00010";
       wait for  period;
       report "37: ADDI r02, 0x666, r02";
       assert debug_data = x"66666666" report "FAIL: register r02 not 0x66666666" severity FAILURE;

       debug_sel   <= "00011";
       wait for  period;
       report "38: LUI r03, 0xCCCCD000";
       assert debug_data = x"CCCCD000" report "FAIL: register r03 not 0xCCCCD000" severity FAILURE;

       debug_sel   <= "00011";
       wait for  period;
       report "39: ADDI r03, 0xCCC, r02";
       assert debug_data = x"CCCCCCCC" report "FAIL: register r03 not 0xCCCCCCCC" severity FAILURE;

       -- r02 set to 66666666, r03 set to CCCCCCCCC
       debug_sel   <= "00100";
       wait for  period;
       report "40: ADD  r02, r03, r04";
       assert debug_data = x"33333332" report "FAIL: register r04 not 0x33333332" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "41: ADD  r03, r02, r04";
       assert debug_data = x"33333332" report "FAIL: register r04 not 0x33333332" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "42: SUB  r02, r03, r04";
       assert debug_data = x"9999999A" report "FAIL: register r04 not 0x9999999A" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "43: SUB  r03, r02, r04";
       assert debug_data = x"66666666" report "FAIL: register r04 not 0x66666666" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "44: SLL  r02, r03, r04";
       assert debug_data = x"66666000" report "FAIL: register r04 not 0x66666000" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "45: SLL  r03, r02, r04";
       assert debug_data = x"33333300" report "FAIL: register r04 not 0x33333300" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "46: SLT  r02, r03, r04";
       assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "47: SLT  r03, r02, r04";
       assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "48: SLTU r02, r03, r04";
       assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "49: SLTU r03, r02, r04";
       assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "50: XOR  r02, r03, r04";
       assert debug_data = x"AAAAAAAA" report "FAIL: register r04 not 0xAAAAAAAA" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "51: XOR  r03, r02, r04";
       assert debug_data = x"AAAAAAAA" report "FAIL: register r04 not 0xAAAAAAAA" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "52: SRL  r02, r03, r04";
       assert debug_data = x"00066666" report "FAIL: register r04 not 0x00066666" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "53: SRL  r03, r02, r04";
       assert debug_data = x"03333333" report "FAIL: register r04 not 0x03333333" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "54: SRA  r02, r03, r04";
       assert debug_data = x"00066666" report "FAIL: register r04 not 0x00066666" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "55: SRA  r03, r02, r04";
       assert debug_data = x"FF333333" report "FAIL: register r04 not 0xFF333333" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "56: OR   r02, r03, r04";
       assert debug_data = x"EEEEEEEE" report "FAIL: register r04 not 0xEEEEEEEE" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "57: OR   r03, r02, r04";
       assert debug_data = x"EEEEEEEE" report "FAIL: register r04 not 0xEEEEEEEE" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "58: AND  r02, r03, r04";
       assert debug_data = x"44444444" report "FAIL: register r04 not 0x44444444" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "59: AND  r03, r02, r04";
       assert debug_data = x"44444444" report "FAIL: register r04 not 0x44444444" severity FAILURE;

---- Immediate ALU ops

       debug_sel   <= "00100";
       wait for  period;
       report "60: ADDI  r03, 0x666, r04";
       assert debug_data = x"CCCCD332" report "FAIL: register r04 not 0xCCCCD332" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "61: SLTI  r03, 0x666, r04";
       assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "62: SLTUI r03, 0x666, r04";
       assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "63: XORI  r03, 0x666, r04";
       assert debug_data = x"CCCCCAAA" report "FAIL: register r04 not 0xCCCCCAAA" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "64: ORI   r03, 0x666, r04";
       assert debug_data = x"CCCCCEEE" report "FAIL: register r04 not 0xCCCCCEEE" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "65: ANDI  r03, 0x666, r04";
       assert debug_data = x"00000444" report "FAIL: register r04 not 0x00000444" severity FAILURE;


       debug_sel   <= "00100";
       wait for  period;
       report "66: SLLI  r03, 0x6, r04";
       assert debug_data = x"33333300" report "FAIL: register r04 not 0x33333300" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "67: SRLI  r03, 0x6, r04";
       assert debug_data = x"03333333" report "FAIL: register r04 not 0x03333333" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "68: SRAI  r03, 0x6, r04";
       assert debug_data = x"FF333333" report "FAIL: register r04 not 0xFF333333" severity FAILURE;


       debug_sel   <= "00011";
       wait for  period;
       report "69: ADDI  r03 <= r00 + 0x000";
       assert debug_data = x"00000000" report "FAIL: register r03 not 0x00000000" severity FAILURE;

       debug_sel   <= "00100";
       wait for  period;
       report "70: JAL   +8, r04";
       assert debug_data = x"F000011C" report "FAIL: register r04 not 0xF000011C" severity FAILURE;

       report "71: ORI   r03 <= r03 | 0x001 is skipped";

       debug_sel   <= "00011";
       wait for  period;
       report "72: ORI   r03 <= r03 | 0x002";
       assert debug_data = x"00000002" report "FAIL: register r03 not 0x00000002" severity FAILURE;

       debug_sel   <= "00011";
       wait for  period;
       report "73: ORI   r03 <= r03 | 0x004";
       assert debug_data = x"00000006" report "FAIL: register r03 not 0x00000006" severity FAILURE;

       -----------------------------------------------------------------
       ------ Testing conditional branches with r03 = 8 and r04 = 8
       -----------------------------------------------------------------
       -- XOR  r02 <= r02 ^ r02
       debug_sel   <= "00010";
       wait for  period;
       report "74: XOR   r02 <= r02 ^ r02";
       assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;

       -- ADDI r03 <= r02 + 0x008
       debug_sel   <= "00011";
       wait for  period;
       report "75: ADDI   r03 <= r02 + 0x8";
       assert debug_data = x"00000008" report "FAIL: register r03 not 0x00000008" severity FAILURE;

       -- ADDI r04 <= r02 + 0x008
       debug_sel   <= "00100";
       wait for  period;
       report "76: ADDI   r04 <= r02 + 0x8";
       assert debug_data = x"00000008" report "FAIL: register r04 not 0x00000008" severity FAILURE;

       -- BEQ  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "77: BEQ r03,r04,+8";
       assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;

       -- ORI  r02 <= r02 | 0x001
       report "78: ORI r02 <= r02 | 0x1  -  should be skipped";

       -- BNE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "79: BNE r03,r04,+8";
       assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;

       -- ORI  r02 <= r02 | 0x002
       debug_sel   <= "00010";
       wait for  period;
       report "80: ORI r02 <= r02 | 0x2";
       assert debug_data = x"00000002" report "FAIL: register r02 not 0x00000002" severity FAILURE;

       -- BLT  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "81: BLT r03,r04,+8";

       -- ORI  r02 <= r02 | 0x004
       debug_sel   <= "00010";
       wait for  period;
       report "82: ORI r02 <= r02 | 0x4";
       assert debug_data = x"00000006" report "FAIL: register r02 not 0x00000006" severity FAILURE;

       -- BGE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "83: BGE r03,r04,+8";

       -- ORI  r02 <= r02 | 0x008
       report "84: ORI r02 <= r02 | 0x8  -  should be skipped";

       -- BLTU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "85: BLTU r03,r04,+8";

       -- ORI  r02 <= r02 | 0x010
       debug_sel   <= "00010";
       wait for  period;
       report "86: ORI r02 <= r02 | 0x10";
       assert debug_data = x"00000016" report "FAIL: register r02 not 0x00000016" severity FAILURE;

       -- BGEU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "87: BGEU r03,r04,+8";

       -- ORI  r02 <= r02 | 0x020
       report "88: ORI r02 <= r02 | 0x20  -  should be skipped";

       -----------------------------------------------------------------
       ------ Testing conditional branches with r03 = 8 and r04 = 16
       -----------------------------------------------------------------
       -- XOR  r02 <= r02 ^ r02
       debug_sel   <= "00010";
       wait for  period;
       report "89: XOR   r02 <= r02 ^ r02";
       assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;

       -- ADDI r04 <= r03 + 0x008
       debug_sel   <= "00100";
       wait for  period;
       report "90: ADDI   r04 <= r03 + 0x8";
       assert debug_data = x"00000010" report "FAIL: register r04 not 0x00000010" severity FAILURE;

       -- BEQ  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "91: BEQ  r03, r04,+8";

       -- ORI  r02 <= r02 | 0x001
       debug_sel   <= "00010";
       wait for  period;
       report "92: ORI r02 <= r02 | 0x01";
       assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;

       -- BNE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "93: BNE  r03, r04,+8";
       assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;

       -- ORI  r02 <= r02 | 0x002
       report "94: ORI r02 <= r02 | 0x2  -  should be skipped";

       -- BLT  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "95: BLT  r03, r04,+8";
       assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;

       -- ORI  r02 <= r02 | 0x004
       report "96: ORI r02 <= r02 | 0x4  -  should be skipped";

       -- BGE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "97: BGE  r03, r04,+8";
       assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;

       -- ORI  r02 <= r02 | 0x008
       debug_sel   <= "00010";
       wait for  period;
       report "98: ORI r02 <= r02 | 0x08";
       assert debug_data = x"00000009" report "FAIL: register r02 not 0x00000009" severity FAILURE;

       -- BLTU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "99: BLTU r03, r04,+8";

       -- ORI  r02 <= r02 | 0x010
       report "100: ORI r02 <= r02 | 0x10  -  should be skipped";

       -- BGEU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "101: BGEU r03, r04,+8";

       -- ORI  r02 <= r02 | 0x020
       debug_sel   <= "00010";
       wait for  period;
       report "102: ORI r02 <= r02 | 0x08";
       assert debug_data = x"00000029" report "FAIL: register r02 not 0x00000029" severity FAILURE;

       -----------------------------------------------------------------
       ------ Testing conditional branches with r03 = 8 and r04 = -16
       -----------------------------------------------------------------
       -- XOR  r02 <= r02 ^ r02
       debug_sel   <= "00010";
       wait for  period;
       report "103: XOR   r02 <= r02 ^ r02";
       assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;

       -- ADDI r04 <= r02 + 0xFFFFFFE0  (-32)
       debug_sel   <= "00100";
       wait for  period;
       report "104: ADDI   r04 <= r02 + 0xFE0";
       assert debug_data = x"FFFFFFE0" report "FAIL: register r04 not 0xFFFFFFE0" severity FAILURE;

       -- BEQ  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "105: BEQ  r03, r04,+8";

       -- ORI  r02 <= r02 | 0x001
       debug_sel   <= "00010";
       wait for  period;
       report "106: ORI r02 <= r02 | 0x01";
       assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;

       -- BNE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "107: BNE  r03, r04,+8";

       -- ORI  r02 <= r02 | 0x002
       report "108: ORI r02 <= r02 | 0x02  -  should be skipped";

       -- BLT  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "109: BLT  r03, r04,+8";

       -- ORI  r02 <= r02 | 0x004
       debug_sel   <= "00010";
       wait for  period;
       report "110: ORI r02 <= r02 | 0x04";
       assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;

       -- BGE  r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "111: BGE  r03, r04,+8";
       assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;

       -- ORI  r02 <= r02 | 0x008
       report "112: ORI r02 <= r02 | 0x08  -  should be skipped";

       -- BLTU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "113: BLTU r03, r04,+8";
       assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;

       -- ORI  r02 <= r02 | 0x010
       report "114: ORI r02 <= r02 | 0x10  -  should be skipped";

       -- BGEU r03, r04, +8
       debug_sel   <= "00010";
       wait for  period;
       report "115: BGEU r03, r04,+8";
       assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;

       -- ORI  r02 <= r02 | 0x020
       debug_sel   <= "00010";
       wait for  period;
       report "116: ORI r02 <= r02 | 0x20";
       assert debug_data = x"00000025" report "FAIL: register r02 not 0x00000025" severity FAILURE;

       report "All tests complete";
       end if;
       wait;
       
   end process;

i_top_level_expanded: top_level_expanded generic map (
        clock_freq           => 50000000,
        bus_bridge_use_clk   => bus_bridge_use_clk,
        bus_expander_use_clk => bus_expander_use_clk,
        cpu_minimize_size    => '1' 
    ) port map(
         clk          => clk,

         uart_rxd_out => uart_rxd_out,
         uart_txd_in  => uart_txd_in,
         
         gpio         => gpio,

         debug_sel    => debug_sel,
         debug_data   => debug_data); 
end Behavioral;

