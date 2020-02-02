###############################################################################
# zedboard.xdc - Constraints for the Avnet Zedboard
#
# Part of the Rudi-RV32I project
#
# See https://github.com/hamsternz/Rudi-RV32I
#
# MIT License
#
###############################################################################
#
# Copyright (c) 2020 Mike Field
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

set_property PACKAGE_PIN Y9 [get_ports clk100MHz];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk100MHz];

# ----------------------------------------------------------------------------
# Audio Codec - Bank 13 - Connects to ADAU1761BCPZ
set_property PACKAGE_PIN AB1 [get_ports { i_audio_adr0}];   # "AC-ADR0"
set_property PACKAGE_PIN Y5  [get_ports { o_audio_adr1}];   # "AC-ADR1"
set_property PACKAGE_PIN Y8  [get_ports {io_audio_gpio[0]}];  # "AC-GPIO0"
set_property PACKAGE_PIN AA7 [get_ports {io_audio_gpio[1]}];  # "AC-GPIO1"
set_property PACKAGE_PIN AA6 [get_ports {io_audio_gpio[2]}];  # "AC-GPIO2"
set_property PACKAGE_PIN Y6  [get_ports {io_audio_gpio[3]}];  # "AC-GPIO3"
set_property PACKAGE_PIN AB2 [get_ports { o_audio_mclk}];   # "AC-MCLK"
set_property PACKAGE_PIN AB4 [get_ports { o_audio_sck}];    # "AC-SCK"
set_property PACKAGE_PIN AB5 [get_ports {io_audio_sda}];    # "AC-SDA"


# ----------------------------------------------------------------------------
# OLED Display - Bank 13
set_property PACKAGE_PIN U10  [get_ports {o_oled_dc}];    # "OLED-DC"
set_property PACKAGE_PIN U9   [get_ports {o_oled_res}];   # "OLED-RES"
set_property PACKAGE_PIN AB12 [get_ports {o_oled_sclk}];  # "OLED-SCLK"
set_property PACKAGE_PIN AA12 [get_ports {o_oled_sdin}];  # "OLED-SDIN"
set_property PACKAGE_PIN U11  [get_ports {o_oled_vbat}];  # "OLED-VBAT"
set_property PACKAGE_PIN U12  [get_ports {o_oled_vdd}];   # "OLED-VDD"


# ----------------------------------------------------------------------------
# HDMI Output - Bank 33
set_property PACKAGE_PIN W18  [get_ports { o_hdmi_clk}];     # "HD-CLK"
set_property PACKAGE_PIN V17  [get_ports { o_hdmi_hsync}];   # "HD-HSYNC"
set_property PACKAGE_PIN W17  [get_ports { o_hdmi_vsync}];   # "HD-VSYNC"
set_property PACKAGE_PIN Y13  [get_ports { o_hdmi_data[0]}];   # "HD-D0"
set_property PACKAGE_PIN AA13 [get_ports { o_hdmi_data[1]}];   # "HD-D1"
set_property PACKAGE_PIN AA14 [get_ports { o_hdmi_data[2]}];   # "HD-D2"
set_property PACKAGE_PIN Y14  [get_ports { o_hdmi_data[3]}];   # "HD-D3"
set_property PACKAGE_PIN AB15 [get_ports { o_hdmi_data[4]}];   # "HD-D4"
set_property PACKAGE_PIN AB16 [get_ports { o_hdmi_data[5]}];   # "HD-D5"
set_property PACKAGE_PIN AA16 [get_ports { o_hdmi_data[6]}];   # "HD-D6"
set_property PACKAGE_PIN AB17 [get_ports { o_hdmi_data[7]}];   # "HD-D7"
set_property PACKAGE_PIN AA17 [get_ports { o_hdmi_data[8]}];   # "HD-D8"
set_property PACKAGE_PIN Y15  [get_ports { o_hdmi_data[9]}];   # "HD-D9"
set_property PACKAGE_PIN W13  [get_ports { o_hdmi_data[10]}];  # "HD-D10"
set_property PACKAGE_PIN W15  [get_ports { o_hdmi_data[11]}];  # "HD-D11"
set_property PACKAGE_PIN V15  [get_ports { o_hdmi_data[12]}];  # "HD-D12"
set_property PACKAGE_PIN U17  [get_ports { o_hdmi_data[13]}];  # "HD-D13"
set_property PACKAGE_PIN V14  [get_ports { o_hdmi_data[14]}];  # "HD-D14"
set_property PACKAGE_PIN V13  [get_ports { o_hdmi_data[15]}];  # "HD-D15"
set_property PACKAGE_PIN U16  [get_ports { o_hdmi_dval}];    # "HD-DE"
set_property PACKAGE_PIN W16  [get_ports { o_hdmi_int}];     # "HD-INT"
set_property PACKAGE_PIN AA18 [get_ports {io_hdmi_scl}];     # "HD-SCL"
set_property PACKAGE_PIN Y16  [get_ports {io_hdmi_sda}];     # "HD-SDA"
set_property PACKAGE_PIN U15  [get_ports { o_hdmi_spdif}];   # "HD-SPDIF"
set_property PACKAGE_PIN Y18  [get_ports { i_hdmi_spdifo}];  # "HD-SPDIFO"


