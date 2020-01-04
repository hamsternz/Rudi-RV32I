#!/bin/bash
###############################################################################
# gen_mem.sh - script to generate HDL memory files
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
OBJCOPY=/opt/riscv/bin/riscv32-unknown-linux-gnu-objcopy

if [ ! -f "$1" ]
then
   echo No file name given
   exit
fi

$OBJCOPY $1 /dev/null --dump-section .data=data.section.$$ --dump-section .text=text.section.$$

if [ ! -f data.section.$$ -o ! -f text.section.$$ ]
then
   echo Unable to dump sections
   exit 
fi

(
    #############################
    ##### Output file header
    #############################
    grep ^H: template_program_memory.vhd | cut -c 3- 

    #############################
    ##### Output Program data
    #############################
    cat text.section.$$ | od -An -w4 -v -tx4 | awk '{ print "         " NR-1 " => x\"" $1 "\"," }'

    #############################
    ##### Output file footer
    #############################
    grep ^F: template_program_memory.vhd | cut -c 3- 
) > ../src/program_memory/program_memory_$1.vhd

(
    #############################
    ##### Output file header
    #############################
    grep ^H: template_ram_memory.vhd | cut -c 3- 

    #############################
    ##### Output Program data
    #############################
    cat data.section.$$ | od -An -w4 -v -tx4 | awk '{ print "         " NR-1 " => x\"" $1 "\"," }'

    #############################
    ##### Output file footer
    #############################
    grep ^F: template_ram_memory.vhd | cut -c 3- 
) > ../src/program_memory/ram_memory_$1.vhd

rm data.section.$$ text.section.$$
