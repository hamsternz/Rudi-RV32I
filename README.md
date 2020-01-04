Rudi-RV32I
==========

Rudi-RV32I is a simple, small, RISC-V processor, supporting the RV32I instruction set, that can be programmed using GCC.

This was a holiday project over Christmas 2019/2020. It has been designed with three key things in mind:

- Minimize complexity
- Minimize required resources
- Maximize Understandability

== THIS IS CURRENTLY IN ALPHA TESTING 

Rudi-RV32 is somewhat unique as it features no pipelining at all. All instructions can complete in a single cycle, including the shift operations. Memory operations might take longer as the external bus can stall the CPU if required. 

Even with this lack of pipelining, the processor can run at > 70MHz in an Artix-7 grade 1 FPGA, and a compact "minimal version" can run at over 50MHz.

A full 32-bit system, with 4kB of Program memory and 4kB of RAM and a serial port can be realized in little as 750 LUTs - 575 for the CPU itself, the rest for the system bus and serial console.


Project structure:

* ./c  - files to support programming the CPU in C
* ./src - HDL Sources
* ./src/test_benches - Test benches
* ./src/program_memory - HDL for RAMs and ROMs
* ./src/systems - HDL for complete systems  - CPUs, RAMs, ROMs and perhipherals
* ./src/boards - Booard specific HDL and constraints
* ./src/bus - CPU bus to peripheral bus adapters 
* ./src/peripheral - Various peripherals
* ./src/cpu - HDL for the Rudi-RV32I CPU
* ./bitstreams - destintation for bitstreams from the ./vivado/build.tcl script
* ./vivado - Scripts for building and testing in vivado

Current known issues:

- Unaligned memory accesses are not supported by the current bus bridge design
- Still in active development and testing - most likely has unknown issues.
- Current serial peripheral is TX only

-- Getting started

* Install Xilinx Vivado
* Install RISC-V GNU toolchain in /opt/riscv - use the rv32ia ISA and ilp32 ABI
* In the './c' directory run 'make' to build the memory images from "test.c"
* In the "./vivado" directory, run "build.sh" to build the bitstream
* You should now have a bitstream for Basys3 in ./bitstreams - program it and connect to the serail port at 19200.

If you find this useful, consider buying me a virutal pizza, virtual beer or virtual dinner via PayPal.