# ----------------------------------------------------------------------------
# UART - Use pins on PMOD JA
set_property PACKAGE_PIN Y11  [get_ports ja1];
set_property PACKAGE_PIN AA11 [get_ports ja2];


# ----------------------------------------------------------------------------
# LEDs
set_property PACKAGE_PIN T22 [get_ports {o_led[0]}];
set_property PACKAGE_PIN T21 [get_ports {o_led[1]}];
set_property PACKAGE_PIN U22 [get_ports {o_led[2]}];
set_property PACKAGE_PIN U21 [get_ports {o_led[3]}];
set_property PACKAGE_PIN V22 [get_ports {o_led[4]}];
set_property PACKAGE_PIN W22 [get_ports {o_led[5]}];
set_property PACKAGE_PIN U19 [get_ports {o_led[6]}];
set_property PACKAGE_PIN U14 [get_ports {o_led[7]}];


# ----------------------------------------------------------------------------
# VGA Output - Bank 33
set_property PACKAGE_PIN AA19 [get_ports {o_vga_hs}];      # "VGA-HS"
set_property PACKAGE_PIN Y19  [get_ports {o_vga_vs}];      # "VGA-VS"
set_property PACKAGE_PIN V20  [get_ports {o_vga_red[0]}];    # "VGA-R1"
set_property PACKAGE_PIN U20  [get_ports {o_vga_red[1]}];    # "VGA-R2"
set_property PACKAGE_PIN V19  [get_ports {o_vga_red[2]}];    # "VGA-R3"
set_property PACKAGE_PIN V18  [get_ports {o_vga_red[3]}];    # "VGA-R4"
set_property PACKAGE_PIN AB22 [get_ports {o_vga_green[0]}];  # "VGA-G1"
set_property PACKAGE_PIN AA22 [get_ports {o_vga_green[1]}];  # "VGA-G2"
set_property PACKAGE_PIN AB21 [get_ports {o_vga_green[2]}];  # "VGA-G3"
set_property PACKAGE_PIN AA21 [get_ports {o_vga_green[3]}];  # "VGA-G4"
set_property PACKAGE_PIN Y21  [get_ports {o_vga_blue[0]}];   # "VGA-B1"
set_property PACKAGE_PIN Y20  [get_ports {o_vga_blue[1]}];   # "VGA-B2"
set_property PACKAGE_PIN AB20 [get_ports {o_vga_blue[2]}];   # "VGA-B3"
set_property PACKAGE_PIN AB19 [get_ports {o_vga_blue[3]}];   # "VGA-B4"


# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
set_property PACKAGE_PIN P16 [get_ports {i_btn_c}];  # "BTNC"
set_property PACKAGE_PIN R16 [get_ports {i_btn_d}];  # "BTND"
set_property PACKAGE_PIN N15 [get_ports {i_btn_l}];  # "BTNL"
set_property PACKAGE_PIN R18 [get_ports {i_btn_r}];  # "BTNR"
set_property PACKAGE_PIN T18 [get_ports {i_btn_u}];  # "BTNU"


# ----------------------------------------------------------------------------
# USB OTG Reset - Bank 34
set_property PACKAGE_PIN L16 [get_ports {o_otg_vbusoc}];  # "OTG-VBUSOC"


# ----------------------------------------------------------------------------
# XADC GIO - Bank 34
set_property PACKAGE_PIN H15 [get_ports {io_xadc_gio[0]}];  # "XADC-GIO0"
set_property PACKAGE_PIN R15 [get_ports {io_xadc_gio[1]}];  # "XADC-GIO1"
set_property PACKAGE_PIN K15 [get_ports {io_xadc_gio[2]}];  # "XADC-GIO2"
set_property PACKAGE_PIN J15 [get_ports {io_xadc_gio[3]}];  # "XADC-GIO3"


# ----------------------------------------------------------------------------
# Miscellaneous - Bank 34
set_property PACKAGE_PIN K16 [get_ports {i_pudc_b}];  # "PUDC_B"


