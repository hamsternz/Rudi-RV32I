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

entity bus_expander is
   generic ( use_clk           : in  STD_LOGIC);
   port    ( clk               : in  STD_LOGIC;
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
   signal active             : std_logic_vector( 2 downto 0) := (others => '0');

   signal addr               : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal write_data         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal write_mask         : STD_LOGIC_VECTOR( 3 downto 0) := (others => '0');
   signal latched_addr       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal latched_write_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal latched_write_mask : STD_LOGIC_VECTOR( 3 downto 0) := (others => '0');
   signal idle               : STD_LOGIC := '0';
   signal busy               : STD_LOGIC := '0';
begin

   m0_bus_enable     <= active(0);
   m0_bus_addr       <= addr(31 downto 2) AND NOT m0_window_mask(31 downto 2);
   m0_bus_write_data <= write_data;
   m0_bus_write_mask <= write_mask;

   m1_bus_enable     <= active(1);
   m1_bus_addr       <= addr(31 downto 2) AND NOT m1_window_mask(31 downto 2);
   m1_bus_write_data <= write_data;
   m1_bus_write_mask <= write_mask;

   m2_bus_enable     <= active(2);
   m2_bus_addr       <= addr(31 downto 2) AND NOT m2_window_mask(31 downto 2);
   m2_bus_write_data <= write_data;
   m2_bus_write_mask <= write_mask;

   s0_bus_busy       <= busy;

   busy <= (s0_bus_enable and idle and use_clk)
        or (m0_bus_busy and active(0))
        or (m2_bus_busy and active(2))
        or (m1_bus_busy and active(1));

   with use_clk select addr       <= latched_addr       when '1', s0_bus_addr & "00" when others;
   with use_clk select write_data <= latched_write_data when '1', s0_bus_write_data  when others;
   with use_clk select write_mask <= latched_write_mask when '1', s0_bus_write_mask  when others;

process(idle, addr, s0_bus_enable,
        m0_window_mask, m0_window_base,
        m1_window_mask, m1_window_base,
        m2_window_mask, m2_window_base)
   begin
      -- work out which port is busy (if any)
      active <= (others => '0');
      if use_clk = '1' then
         if idle = '0' then
            if (addr(31 downto 2) and m0_window_mask(31 downto 2)) = m0_window_base(31 downto 2) then
               active(0) <= '1';
            end if;
            if (addr(31 downto 2) and m1_window_mask(31 downto 2)) = m1_window_base(31 downto 2) then
               active(1) <= '1';
            end if;
            if (addr(31 downto 2) and m2_window_mask(31 downto 2)) = m2_window_base(31 downto 2) then
               active(2) <= '1';
            end if;
         end if;
      else
         if s0_bus_enable = '1' then
            if (addr(31 downto 2) and m0_window_mask(31 downto 2)) = m0_window_base(31 downto 2) then
               active(0) <= '1';
            end if;
            if (addr(31 downto 2) and m1_window_mask(31 downto 2)) = m1_window_base(31 downto 2) then
               active(1) <= '1';
            end if;
            if (addr(31 downto 2) and m2_window_mask(31 downto 2)) = m2_window_base(31 downto 2) then
               active(2) <= '1';
            end if;
         end if;
      end if;
   end process;

process(clk)
   begin
      if rising_edge(clk) then
         idle <= '1';
         if s0_bus_enable = '1' then
            -- Take note of if the bus is currently busy
            -- Hold the address and write info in local registers.
            -- This is needed to give an endpoint for static timing analysis
            -- even if we don't expect these to change during the transaction.
            idle               <= not busy;
            latched_addr       <= s0_bus_addr & "00";
            latched_write_data <= s0_bus_write_data;
            latched_write_mask <= s0_bus_write_mask;
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
