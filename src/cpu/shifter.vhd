--###############################################################################
--# shifter.vhd  - The barrel shifter
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

entity shifter is
  port ( shift_mode      : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
         minimize_size   : in  STD_LOGIC;
         a               : in  STD_LOGIC_VECTOR(31 downto 0);
         b               : in  STD_LOGIC_VECTOR(31 downto 0);
         c               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
end entity;

architecture Behavioral of shifter is
   -- Must agree with decode.vhd
   constant SHIFTER_LEFT_LOGICAL        : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant SHIFTER_LEFT_ARITH          : STD_LOGIC_VECTOR(1 downto 0) := "01";  -- not used
   constant SHIFTER_RIGHT_LOGICAL       : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant SHIFTER_RIGHT_ARITH         : STD_LOGIC_VECTOR(1 downto 0) := "11";
   
   signal padding : std_logic_vector(15 downto 0);
begin
    
process(shift_mode,a)
    begin
        -- Generate the padding for right shifts (either logical or arithmetic)
        if (shift_mode = SHIFTER_LEFT_ARITH OR shift_mode = SHIFTER_RIGHT_ARITH) AND a(a'high) = '1' then
            padding <= (others => '1');
        else
            padding <= (others => '0');
        end if; 
    end process;
    
process(shift_mode, a, b, padding, minimize_size)
    variable t : STD_LOGIC_VECTOR(31 downto 0);
    begin
        if minimize_size = '1' then
            -- Swap bit order if shifting to the right
            if shift_mode = SHIFTER_RIGHT_LOGICAL OR shift_mode = SHIFTER_RIGHT_ARITH then
               t := a;
            else
               t := a( 0) & a( 1) & a( 2) & a( 3) & a( 4) & a( 5) & a( 6) & a( 7)
                  & a( 8) & a( 9) & a(10) & a(11) & a(12) & a(13) & a(14) & a(15)
                  & a(16) & a(17) & a(18) & a(19) & a(20) & a(21) & a(22) & a(23)
                  & a(24) & a(25) & a(26) & a(27) & a(28) & a(29) & a(30) & a(31);
            end if;
            
            if b(4) = '1' then
                t := padding(15 downto 0) & t(31 downto 16);
            end if;
                
            if b(3) = '1' then
                t := padding(7 downto 0) & t(31 downto 8);
            end if;

            if b(2) = '1' then
                t := padding(3 downto 0) & t(31 downto 4);
            end if;

            if b(1) = '1' then
                t := padding(1 downto 0) & t(31 downto 2);
            end if;

            if b(0) = '1' then
                t := padding(0 downto 0) & t(31 downto 1);
            end if;           

            if shift_mode = SHIFTER_RIGHT_LOGICAL OR shift_mode = SHIFTER_RIGHT_ARITH then
               c <= t;
            else
               c <= t( 0) & t( 1) & t( 2) & t( 3) & t( 4) & t( 5) & t( 6) & t( 7)
                  & t( 8) & t( 9) & t(10) & t(11) & t(12) & t(13) & t(14) & t(15)
                  & t(16) & t(17) & t(18) & t(19) & t(20) & t(21) & t(22) & t(23)
                  & t(24) & t(25) & t(26) & t(27) & t(28) & t(29) & t(30) & t(31);
            end if;
        else
            t := a;
            if shift_mode = SHIFTER_LEFT_LOGICAL OR shift_mode = SHIFTER_LEFT_ARITH then
                if b(4) = '1' then
                    t := t(15 downto 0) & x"0000";
                end if;
                
                if b(3) = '1' then
                    t := t(23 downto 0) & x"00";
                end if;
    
                if b(2) = '1' then
                    t := t(27 downto 0) & x"0";
                end if;
    
                if b(1) = '1' then
                    t := t(29 downto 0) & "00";
                end if;
    
                if b(0) = '1' then
                    t := t(30 downto 0) & "0";
                end if;
           else
                if b(4) = '1' then
                    t := padding(15 downto 0) & t(31 downto 16);
                end if;
                
                if b(3) = '1' then
                    t := padding(7 downto 0) & t(31 downto 8);
                end if;
    
                if b(2) = '1' then
                    t := padding(3 downto 0) & t(31 downto 4);
                end if;
    
                if b(1) = '1' then
                    t := padding(1 downto 0) & t(31 downto 2);
                end if;
    
                if b(0) = '1' then
                    t := padding(0 downto 0) & t(31 downto 1);
                end if;           
            end if;
    
            c <= t;
        end if;
   end process;
end Behavioral;
