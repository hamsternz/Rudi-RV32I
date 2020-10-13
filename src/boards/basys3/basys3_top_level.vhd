--###############################################################################
--# basys3_top_level.vhd  - Top level HDL design for the Basys3 board
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

library UNISIM;
use UNISIM.vcomponents.all;

entity basys3_top_level is
  port ( clk100mhz    : in  STD_LOGIC;
         btnC         : in  STD_LOGIC;
         led          : inout std_logic_vector(15 downto 0);
         uart_rxd_out : out STD_LOGIC := '1';
         uart_txd_in  : in  STD_LOGIC);
end entity;

architecture Behavioral of basys3_top_level is
    constant ext_clock_rate       : natural   := 100000000;
    constant multiplier           : real      := 10.000;
    constant divider              : real      := 14.750;
    constant bus_bridge_use_clk   : std_logic := '0';
    constant bus_expander_use_clk : std_logic := '0';
    constant cpu_minimize_size    : std_logic := '0';

    component top_level_expanded is
    generic ( clock_freq           : natural   := 50000000;
              bus_bridge_use_clk   : std_logic := '1';
              bus_expander_use_clk : std_logic := '1';
              cpu_minimize_size    : std_logic := '1');
    port ( clk              : in  STD_LOGIC;
           uart_rxd_out     : out STD_LOGIC := '1';
           uart_txd_in      : in  STD_LOGIC;
           gpio             : inout std_logic_vector(15 downto 0);
           debug_sel        : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data       : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal clk : STD_LOGIC;
    signal fb  : STD_LOGIC;
begin

   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => multiplier,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => divider,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk,     -- 1-bit output: CLKOUT0
      CLKOUT0B => open,   -- 1-bit output: Inverted CLKOUT0
      CLKOUT1 => open,     -- 1-bit output: CLKOUT1
      CLKOUT1B => open,   -- 1-bit output: Inverted CLKOUT1
      CLKOUT2 => open,     -- 1-bit output: CLKOUT2
      CLKOUT2B => open,   -- 1-bit output: Inverted CLKOUT2
      CLKOUT3 => open,     -- 1-bit output: CLKOUT3
      CLKOUT3B => open,   -- 1-bit output: Inverted CLKOUT3
      CLKOUT4 => open,     -- 1-bit output: CLKOUT4
      CLKOUT5 => open,     -- 1-bit output: CLKOUT5
      CLKOUT6 => open,     -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => fb,   -- 1-bit output: Feedback clock
      CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => open,       -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => clk100mhz,       -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down
      RST => '0',             -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => fb      -- 1-bit input: Feedback clock
   );

i_top_level_expanded: top_level_expanded generic map ( 
        clock_freq           => natural(real(ext_clock_rate)*multiplier/divider), 
        bus_bridge_use_clk   => bus_bridge_use_clk,
        bus_expander_use_clk => bus_expander_use_clk,
        cpu_minimize_size    => cpu_minimize_size
    ) port map (
        clk          => clk,
        uart_rxd_out => uart_rxd_out,
        uart_txd_in  => uart_txd_in,
        gpio         => led,
        debug_sel    => "00000",
        debug_data   => open);
end Behavioral;

