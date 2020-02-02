--###############################################################################
--# zedboard_top_level.vhd  - Top level HDL design for the Avnet Zedboard
--#
--# Part of the Rudi-RV32I project
--#
--# See https://github.com/hamsternz/Rudi-RV32I
--#
--# MIT License
--#
--###############################################################################
--#
--# Copyright (c) 2020 Mike Field and Iain Waugh
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity zedboard_top_level is
  port (
    ----------------------------------------------------------------------------
    -- Clock Source - Bank 13
    clk100MHz : in std_logic;          -- "GCLK"

    ----------------------------------------------------------------------------
    -- Audio Codec - Bank 13 - Connects to ADAU1761BCPZ
    i_audio_adr0  : in    std_logic;                     -- "AC-ADR0"
    o_audio_adr1  : out   std_logic;                     -- "AC-ADR1"
    io_audio_gpio : inout std_logic_vector(3 downto 0);  -- "AC-GPIO[3:0]"
    o_audio_mclk  : out   std_logic;                     -- "AC-MCLK"
    o_audio_sck   : out   std_logic;                     -- "AC-SCK"
    io_audio_sda  : inout std_logic;                     -- "AC-SDA"

    ----------------------------------------------------------------------------
    -- OLED Display - Bank 13
    o_oled_dc   : out std_logic;        -- "OLED-DC"
    o_oled_res  : out std_logic;        -- "OLED-RES"
    o_oled_sclk : out std_logic;        -- "OLED-SCLK"
    o_oled_sdin : out std_logic;        -- "OLED-SDIN"
    o_oled_vbat : out std_logic;        -- "OLED-VBAT"
    o_oled_vdd  : out std_logic;        -- "OLED-VDD"

    ----------------------------------------------------------------------------
    -- HDMI Output - Bank 33
    o_hdmi_clk    : out   std_logic;                      -- "HD-CLK"
    o_hdmi_hsync  : out   std_logic;                      -- "HD-HSYNC"
    o_hdmi_vsync  : out   std_logic;                      -- "HD-VSYNC"
    o_hdmi_data   : out   std_logic_vector(15 downto 0);  -- "HD-D[15:0]"
    o_hdmi_dval   : out   std_logic;                      -- "HD-DE"
    o_hdmi_int    : out   std_logic;                      -- "HD-INT"
    io_hdmi_scl   : inout std_logic;                      -- "HD-SCL"
    io_hdmi_sda   : inout std_logic;                      -- "HD-SDA"
    o_hdmi_spdif  : out   std_logic;                      -- "HD-SPDIF"
    i_hdmi_spdifo : in    std_logic;                      -- "HD-SPDIFO"

    ----------------------------------------------------------------------------
    -- User LEDs - Bank 33
    o_led : out std_logic_vector(7 downto 0);  -- "LD[7:0]"

    ----------------------------------------------------------------------------
    -- VGA Output - Bank 33
    o_vga_hs    : out std_logic;             -- "VGA-HS"
    o_vga_vs    : out std_logic;             -- "VGA-VS"
    o_vga_red   : out unsigned(3 downto 0);  -- "VGA-R[3:0]"
    o_vga_green : out unsigned(3 downto 0);  -- "VGA-G[3:0]"
    o_vga_blue  : out unsigned(3 downto 0);  -- "VGA-B[3:0]"

    ----------------------------------------------------------------------------
    -- User Push Buttons - Bank 34
    i_btn_c : in std_logic;             -- "BTNC"
    i_btn_d : in std_logic;             -- "BTND"
    i_btn_l : in std_logic;             -- "BTNL"
    i_btn_r : in std_logic;             -- "BTNR"
    i_btn_u : in std_logic;             -- "BTNU"

    -- ----------------------------------------------------------------------------
    -- USB OTG Reset - Bank 34
    o_otg_vbusoc : out std_logic;       -- "OTG-VBUSOC"

    ----------------------------------------------------------------------------
    -- XADC GIO - Bank 34
    io_xadc_gio : inout std_logic_vector(3 downto 0);  -- "XADC-GIO[3:0]"

    ----------------------------------------------------------------------------
    -- Miscellaneous - Bank 34
    i_pudc_b : in std_logic;            -- "PUDC_B"

    ----------------------------------------------------------------------------
    -- USB OTG Reset - Bank 35
    o_otg_reset_n : out std_logic;      -- "OTG-RESETN"

    ----------------------------------------------------------------------------
    -- User DIP Switches - Bank 35
    i_sw : in std_logic_vector(7 downto 0);  -- "SW[7:0]"

    ----------------------------------------------------------------------------
    -- XADC AD Channels - Bank 35
    i_ad0n_r : in std_logic;            -- "XADC-AD0N-R"
    i_ad0p_r : in std_logic;            -- "XADC-AD0P-R"
    i_ad8n_n : in std_logic;            -- "XADC-AD8N-R"
    i_ad8p_r : in std_logic;            -- "XADC-AD8P-R"

    ----------------------------------------------------------------------------
    -- FMC Expansion Connector - Bank 13
    io_fmc_scl : inout std_logic;       -- "FMC-SCL"
    io_fmc_sda : inout std_logic;       -- "FMC-SDA"

    ----------------------------------------------------------------------------
    -- FMC Expansion Connector - Bank 33
    i_fmc_prsnt : in std_logic;          -- "FMC-PRSNT"

    ----------------------------------------------------------------------------
    -- Partial PMOD JA (used as a UART)
    ja1 : out std_logic;
    ja2 : in std_logic
    );
