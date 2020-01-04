###############################################################################
# test.tcl  - A vivado script to run the simulation test_bench
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
read_vhdl ../src/sign_extender.vhd
read_vhdl ../src/data_bus_mux_a.vhd
read_vhdl ../src/decode.vhd
read_vhdl ../src/data_bus_mux_b.vhd
read_vhdl ../src/program_counter.vhd
read_vhdl ../src/station_alu.vhd
read_vhdl ../src/result_bus_mux.vhd
read_vhdl ../src/ram.vhd
read_vhdl ../src/station_test.vhd
read_vhdl ../src/top_level.vhd
read_vhdl ../src/riscv_cpu.vhd
read_vhdl ../src/register_file.vhd
read_vhdl ../src/branch_test.vhd
read_vhdl ../src/station_shifter.vhd
read_vhdl ../src/program_memory.vhd

# read constraints
read_xdc ../src/cmod_a7.xdc

# Synthesize Design
synth_design -top top_level -part "xc7a35tcpg236-1" -flatten_hierarchy none
# Opt Design 
opt_design
# Place Design
place_design 
# Route Design
route_design
report_timing -nworst 1
report_utilization -hierarchical
	
# Write out bitfile
## write_debug_probes -force my_proj/my_proj.ltx
## write_bitstream -force my_proj/my_proj.bit
