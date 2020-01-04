--###############################################################################
--# sign_extender.vhd - Masks and extends the sign on values form memory
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

entity sign_extender is
  port ( sign_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0);
         sign_ex_width : in  STD_LOGIC_VECTOR(1 downto 0);
         a             : in  STD_LOGIC_VECTOR(31 downto 0);
         b             : out STD_LOGIC_VECTOR(31 downto 0));
end entity;

architecture Behavioral of sign_extender is
   -- Must agree with decode.vhd
   constant SIGN_EX_WIDTH_B            : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant SIGN_EX_WIDTH_H            : STD_LOGIC_VECTOR(1 downto 0) := "01";
   constant SIGN_EX_WIDTH_W            : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant SIGN_EX_WIDTH_X            : STD_LOGIC_VECTOR(1 downto 0) := "11";
   constant SIGN_EX_SIGNED             : STD_LOGIC_VECTOR(0 downto 0) := "0";
   constant SIGN_EX_UNSIGNED           : STD_LOGIC_VECTOR(0 downto 0) := "1";
   signal padding : STD_LOGIC_VECTOR(31 downto 8);
begin

process(sign_ex_mode, sign_ex_width, a)
    begin
        padding <= (others => '0');
        if sign_ex_mode = SIGN_EX_SIGNED then
            case sign_ex_width is
                when SIGN_EX_WIDTH_B =>
                  if a(7) = '1' then
                     padding <= (others => '1');
                  end if;
                when others =>
                  if a(15) = '1' then
                     padding <= (others => '1');
                  end if;              
            end case;
        end if;
    end process;

process(a, sign_ex_width, padding)
    begin
        case sign_ex_width is
            when SIGN_EX_WIDTH_B =>
                b <= padding(31 downto  8) & a( 7 downto 0);
            when SIGN_EX_WIDTH_H =>
                b <= padding(31 downto 16) & a(15 downto 0);
            when SIGN_EX_WIDTH_W =>
                b <= a;
            when others =>
                b <= a;
        end case;
    end process;
end Behavioral;