end entity;

architecture Behavioral of zedboard_top_level is

  constant ext_clock_rate       : natural   := 100000000;
  constant multiplier           : real      := 10.000;
  constant divider              : real      := 14.750;
  constant bus_bridge_use_clk   : std_logic := '0';
  constant bus_expander_use_clk : std_logic := '0';
  constant cpu_minimize_size    : std_logic := '0';

  -- Internal clocking signals
  signal clk : std_logic;
  signal fb  : std_logic;

  signal gpio : std_logic_vector(15 downto 0);

  -- Tristate breakout signals
  signal i_audio_gpio   : std_logic_vector(3 downto 0);
  signal o_audio_gpio   : std_logic_vector(3 downto 0) := (others => '0');
  signal audio_gpio_out : std_logic                    := '0';

  signal i_audio_sda   : std_logic;
  signal o_audio_sda   : std_logic := '0';
  signal audio_sda_out : std_logic := '0';

  signal i_hdmi_scl   : std_logic;
  signal o_hdmi_scl   : std_logic := '0';
  signal hdmi_scl_out : std_logic := '0';

  signal i_hdmi_sda   : std_logic;
  signal o_hdmi_sda   : std_logic := '0';
  signal hdmi_sda_out : std_logic := '0';

  signal i_xadc_gio   : std_logic_vector(3 downto 0);
  signal o_xadc_gio   : std_logic_vector(3 downto 0) := (others => '0');
  signal xadc_gio_out : std_logic                    := '0';

  signal i_fmc_scl   : std_logic;
  signal o_fmc_scl   : std_logic := '0';
  signal fmc_scl_out : std_logic := '0';

  signal i_fmc_sda   : std_logic;
  signal o_fmc_sda   : std_logic := '0';
  signal fmc_sda_out : std_logic := '0';

