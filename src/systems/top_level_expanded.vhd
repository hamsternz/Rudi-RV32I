--###############################################################################
--# top_level.vhd - Top level design
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

entity top_level_expanded is
  generic ( clock_freq           : natural   := 50000000;
            bus_bridge_use_clk   : std_logic := '1';
            bus_expander_use_clk : std_logic := '1';
            cpu_minimize_size    : std_logic := '1');
  port ( clk          : in    STD_LOGIC;
         uart_rxd_out : out   STD_LOGIC := '1';
         uart_txd_in  : in    STD_LOGIC;
         debug_sel    : in    STD_LOGIC_VECTOR(4 downto 0);
         debug_data   : out   STD_LOGIC_VECTOR(31 downto 0);
         gpio         : inout STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture Behavioral of top_level_expanded is

    component riscv_cpu is
          port ( clk           : in  STD_LOGIC;
                 pc_next       : out STD_LOGIC_VECTOR(31 downto 0);
                 reset         : in  STD_LOGIC;
                 minimize_size : in  STD_LOGIC;

                 bus_busy      : in  STD_LOGIC;
                 bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
                 bus_width     : out STD_LOGIC_VECTOR(1 downto 0);
                 bus_write     : out STD_LOGIC;
                 bus_enable    : out STD_LOGIC;
                 bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
                 bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);

                 instr_reg     : in  STD_LOGIC_VECTOR(31 downto 0);
                 debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
                 debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
                 debug_data    : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal pc_next : STD_LOGIC_VECTOR(31 downto 0);
    signal instr_reg : STD_LOGIC_VECTOR(31 downto 0);

    component program_memory is
    port ( clk            : in  STD_LOGIC;

           pc_next        : in  STD_LOGIC_VECTOR(31 downto 0);
           instr_reg      : out STD_LOGIC_VECTOR(31 downto 0);

           bus_busy       : out STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
           bus_enable     : in  STD_LOGIC;
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));

    end component;

    component bus_bridge is
    generic ( use_clk           : in  STD_LOGIC);
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
           m0_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0);

           m1_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
           m1_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
           m1_bus_busy       : in  STD_LOGIC;
           m1_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
           m1_bus_enable     : out STD_LOGIC;
           m1_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
           m1_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           m1_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0);

           m2_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
           m2_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
           m2_bus_busy       : in  STD_LOGIC;
           m2_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
           m2_bus_enable     : out STD_LOGIC;
           m2_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
           m2_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           m2_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0));
    end component; 

    signal m0_bus_enable     : STD_LOGIC;
    signal m0_bus_busy       : STD_LOGIC;
    signal m0_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m0_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m0_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m0_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    signal m1_bus_busy       : STD_LOGIC;
    signal m1_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m1_bus_enable     : STD_LOGIC;
    signal m1_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m1_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m1_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    signal m2_bus_busy       : STD_LOGIC;
    signal m2_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m2_bus_enable     : STD_LOGIC;
    signal m2_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m2_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m2_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    component bus_expander is
    generic ( use_clk           : in  STD_LOGIC);
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
    end component;

    signal m20_bus_enable     : STD_LOGIC;
    signal m20_bus_busy       : STD_LOGIC;
    signal m20_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m20_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m20_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m20_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    signal m21_bus_busy       : STD_LOGIC;
    signal m21_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m21_bus_enable     : STD_LOGIC;
    signal m21_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m21_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m21_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    signal m22_bus_busy       : STD_LOGIC;
    signal m22_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m22_bus_enable     : STD_LOGIC;
    signal m22_bus_write_mask : STD_LOGIC_VECTOR( 3 downto 0);
    signal m22_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m22_bus_read_data  : STD_LOGIC_VECTOR(31 downto 0);

    component ram_memory is
    port ( clk            : in  STD_LOGIC;
           bus_enable     : in  STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_busy       : out STD_LOGIC;
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0));
    end   component;

    component peripheral_gpio is
    port ( clk            : in  STD_LOGIC;

           bus_busy       : out STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(3 downto 2);
           bus_enable     : in  STD_LOGIC;
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

           gpio           : inout STD_LOGIC_VECTOR);
    end component;

    component peripheral_millis is
    generic ( clock_freq : natural);
    port ( clk            : in  STD_LOGIC;

           bus_busy       : out STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(3 downto 2);
           bus_enable     : in  STD_LOGIC;
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

           gpio           : inout STD_LOGIC_VECTOR);
    end component;

    component peripheral_serial is
    generic ( clock_freq : natural;
              baud_rate  : natural);
    port ( clk            : in  STD_LOGIC;
           bus_enable     : in  STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(3 downto 2);
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0);
           bus_busy       : out STD_LOGIC;

           serial_rx      : in  STD_LOGIC;
           serial_tx      : out STD_LOGIC);
    end   component;

    signal reset_sr : std_logic_vector(3 downto 0) := "1111";

    signal debug_pc : STD_LOGIC_VECTOR(31 downto 0);

    signal cpu_bus_busy   : STD_LOGIC := '1';
    signal cpu_bus_addr   : STD_LOGIC_VECTOR(31 downto 0);
    signal cpu_bus_width  : STD_LOGIC_VECTOR(1 downto 0);
    signal cpu_bus_write  : STD_LOGIC;
    signal cpu_bus_enable : STD_LOGIC;
    signal cpu_bus_dout   : STD_LOGIC_VECTOR(31 downto 0);
    signal cpu_bus_din    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin

