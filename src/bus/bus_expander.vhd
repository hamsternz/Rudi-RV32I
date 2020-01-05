--###############################################################################
--# bus_expander.vhd  - A primative bridge from the CPU to peripheral bus.
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

entity bus_expander is
  port ( clk           : in  STD_LOGIC;
         -- Upstream (slave) interfaces
         s0_bus_busy       : out STD_LOGIC;
         s0_bus_addr       : in  STD_LOGIC_VECTOR(31 downto 2);
         s0_bus_enable     : in  STD_LOGIC;
         s0_bus_write_mask : in  STD_LOGIC_VECTOR( 3 downto 0);
         s0_bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         s0_bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         -- Downstream (master) interfaces
         m0_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
         m0_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
         m0_bus_busy       : in  STD_LOGIC;
         m0_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
         m0_bus_enable     : out STD_LOGIC;
         m0_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
         m0_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
         m0_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         m1_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
         m1_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
         m1_bus_busy       : in  STD_LOGIC;
         m1_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
         m1_bus_enable     : out STD_LOGIC;
         m1_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
         m1_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
         m1_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         m2_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
         m2_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
         m2_bus_busy       : in  STD_LOGIC;
         m2_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
         m2_bus_enable     : out STD_LOGIC;
         m2_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
         m2_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
         m2_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
   );
end entity;


architecture Behavioral of bus_expander is
   signal active     : std_logic_vector( 2 downto 0);
begin

   m0_bus_enable     <= active(0);
   m0_bus_addr       <= s0_bus_addr(31 downto 2) AND NOT m0_window_mask(31 downto 2);
   m0_bus_write_data <= s0_bus_write_data;
   m0_bus_write_mask <= s0_bus_write_mask;


   m1_bus_enable     <= active(1);
   m1_bus_addr       <= s0_bus_addr(31 downto 2) AND NOT m1_window_mask(31 downto 2);
   m1_bus_write_data <= s0_bus_write_data;
   m1_bus_write_mask <= s0_bus_write_mask;

   m2_bus_enable     <= active(2);
   m2_bus_addr       <= s0_bus_addr(31 downto 2) AND NOT m2_window_mask(31 downto 2);
   m2_bus_write_data <= s0_bus_write_data;
   m2_bus_write_mask <= s0_bus_write_mask;


   s0_bus_busy <= (m0_bus_busy and active(0))
                or (m1_bus_busy and active(1))
                or (m2_bus_busy and active(2));


process(s0_bus_addr,    s0_bus_enable,
        m0_window_base, m0_window_mask,
        m1_window_base, m1_window_mask,
        m2_window_base, m2_window_mask)
   begin
      active <= (others => '0');
      if s0_bus_enable = '1' then
         if (s0_bus_addr and m0_window_mask(31 downto 2)) = m0_window_base(31 downto 2) then
            active(0) <= '1';
         end if;

         if (s0_bus_addr and m1_window_mask(31 downto 2)) = m1_window_base(31 downto 2) then
            active(1) <= '1';
         end if;

         if (s0_bus_addr and m2_window_mask(31 downto 2)) = m2_window_base(31 downto 2) then
            active(2) <= '1';
         end if;
      end if;
   end process;

process(active, m0_bus_read_data, m1_bus_read_data, m2_bus_read_data)
   begin
      case active is
         when "001"  => s0_bus_read_data <= m0_bus_read_data;
         when "010"  => s0_bus_read_data <= m1_bus_read_data;
         when "100"  => s0_bus_read_data <= m2_bus_read_data;
         when others => s0_bus_read_data <= m2_bus_read_data; -- Multiple active (most likely an error!)
      end case;
   end process;

end Behavioral;
