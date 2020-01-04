--###############################################################################
--# branch_test.vhd  - THe branch test unit
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

entity branch_test is
  port ( branch_test_mode   : in  STD_LOGIC_VECTOR(2 downto 0);
         branch_test_enable : in  STD_LOGIC;
         minimize_size      : in  STD_LOGIC;
         a                  : in  STD_LOGIC_VECTOR(31 downto 0);
         b                  : in  STD_LOGIC_VECTOR(31 downto 0);       
         take_branch        : out STD_LOGIC); 
end entity;


architecture Behavioral of branch_test is

   constant BRANCH_TEST_EQ                     : STD_LOGIC_VECTOR(2 downto 0) := "000";
   constant BRANCH_TEST_NE                     : STD_LOGIC_VECTOR(2 downto 0) := "001";
   constant BRANCH_TEST_TRUE                   : STD_LOGIC_VECTOR(2 downto 0) := "010";
   constant BRANCH_TEST_FALSE                  : STD_LOGIC_VECTOR(2 downto 0) := "011";
   constant BRANCH_TEST_LT                     : STD_LOGIC_VECTOR(2 downto 0) := "100";
   constant BRANCH_TEST_GE                     : STD_LOGIC_VECTOR(2 downto 0) := "101";
   constant BRANCH_TEST_LTU                    : STD_LOGIC_VECTOR(2 downto 0) := "110";
   constant BRANCH_TEST_GEU                    : STD_LOGIC_VECTOR(2 downto 0) := "111";

   signal test_is_true : std_logic;

begin
    take_branch <= test_is_true and branch_test_enable;

process(branch_test_mode, a, b, minimize_size)
    variable a_dash : std_logic_vector(31 downto 0);
    variable b_dash : std_logic_vector(31 downto 0);
    begin
        if minimize_size = '0' then
            --- This branch uses 44
            case branch_test_mode(2 downto 1) is

                when "00" =>   -- EQ and NE
                    if a = b then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when "01" =>  -- TRUE and FALSE
                    test_is_true <= NOT branch_test_mode(0);

                when "10" =>  -- SIGNED LT and GE
                    if SIGNED(a) < SIGNED(b) then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when "11" => -- unsigned LT and GE
                    if UNSIGNED(a) < UNSIGNED(b) then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when others =>
                    test_is_true <= NOT branch_test_mode(0);
            end case;
        else
            -- this branch uses 29 LUTs
            a_dash := a;
            b_dash := b;
            -- Map signed values to unsigned values for compraison
            if branch_test_mode = BRANCH_TEST_GE or branch_test_mode = BRANCH_TEST_LT then
               a_dash(a_dash'high) := NOT a_dash(a_dash'high);
               b_dash(b_dash'high) := NOT b_dash(b_dash'high);
            end if;

            case branch_test_mode(2 downto 1) is

                when "00" =>   -- EQ and NE
                    if a_dash = b_dash then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when "01" =>  -- TRUE and FALSE
                    test_is_true <= NOT branch_test_mode(0);

                when "10" =>  -- SIGNED LT and GE (with range moved)
                    if UNSIGNED(a_dash) < UNSIGNED(b_dash) then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when "11" => -- unsigned LT and GE
                    if UNSIGNED(a_dash) < UNSIGNED(b_dash) then
                        test_is_true <= NOT branch_test_mode(0);
                    else
                        test_is_true <= branch_test_mode(0);
                    end if;

                when others =>
                    test_is_true <= NOT branch_test_mode(0);
            end case;
        end if;
    end process;

end Behavioral;