process(clk)
   begin
      if rising_edge(clk) then
         reset_sr <= '0' & reset_sr(reset_sr'high downto 1);
      end if;
   end process;

i_riscv_cpu: riscv_cpu port map (
       clk           => clk,
       instr_reg     => instr_reg,
                 
       reset         => reset_sr(0),
       minimize_size => cpu_minimize_size,
                 
       bus_busy      => cpu_bus_busy,
       bus_addr      => cpu_bus_addr,
       bus_width     => cpu_bus_width,
       bus_write     => cpu_bus_write,
       bus_enable    => cpu_bus_enable,
       bus_dout      => cpu_bus_dout,
       bus_din       => cpu_bus_din,

       pc_next       => pc_next,
       debug_pc      => debug_pc,
       debug_sel     => debug_sel,
       debug_data    => debug_data); 


i_bus_bridge: bus_bridge generic map (use_clk => bus_bridge_use_clk)  port map (
       clk               => clk,
       cpu_bus_busy      => cpu_bus_busy,
       cpu_bus_addr      => cpu_bus_addr,
       cpu_bus_width     => cpu_bus_width,
       cpu_bus_dout      => cpu_bus_dout,
       cpu_bus_write     => cpu_bus_write,
       cpu_bus_enable    => cpu_bus_enable,
       cpu_bus_din       => cpu_bus_din,
   
       -- System RAM
       m0_window_base    => x"10000000",
       m0_window_mask    => x"FFFFF000",
       m0_bus_busy       => m0_bus_busy,
       m0_bus_addr       => m0_bus_addr,
       m0_bus_enable     => m0_bus_enable,
       m0_bus_write_mask => m0_bus_write_mask,
       m0_bus_write_data => m0_bus_write_data,
       m0_bus_read_data  => m0_bus_read_data,
       -- Program memory
       m1_window_base    => x"F0000000",
       m1_window_mask    => x"FFFFF000",
       m1_bus_busy       => m1_bus_busy,
       m1_bus_addr       => m1_bus_addr,
       m1_bus_enable     => m1_bus_enable,
       m1_bus_write_mask => m1_bus_write_mask,
       m1_bus_write_data => m1_bus_write_data,
       m1_bus_read_data  => m1_bus_read_data,
       -- Expander
       m2_window_base    => x"E0000000",
       m2_window_mask    => x"FFFFFFC0",
       m2_bus_busy       => m2_bus_busy,
       m2_bus_addr       => m2_bus_addr,
       m2_bus_enable     => m2_bus_enable,
       m2_bus_write_mask => m2_bus_write_mask,
       m2_bus_write_data => m2_bus_write_data,
       m2_bus_read_data  => m2_bus_read_data
    );

i_ram_memory: ram_memory port map (
       clk            => clk,
       bus_enable     => m0_bus_enable,
       bus_addr       => m0_bus_addr(11 downto 2),
       bus_busy       => m0_bus_busy, 
       bus_write_mask => m0_bus_write_mask,
       bus_write_data => m0_bus_write_data,
       bus_read_data  => m0_bus_read_data);

i_program_memory: program_memory port map (
       clk       => clk,

       pc_next   => pc_next,
       instr_reg => instr_reg,

       bus_enable     => m1_bus_enable,
       bus_addr       => m1_bus_addr(11 downto 2),
       bus_busy       => m1_bus_busy, 
       bus_write_mask => m1_bus_write_mask,
       bus_write_data => m1_bus_write_data,
       bus_read_data  => m1_bus_read_data);

i_bus_expander: bus_expander generic map (use_clk => bus_expander_use_clk) port map (
       clk               => clk,
         -- Upstream (slave) interfaces
       s0_bus_enable     => m2_bus_enable,
       s0_bus_addr       => m2_bus_addr(31 downto 2),
       s0_bus_busy       => m2_bus_busy, 
       s0_bus_write_mask => m2_bus_write_mask,
       s0_bus_write_data => m2_bus_write_data,
       s0_bus_read_data  => m2_bus_read_data,

       -- Downstream (master) interfaces
       -- Serial console
       m0_window_base    => x"00000000",
       m0_window_mask    => x"FFFFFFF0",
       m0_bus_busy       => m20_bus_busy,
       m0_bus_addr       => m20_bus_addr,
       m0_bus_enable     => m20_bus_enable,
       m0_bus_write_mask => m20_bus_write_mask,
       m0_bus_write_data => m20_bus_write_data,
       m0_bus_read_data  => m20_bus_read_data,

       -- GPIO 
       m1_window_base    => x"00000010",
       m1_window_mask    => x"FFFFFFF0",
       m1_bus_busy       => m21_bus_busy,
       m1_bus_addr       => m21_bus_addr,
       m1_bus_enable     => m21_bus_enable,
       m1_bus_write_mask => m21_bus_write_mask,
       m1_bus_write_data => m21_bus_write_data,
       m1_bus_read_data  => m21_bus_read_data,

       -- Not used
       m2_window_base    => x"00000020",
       m2_window_mask    => x"FFFFFFF0",
       m2_bus_busy       => m22_bus_busy,
       m2_bus_addr       => m22_bus_addr,
       m2_bus_enable     => m22_bus_enable,
       m2_bus_write_mask => m22_bus_write_mask,
       m2_bus_write_data => m22_bus_write_data,
       m2_bus_read_data  => m22_bus_read_data
    );

i_peripheral_serial: peripheral_serial generic map ( 
       clock_freq => clock_freq,
       baud_rate  => 19200
    ) port map ( 
       clk            => clk,
       bus_enable     => m20_bus_enable,
       bus_addr       => m20_bus_addr(3 downto 2),
       bus_busy       => m20_bus_busy, 
       bus_write_mask => m20_bus_write_mask,
       bus_write_data => m20_bus_write_data,
       bus_read_data  => m20_bus_read_data,
       serial_rx      => uart_txd_in,
       serial_tx      => uart_rxd_out);


i_peripheral_gpio: peripheral_gpio port map ( 
       clk            => clk,
       bus_enable     => m21_bus_enable,
       bus_addr       => m21_bus_addr(3 downto 2),
       bus_busy       => m21_bus_busy, 
       bus_write_mask => m21_bus_write_mask,
       bus_write_data => m21_bus_write_data,
       bus_read_data  => m21_bus_read_data,
       gpio           => gpio);


i_peripheral_millis: peripheral_millis generic map ( clock_freq => clock_freq) port map ( 
       clk            => clk,
       bus_enable     => m22_bus_enable,
       bus_addr       => m22_bus_addr(3 downto 2),
       bus_busy       => m22_bus_busy, 
       bus_write_mask => m22_bus_write_mask,
       bus_write_data => m22_bus_write_data,
       bus_read_data  => m22_bus_read_data,
       gpio           => gpio);

end Behavioral;
