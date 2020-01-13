src/cpu - A RISC-V 32-bit RV32I CPU

* README.md - This file
* alu.vhd - Arithmetic and Logic Unit
* branch_test.vhd - testing for conditional branches
* data_bus_mux_a.vhd - MUX that directs data into the 'A' side of the ALU and Shifter.
* data_bus_mux_b.vhd - MUX that directs data into the 'B' side of the ALU and Shifter.
* decode.vhd - Instruction Decoder
* program_counter.vhd - Manages the program counter
* register_file.vhd - The register file
* result_bus_mux.vhd - Selects what will be written back to the register file
* riscv_cpu.vhd	- Top level structural design of the CPU 
* shifter.vhd - Barrel shifter
* sign_extender.vhd - Masks and sign-extends values coming from memory.
