--###############################################################################
--# peripheral_serial.vhd  - The serial port peripheral
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

entity peripheral_serial is

  generic ( clock_freq : natural;
            baud_rate  : natural);

  port ( clk            : in  STD_LOGIC;

         bus_busy       : out STD_LOGIC;
         bus_addr       : in  STD_LOGIC_VECTOR(3 downto 2);
         bus_enable     : in  STD_LOGIC;
         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         serial_rx      : in  STD_LOGIC;
         serial_tx      : out STD_LOGIC := '0');

end entity;

architecture Behavioral of peripheral_serial is
    signal data_valid   : STD_LOGIC := '1';

    signal fifo_wr      : STD_LOGIC := '0';
    signal fifo_wr_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal fifo_rd      : STD_LOGIC := '0';
    signal fifo_rd_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal fifo_full    : STD_LOGIC := '0';
    signal fifo_empty   : STD_LOGIC := '1';

    signal data_tx_sr   : STD_LOGIC_VECTOR(9 downto 0) := (others => '1');    
    signal busy_tx_sr   : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');    
    signal baud_tick    : STD_LOGIC := '0';
    signal baud_counter : UNSIGNED(29 downto 0) := (others => '0');  -- Good to about 1GHz

begin
   serial_tx <= data_tx_sr(0);
   fifo_full <= busy_tx_sr(0);

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
        -- Processing outbound serial data
        if busy_tx_sr(0) = '1' then
            if baud_tick = '1' then
                busy_tx_sr <= '0' & busy_tx_sr(busy_tx_sr'high downto 1);
                data_tx_sr <= '1' & data_tx_sr(data_tx_sr'high downto 1);
            end if;
        end if;

        if fifo_wr = '1' and busy_tx_sr(0) = '0' then
            data_tx_sr <= '1' & fifo_wr_data & '0';
            busy_tx_sr <= (others => '1');
        end if;

        -- Handle the bus request
        data_valid <= '0';
        bus_read_data <= x"00000000";
        fifo_wr    <= '0';
        fifo_rd    <= '0';
        if bus_enable = '1' then
            if bus_write_mask /= "0000" then
                case bus_addr is
                    -- write SERIAL_OUT register
                    when "00" =>  
                        if bus_write_mask(0) = '1' then
                            fifo_wr_data <= bus_write_data(7 downto 0); fifo_wr <= '1';
                        end if;
                    -- other registers are read only
                    when others =>
                end case;
            else
                if data_valid = '0' then
                   data_valid <= '1';
                end if;

                case bus_addr is
                    -- read SERIAL_OUT register (reads as zeros)
                    when "00" => bus_read_data <= x"00000000";
                    -- read SERIAL_OUT_STATUS register
                    when "01" => bus_read_data <= x"00000000"; bus_read_data(0)          <= fifo_full;
                    -- read SERIAL_IN register
                    when "10" => bus_read_data <= x"00000000"; bus_read_data(7 downto 0) <= fifo_rd_data; fifo_rd <= '1';
                    -- read SERIAL_IN_STATUS register
                    when "11" => bus_read_data <= x"00000000"; bus_read_data(0)          <= fifo_empty;
                    when others =>
                end case;
            end if;           
        end if;

        -- Work out where the next baud tick is
        if baud_counter < baud_rate then
           baud_counter <= baud_counter - baud_rate + clock_freq - 1;
           baud_tick    <= '1';
        else
           baud_counter <= baud_counter - baud_rate;
           baud_tick    <= '0';
        end if;
    end if;
end process;



end Behavioral;
