--###############################################################################
--# peripheral_gpio.vhd  - The serial port peripheral
--#
--# A GPIO peripheral
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

entity peripheral_gpio is
  port ( clk            : in  STD_LOGIC;

         bus_busy       : out STD_LOGIC;
         bus_addr       : in  STD_LOGIC_VECTOR(3 downto 2);
         bus_enable     : in  STD_LOGIC;
         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         gpio           : inout STD_LOGIC_VECTOR);

end entity;

architecture Behavioral of peripheral_gpio is
    signal data_valid   : STD_LOGIC := '1';

    signal direction       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal output_value    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal read_value      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

process(bus_enable, bus_write_mask, data_valid)
begin
    bus_busy <= '0';
    if bus_enable = '1' and bus_write_mask = "0000" then
        if data_valid = '0' then
           bus_busy <= '1';
        end if;
    end if;
end process;

process(gpio)
begin
   read_value                     <= (others => '0');
   read_value(gpio'high downto 0) <= gpio;
end process;

process(direction,output_value)
begin
   for i in 0 to gpio'high loop
      if direction(i) = '0' then
        gpio(i) <= 'Z';
      else
        gpio(i) <= output_value(i);    
      end if;
   end loop;
end process;

process(clk) 
begin
    if rising_edge(clk) then
        data_valid <= '0';
        bus_read_data <= x"00000000";
        if bus_enable = '1' then
            if bus_write_mask /= "0000" then
                case bus_addr is
                    when "00" =>  
                        if bus_write_mask(0) = '1' then
                            output_value <= bus_write_data;
                        end if;
                    when "01" =>  
                        if bus_write_mask(0) = '1' then
                            direction <= bus_write_data;
                        end if;
                    -- other registers are read only
                    when others =>
                end case;
            else
                if data_valid = '0' then
                   data_valid <= '1';
                end if;

                case bus_addr is
                    when "00"   => bus_read_data <= read_value;
                    when "01"   => bus_read_data <= direction;
                    when others => bus_read_data <= (others => '0');
                end case;
            end if;           
        end if;
    end if;
end process;

end Behavioral;