begin

  MMCME2_BASE_inst : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => multiplier,  -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 0.0,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE     => 1,
      CLKOUT2_DIVIDE     => 1,
      CLKOUT3_DIVIDE     => 1,
      CLKOUT4_DIVIDE     => 1,
      CLKOUT5_DIVIDE     => 1,
      CLKOUT6_DIVIDE     => 1,
      CLKOUT0_DIVIDE_F   => divider,  -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT3_PHASE      => 0.0,
      CLKOUT4_PHASE      => 0.0,
      CLKOUT5_PHASE      => 0.0,
      CLKOUT6_PHASE      => 0.0,
      CLKOUT4_CASCADE    => false,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE      => 1,          -- Master division value (1-106)
      REF_JITTER1        => 0.0,  -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => false  -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
    port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => clk,                 -- 1-bit output: CLKOUT0
      CLKOUT0B  => open,                -- 1-bit output: Inverted CLKOUT0
      CLKOUT1   => open,                -- 1-bit output: CLKOUT1
      CLKOUT1B  => open,                -- 1-bit output: Inverted CLKOUT1
      CLKOUT2   => open,                -- 1-bit output: CLKOUT2
      CLKOUT2B  => open,                -- 1-bit output: Inverted CLKOUT2
      CLKOUT3   => open,                -- 1-bit output: CLKOUT3
      CLKOUT3B  => open,                -- 1-bit output: Inverted CLKOUT3
      CLKOUT4   => open,                -- 1-bit output: CLKOUT4
      CLKOUT5   => open,                -- 1-bit output: CLKOUT5
      CLKOUT6   => open,                -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => fb,                  -- 1-bit output: Feedback clock
      CLKFBOUTB => open,                -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED    => open,                -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1    => clk100MHz,           -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN    => '0',                 -- 1-bit input: Power-down
      RST       => '0',                 -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => fb                   -- 1-bit input: Feedback clock
      );

  i_top_level_expanded : entity work.top_level_expanded
    generic map (
      clock_freq           => natural(real(ext_clock_rate)/divider),
      bus_bridge_use_clk   => bus_bridge_use_clk,
      bus_expander_use_clk => bus_expander_use_clk,
      cpu_minimize_size    => cpu_minimize_size
      )
    port map (
      clk          => clk,
      uart_rxd_out => ja1,
      uart_txd_in  => ja2,
      gpio         => gpio,
      debug_sel    => "00000",
      debug_data   => open
      );
  o_led <= gpio(7 downto 0);


  --==========================================================================
  -- 
  -- Tie off unused ports/signal (don't leave them floating)
  
  ----------------------------------------------------------------------------
  -- Audio Codec - Bank 13 - Connects to ADAU1761BCPZ
  o_audio_adr1 <= '0';
  o_audio_mclk <= '0';
  o_audio_sck  <= '0';

  i_audio_gpio  <= io_audio_gpio;
  io_audio_gpio <= o_audio_gpio when audio_gpio_out = '1' else (others => 'Z');

  i_audio_sda  <= io_audio_sda;
  io_audio_sda <= o_audio_sda when audio_sda_out = '1' else 'Z';

  ----------------------------------------------------------------------------
  -- OLED Display - Bank 13
  o_oled_dc   <= '0';
  o_oled_res  <= '0';
  o_oled_sclk <= '0';
  o_oled_sdin <= '0';
  o_oled_vbat <= '0';
  o_oled_vdd  <= '0';

  ----------------------------------------------------------------------------
  -- HDMI Output - Bank 33
  o_hdmi_clk   <= '0';
  o_hdmi_hsync <= '0';
  o_hdmi_vsync <= '0';
  o_hdmi_data  <= (others => '0');
  o_hdmi_dval  <= '0';
  o_hdmi_int   <= '0';
  o_hdmi_spdif <= '0';

  i_hdmi_scl  <= io_hdmi_scl;
  io_hdmi_scl <= o_hdmi_scl when hdmi_scl_out = '1' else 'Z';

  i_hdmi_sda  <= io_hdmi_sda;
  io_hdmi_sda <= o_hdmi_sda when hdmi_sda_out = '1' else 'Z';

  i_xadc_gio  <= io_xadc_gio;
  io_xadc_gio <= o_xadc_gio when xadc_gio_out = '1' else (others => 'Z');

  ----------------------------------------------------------------------------
  -- USB OTG Reset - Bank 35
  o_otg_vbusoc  <= '0';
  o_otg_reset_n <= '0';

  ----------------------------------------------------------------------------
  -- FMC Expansion Connector - Bank 13
  i_fmc_scl  <= io_fmc_scl;
  io_fmc_scl <= o_fmc_scl when fmc_scl_out = '1' else 'Z';

  i_fmc_sda  <= io_fmc_sda;
  io_fmc_sda <= o_fmc_sda when fmc_sda_out = '1' else 'Z';

end Behavioral;