# ----------------------------------------------------------------------------
# USB OTG Reset - Bank 35
set_property PACKAGE_PIN G17 [get_ports {o_otg_reset_n}];  # "OTG-RESETN"


# ----------------------------------------------------------------------------
# User DIP Switches - Bank 35
set_property PACKAGE_PIN F22 [get_ports {i_sw[0]}];  # "SW0"
set_property PACKAGE_PIN G22 [get_ports {i_sw[1]}];  # "SW1"
set_property PACKAGE_PIN H22 [get_ports {i_sw[2]}];  # "SW2"
set_property PACKAGE_PIN F21 [get_ports {i_sw[3]}];  # "SW3"
set_property PACKAGE_PIN H19 [get_ports {i_sw[4]}];  # "SW4"
set_property PACKAGE_PIN H18 [get_ports {i_sw[5]}];  # "SW5"
set_property PACKAGE_PIN H17 [get_ports {i_sw[6]}];  # "SW6"
set_property PACKAGE_PIN M15 [get_ports {i_sw[7]}];  # "SW7"


# ----------------------------------------------------------------------------
# XADC AD Channels - Bank 35
set_property PACKAGE_PIN E16 [get_ports {i_ad0n_r}];  # "XADC-AD0N-R"
set_property PACKAGE_PIN F16 [get_ports {i_ad0p_r}];  # "XADC-AD0P-R"
set_property PACKAGE_PIN D17 [get_ports {i_ad8n_n}];  # "XADC-AD8N-R"
set_property PACKAGE_PIN D16 [get_ports {i_ad8p_r}];  # "XADC-AD8P-R"


# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 13
set_property PACKAGE_PIN R7 [get_ports {io_fmc_scl}];  # "FMC-SCL"
set_property PACKAGE_PIN U7 [get_ports {io_fmc_sda}];  # "FMC-SDA"


# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 33
set_property PACKAGE_PIN AB14 [get_ports {i_fmc_prsnt}];  # "FMC-PRSNT"


# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
set_property PACKAGE_PIN Y11  [get_ports {ja1}];   # "JA1"
set_property PACKAGE_PIN AA11 [get_ports {ja2}];   # "JA2"
#set_property PACKAGE_PIN Y10  [get_ports {ja3}];   # "JA3"
#set_property PACKAGE_PIN AA9  [get_ports {ja4}];   # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {ja7}];   # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {ja8}];   # "JA8"
#set_property PACKAGE_PIN AB9  [get_ports {ja9}];   # "JA9"
#set_property PACKAGE_PIN AA8  [get_ports {ja10}];  # "JA10"

# ----------------------------------------------------------------------------
# JB Pmod - Bank 13
#set_property PACKAGE_PIN W12 [get_ports {jb1}];   # "JB1"
#set_property PACKAGE_PIN W11 [get_ports {jb2}];   # "JB2"
#set_property PACKAGE_PIN V10 [get_ports {jb3}];   # "JB3"
#set_property PACKAGE_PIN W8  [get_ports {jb4}];   # "JB4"
#set_property PACKAGE_PIN V12 [get_ports {jb7}];   # "JB7"
#set_property PACKAGE_PIN W10 [get_ports {jb8}];   # "JB8"
#set_property PACKAGE_PIN V9  [get_ports {jb9}];   # "JB9"
#set_property PACKAGE_PIN V8  [get_ports {jb10}];  # "JB10"

# ----------------------------------------------------------------------------
# JC Differential Pmod - Bank 13
#set_property PACKAGE_PIN AB6 [get_ports {jc1_n}];  # "JC1_N"
#set_property PACKAGE_PIN AB7 [get_ports {jc1_p}];  # "JC1_P"
#set_property PACKAGE_PIN AA4 [get_ports {jc2_n}];  # "JC2_N"
#set_property PACKAGE_PIN Y4  [get_ports {jc2_p}];  # "JC2_P"
#set_property PACKAGE_PIN T6  [get_ports {jc3_n}];  # "JC3_N"
#set_property PACKAGE_PIN R6  [get_ports {jc3_p}];  # "JC3_P"
#set_property PACKAGE_PIN U4  [get_ports {jc4_n}];  # "JC4_N"
#set_property PACKAGE_PIN T4  [get_ports {jc4_p}];  # "JC4_P"

