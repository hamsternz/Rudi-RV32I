###############################################################################
# build.tcl  - A vivado build script
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

set_part "xc7a35tcpg236-1"

# read all design files
read_vhdl ../src/systems/top_level_expanded.vhd

# The CPU design
read_vhdl ../src/cpu/riscv_cpu.vhd
read_vhdl ../src/cpu/decode.vhd
read_vhdl ../src/cpu/data_bus_mux_a.vhd
read_vhdl ../src/cpu/data_bus_mux_b.vhd
read_vhdl ../src/cpu/result_bus_mux.vhd
read_vhdl ../src/cpu/program_counter.vhd
read_vhdl ../src/cpu/shifter.vhd
read_vhdl ../src/cpu/alu.vhd
read_vhdl ../src/cpu/sign_extender.vhd
read_vhdl ../src/cpu/register_file.vhd
read_vhdl ../src/cpu/branch_test.vhd

# The Program ROM and RAM
read_vhdl ../src/program_memory/program_memory_test.vhd
read_vhdl ../src/program_memory/ram_memory_test.vhd

# The 'external' CPU bus - bridge, RAM and Serial peripherals
read_vhdl ../src/bus/bus_bridge.vhd
read_vhdl ../src/bus/bus_expander.vhd
read_vhdl ../src/peripheral/peripheral_gpio.vhd
read_vhdl ../src/peripheral/peripheral_ram.vhd
read_vhdl ../src/peripheral/peripheral_serial.vhd
read_vhdl ../src/peripheral/peripheral_millis.vhd

# board specific stuff
read_vhdl ../src/boards/basys3_top_level.vhd
read_xdc ../src/boards/basys3.xdc

# Synthesize Design
synth_design -top basys3_top_level -part "xc7a35tcpg236-1" -flatten_hierarchy none
write_checkpoint basys3_top_level_synth.dcp

# Opt Design 
opt_design
# Place Design
place_design 
# Route Design
route_design

write_checkpoint basys3_top_level_route.dcp

# Write the bitstream	
write_bitstream -force -file ../bitstreams/basys3_top_level.bit

# Generate reports
report_timing -nworst 1
report_utilization -hierarchical
