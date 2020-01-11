--###############################################################################
--# bus_bridge.vhd  - A primative bridge from the CPU to peripheral bus.
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

entity bus_bridge is
  generic (use_clk         : in STD_LOGIC);
  port ( clk               : in  STD_LOGIC;
         cpu_bus_busy      : out STD_LOGIC;
         cpu_bus_addr      : in  STD_LOGIC_VECTOR(31 downto 0);
         cpu_bus_width     : in  STD_LOGIC_VECTOR( 1 downto 0);  
         cpu_bus_dout      : in  STD_LOGIC_VECTOR(31 downto 0);
         cpu_bus_write     : in  STD_LOGIC;
         cpu_bus_enable    : in  STD_LOGIC;
         cpu_bus_din       : out STD_LOGIC_VECTOR(31 downto 0);

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


architecture Behavioral of bus_bridge is
   signal active             : std_logic_vector( 2 downto 0);
   signal addr               : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal write              : std_logic;
   signal width              : std_logic_vector( 1 downto 0);
   signal write_data         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal latched_addr       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal latched_write      : std_logic;
   signal latched_width      : std_logic_vector( 1 downto 0);
   signal latched_write_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal write_mask         : STD_LOGIC_VECTOR( 3 downto 0);
   signal write_data_aligned : STD_LOGIC_VECTOR(31 downto 0);
   signal read_data          : STD_LOGIC_VECTOR(31 downto 0);

   signal idle : STD_LOGIC := '0';
   signal busy : STD_LOGIC := '0';
   
begin

   m0_bus_enable     <= active(0);
   m0_bus_addr       <= addr(31 downto 2) AND NOT m0_window_mask(31 downto 2);
   m0_bus_write_data <= write_data_aligned;
   m0_bus_write_mask <= write_mask;

   m1_bus_enable     <= active(1);
   m1_bus_addr       <= addr(31 downto 2) AND NOT m1_window_mask(31 downto 2);
   m1_bus_write_data <= write_data_aligned;
   m1_bus_write_mask <= write_mask;

   m2_bus_enable     <= active(2);
   m2_bus_addr       <= addr(31 downto 2) AND NOT m2_window_mask(31 downto 2);
   m2_bus_write_data <= write_data_aligned;
   m2_bus_write_mask <= write_mask;

   cpu_bus_busy <= busy;

   -- Tell the CPU interface when we are busy.
   busy <= (cpu_bus_enable and idle and use_clk)
         or (m0_bus_busy and active(0))
         or (m2_bus_busy and active(2))
         or (m1_bus_busy and active(1));

   with use_clk select addr        <= latched_addr       when '1', cpu_bus_addr  when others;
   with use_clk select write       <= latched_write      when '1', cpu_bus_write when others;
   with use_clk select write_data  <= latched_write_data when '1', cpu_bus_dout  when others;
   with use_clk select width       <= latched_width      when '1', cpu_bus_width when others;

process(write_data, addr)
   begin
      case addr(1 downto 0) is
         when "00"   => write_data_aligned <= write_data(31 downto 0);
         when "01"   => write_data_aligned <= write_data(23 downto 0) & x"00";
         when "10"   => write_data_aligned <= write_data(15 downto 0) & x"0000";
         when others => write_data_aligned <= write_data( 7 downto 0) & x"000000";
      end case;
   end process;

process(write, width, addr)
   begin
      write_mask <= "0000";
      if write = '1' then
         case width & addr(1 downto 0) is
            when "0000" => write_mask <= "0001";
            when "0001" => write_mask <= "0010";
            when "0010" => write_mask <= "0100";
            when "0011" => write_mask <= "1000";

            when "0100" => write_mask <= "0011";
            when "0101" => write_mask <= "0110";
            when "0110" => write_mask <= "1100";
            when "0111" => write_mask <= "1000";

            when "1000" => write_mask <= "1111";
            when "1001" => write_mask <= "1110";
            when "1010" => write_mask <= "1100";
            when "1011" => write_mask <= "1000";

            when others => write_mask <= "0000";
         end case;
      end if;
   end process;

process(idle, addr, cpu_bus_enable,
        m0_window_base, m0_window_mask,
        m1_window_base, m1_window_mask,
        m2_window_base, m2_window_mask)
   begin
      active <= (others => '0');
      if use_clk = '1' then
         if idle = '0' then      
            if (addr and m0_window_mask) = m0_window_base then
               active(0) <= '1';
            end if;

            if (addr and m1_window_mask) = m1_window_base then
               active(1) <= '1';
            end if;

            if (addr and m2_window_mask) = m2_window_base then
               active(2) <= '1';
            end if;
         end if;
      else
         if cpu_bus_enable = '1' then      
            if (addr and m0_window_mask) = m0_window_base then
               active(0) <= '1';
            end if;

            if (addr and m1_window_mask) = m1_window_base then
               active(1) <= '1';
            end if;

            if (addr and m2_window_mask) = m2_window_base then
               active(2) <= '1';
            end if;
         end if;
      end if;
   end process;

process(clk)
   begin
   if rising_edge(clk) then
      idle <= '1';
      if cpu_bus_enable = '1' then
      -- Take note of if the bus is currently busy
         idle <= not busy;
         -- Hold the address and write info in local registers.
         -- This is needed to give an endpoint for static timing analysis
         -- even if we don't expect these to change during the transaction.
         latched_addr       <= cpu_bus_addr;
         latched_write_data <= cpu_bus_dout;
         latched_width      <= cpu_bus_width;
         latched_write      <= cpu_bus_write;
      end if;
   end if;
end process;

------------------------------------
-- Work out which data is being read
------------------------------------
process(active, m0_bus_read_data, m1_bus_read_data, m2_bus_read_data)
   begin
      case active is
         when "001"  => read_data <= m0_bus_read_data;
         when "010"  => read_data <= m1_bus_read_data;
         when "100"  => read_data <= m2_bus_read_data;
         when others => read_data <= m2_bus_read_data; -- Multiple active (most likely an error!)
      end case;
   end process;

-------------------------------------------
-- Correct alignment and send it to the CPU
-------------------------------------------
process(read_data, addr)
   begin
      case addr(1 downto 0) is
         when "00"   => cpu_bus_din <= read_data(31 downto 0);
         when "01"   => cpu_bus_din <= x"00" & read_data(31 downto 8);
         when "10"   => cpu_bus_din <= x"0000" & read_data(31 downto 16);
         when "11"   => cpu_bus_din <= x"000000" & read_data(31 downto 24);
         when others => cpu_bus_din <= read_data(31 downto 0);
      end case;
   end process;

end Behavioral;