# ----------------------------------------------------------------------------
# JD Differential Pmod - Bank 13
#set_property PACKAGE_PIN W7 [get_ports {jd1_n}];  # "JD1_N"
#set_property PACKAGE_PIN V7 [get_ports {jd1_p}];  # "JD1_P"
#set_property PACKAGE_PIN V4 [get_ports {jd2_n}];  # "JD2_N"
#set_property PACKAGE_PIN V5 [get_ports {jd2_p}];  # "JD2_P"
#set_property PACKAGE_PIN W5 [get_ports {jd3_n}];  # "JD3_N"
#set_property PACKAGE_PIN W6 [get_ports {jd3_p}];  # "JD3_P"
#set_property PACKAGE_PIN U5 [get_ports {jd4_n}];  # "JD4_N"
#set_property PACKAGE_PIN U6 [get_ports {jd4_p}];  # "JD4_P"

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 34
#set_property PACKAGE_PIN L19 [get_ports {fmc_clk0_n}];     # "FMC-CLK0_N"
#set_property PACKAGE_PIN L18 [get_ports {fmc_clk0_p}];     # "FMC-CLK0_P"
#set_property PACKAGE_PIN M20 [get_ports {fmc_la00_cc_n}];  # "FMC-LA00_CC_N"
#set_property PACKAGE_PIN M19 [get_ports {fmc_la00_cc_p}];  # "FMC-LA00_CC_P"
#set_property PACKAGE_PIN N20 [get_ports {fmc_la01_cc_n}];  # "FMC-LA01_CC_N"
#set_property PACKAGE_PIN N19 [get_ports {fmc_la01_cc_p}];  # "FMC-LA01_CC_P" - corrected 6/6/16 GE
#set_property PACKAGE_PIN P18 [get_ports {fmc_la02_n}];     # "FMC-LA02_N"
#set_property PACKAGE_PIN P17 [get_ports {fmc_la02_p}];     # "FMC-LA02_P"
#set_property PACKAGE_PIN P22 [get_ports {fmc_la03_n}];     # "FMC-LA03_N"
#set_property PACKAGE_PIN N22 [get_ports {fmc_la03_p}];     # "FMC-LA03_P"
#set_property PACKAGE_PIN M22 [get_ports {fmc_la04_n}];     # "FMC-LA04_N"
#set_property PACKAGE_PIN M21 [get_ports {fmc_la04_p}];     # "FMC-LA04_P"
#set_property PACKAGE_PIN K18 [get_ports {fmc_la05_n}];     # "FMC-LA05_N"
#set_property PACKAGE_PIN J18 [get_ports {fmc_la05_p}];     # "FMC-LA05_P"
#set_property PACKAGE_PIN L22 [get_ports {fmc_la06_n}];     # "FMC-LA06_N"
#set_property PACKAGE_PIN L21 [get_ports {fmc_la06_p}];     # "FMC-LA06_P"
#set_property PACKAGE_PIN T17 [get_ports {fmc_la07_n}];     # "FMC-LA07_N"
#set_property PACKAGE_PIN T16 [get_ports {fmc_la07_p}];     # "FMC-LA07_P"
#set_property PACKAGE_PIN J22 [get_ports {fmc_la08_n}];     # "FMC-LA08_N"
#set_property PACKAGE_PIN J21 [get_ports {fmc_la08_p}];     # "FMC-LA08_P"
#set_property PACKAGE_PIN R21 [get_ports {fmc_la09_n}];     # "FMC-LA09_N"
#set_property PACKAGE_PIN R20 [get_ports {fmc_la09_p}];     # "FMC-LA09_P"
#set_property PACKAGE_PIN T19 [get_ports {fmc_la10_n}];     # "FMC-LA10_N"
#set_property PACKAGE_PIN R19 [get_ports {fmc_la10_p}];     # "FMC-LA10_P"
#set_property PACKAGE_PIN N18 [get_ports {fmc_la11_n}];     # "FMC-LA11_N"
#set_property PACKAGE_PIN N17 [get_ports {fmc_la11_p}];     # "FMC-LA11_P"
#set_property PACKAGE_PIN P21 [get_ports {fmc_la12_n}];     # "FMC-LA12_N"
#set_property PACKAGE_PIN P20 [get_ports {fmc_la12_p}];     # "FMC-LA12_P"
#set_property PACKAGE_PIN M17 [get_ports {fmc_la13_n}];     # "FMC-LA13_N"
#set_property PACKAGE_PIN L17 [get_ports {fmc_la13_p}];     # "FMC-LA13_P"
#set_property PACKAGE_PIN K20 [get_ports {fmc_la14_n}];     # "FMC-LA14_N"
#set_property PACKAGE_PIN K19 [get_ports {fmc_la14_p}];     # "FMC-LA14_P"
#set_property PACKAGE_PIN J17 [get_ports {fmc_la15_n}];     # "FMC-LA15_N"
#set_property PACKAGE_PIN J16 [get_ports {fmc_la15_p}];     # "FMC-LA15_P"
#set_property PACKAGE_PIN K21 [get_ports {fmc_la16_n}];     # "FMC-LA16_N"
#set_property PACKAGE_PIN J20 [get_ports {fmc_la16_p}];     # "FMC-LA16_P"

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 35
#set_property PACKAGE_PIN C19 [get_ports {fmc_clk1_n}];     # "FMC-CLK1_N"
#set_property PACKAGE_PIN D18 [get_ports {fmc_clk1_p}];     # "FMC-CLK1_P"
#set_property PACKAGE_PIN B20 [get_ports {fmc_la17_cc_n}];  # "FMC-LA17_CC_N"
#set_property PACKAGE_PIN B19 [get_ports {fmc_la17_cc_p}];  # "FMC-LA17_CC_P"
#set_property PACKAGE_PIN C20 [get_ports {fmc_la18_cc_n}];  # "FMC-LA18_CC_N"
#set_property PACKAGE_PIN D20 [get_ports {fmc_la18_cc_p}];  # "FMC-LA18_CC_P"
#set_property PACKAGE_PIN G16 [get_ports {fmc_la19_n}];     # "FMC-LA19_N"
#set_property PACKAGE_PIN G15 [get_ports {fmc_la19_p}];     # "FMC-LA19_P"
#set_property PACKAGE_PIN G21 [get_ports {fmc_la20_n}];     # "FMC-LA20_N"
#set_property PACKAGE_PIN G20 [get_ports {fmc_la20_p}];     # "FMC-LA20_P"
#set_property PACKAGE_PIN E20 [get_ports {fmc_la21_n}];     # "FMC-LA21_N"
#set_property PACKAGE_PIN E19 [get_ports {fmc_la21_p}];     # "FMC-LA21_P"
#set_property PACKAGE_PIN F19 [get_ports {fmc_la22_n}];     # "FMC-LA22_N"
#set_property PACKAGE_PIN G19 [get_ports {fmc_la22_p}];     # "FMC-LA22_P"
#set_property PACKAGE_PIN D15 [get_ports {fmc_la23_n}];     # "FMC-LA23_N"
#set_property PACKAGE_PIN E15 [get_ports {fmc_la23_p}];     # "FMC-LA23_P"
#set_property PACKAGE_PIN A19 [get_ports {fmc_la24_n}];     # "FMC-LA24_N"
#set_property PACKAGE_PIN A18 [get_ports {fmc_la24_p}];     # "FMC-LA24_P"
#set_property PACKAGE_PIN C22 [get_ports {fmc_la25_n}];     # "FMC-LA25_N"
#set_property PACKAGE_PIN D22 [get_ports {fmc_la25_p}];     # "FMC-LA25_P"
#set_property PACKAGE_PIN E18 [get_ports {fmc_la26_n}];     # "FMC-LA26_N"
#set_property PACKAGE_PIN F18 [get_ports {fmc_la26_p}];     # "FMC-LA26_P"
#set_property PACKAGE_PIN D21 [get_ports {fmc_la27_n}];     # "FMC-LA27_N"
#set_property PACKAGE_PIN E21 [get_ports {fmc_la27_p}];     # "FMC-LA27_P"
#set_property PACKAGE_PIN A17 [get_ports {fmc_la28_n}];     # "FMC-LA28_N"
#set_property PACKAGE_PIN A16 [get_ports {fmc_la28_p}];     # "FMC-LA28_P"
#set_property PACKAGE_PIN C18 [get_ports {fmc_la29_n}];     # "FMC-LA29_N"
#set_property PACKAGE_PIN C17 [get_ports {fmc_la29_p}];     # "FMC-LA29_P"
#set_property PACKAGE_PIN B15 [get_ports {fmc_la30_n}];     # "FMC-LA30_N"
#set_property PACKAGE_PIN C15 [get_ports {fmc_la30_p}];     # "FMC-LA30_P"
#set_property PACKAGE_PIN B17 [get_ports {fmc_la31_n}];     # "FMC-LA31_N"
#set_property PACKAGE_PIN B16 [get_ports {fmc_la31_p}];     # "FMC-LA31_P"
#set_property PACKAGE_PIN A22 [get_ports {fmc_la32_n}];     # "FMC-LA32_N"
#set_property PACKAGE_PIN A21 [get_ports {fmc_la32_p}];     # "FMC-LA32_P"
#set_property PACKAGE_PIN B22 [get_ports {fmc_la33_n}];     # "FMC-LA33_N"
#set_property PACKAGE_PIN B21 [get_ports {fmc_la33_p}];     # "FMC-LA33_P"


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
