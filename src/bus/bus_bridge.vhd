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
  port ( clk           : in  STD_LOGIC;
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
   signal active     : std_logic_vector( 2 downto 0);
   signal write_mask : STD_LOGIC_VECTOR( 3 downto 0);
   signal write_data : STD_LOGIC_VECTOR(31 downto 0);
   signal read_data  : STD_LOGIC_VECTOR(31 downto 0);
begin

   m0_bus_enable     <= active(0);
   m0_bus_addr       <= cpu_bus_addr(31 downto 2);
   m0_bus_write_data <= write_data;
   m0_bus_write_mask <= write_mask;

   m1_bus_enable     <= active(1);
   m1_bus_addr       <= cpu_bus_addr(31 downto 2);
   m1_bus_write_data <= write_data;
   m1_bus_write_mask <= write_mask;

   m2_bus_enable     <= active(2);
   m2_bus_addr       <= cpu_bus_addr(31 downto 2);
   m2_bus_write_data <= write_data;
   m2_bus_write_mask <= write_mask;

   cpu_bus_busy <= (m0_bus_busy and active(0))
                or (m1_bus_busy and active(1))
                or (m2_bus_busy and active(2));


process(cpu_bus_dout, cpu_bus_addr)
   begin
      case cpu_bus_addr(1 downto 0) is
         when "00"   => write_data <= cpu_bus_dout(31 downto 0);
         when "01"   => write_data <= cpu_bus_dout(23 downto 0) & x"00";
         when "10"   => write_data <= cpu_bus_dout(15 downto 0) & x"0000";
         when others => write_data <= cpu_bus_dout( 7 downto 0) & x"000000";
      end case;
   end process;

process(cpu_bus_write, cpu_bus_width, cpu_bus_addr)
   begin
      write_mask <= "0000";
      if cpu_bus_write = '1' then
         case cpU_bus_width & cpu_bus_addr(1 downto 0) is
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

process(cpu_bus_addr,   cpu_bus_enable,
        m0_window_base, m0_window_mask,
        m1_window_base, m1_window_mask,
        m2_window_base, m2_window_mask)
   begin
      active <= (others => '0');
      if cpu_bus_enable = '1' then
         if (cpu_bus_addr and m0_window_mask) = m0_window_base then
            active(0) <= '1';
         end if;

         if (cpu_bus_addr and m1_window_mask) = m1_window_base then
            active(1) <= '1';
         end if;

         if (cpu_bus_addr and m2_window_mask) = m2_window_base then
            active(2) <= '1';
         end if;
      end if;
   end process;

process(read_data, cpu_bus_addr)
   begin
      case cpu_bus_addr(1 downto 0) is
         when "00"   => cpu_bus_din <= read_data(31 downto 0);
         when "01"   => cpu_bus_din <= x"00" & read_data(31 downto 8);
         when "10"   => cpu_bus_din <= x"0000" & read_data(31 downto 16);
         when "11"   => cpu_bus_din <= x"000000" & read_data(31 downto 24);
         when others => cpu_bus_din <= read_data(31 downto 0);
      end case;
   end process;

process(active, m0_bus_read_data, m1_bus_read_data, m2_bus_read_data)
   begin
      case active is
         when "001"  => read_data <= m0_bus_read_data;
         when "010"  => read_data <= m1_bus_read_data;
         when "100"  => read_data <= m2_bus_read_data;
         when others => read_data <= m2_bus_read_data; -- Multiple active (most likely an error!)
      end case;
   end process;

end Behavioral;
