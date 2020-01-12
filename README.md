Rudi-RV32I
==========

Rudi-RV32I is a simple, small, RISC-V processor, supporting the RV32I instruction set, that can be programmed using GCC.

This was a holiday project over Christmas 2019/2020. It has been designed with three key things in mind:

- Minimize complexity
- Minimize required resources
- Maximize Understandability

## THIS IS CURRENTLY IN ALPHA TESTING
This currently works as intended for all my designs, but you are more than likely to discover bugs.

## What is special about this design?
Rudi-RV32 is somewhat unique as it features no pipelining at all. All instructions can 
complete in a single cycle, including the shift operations. Memory operations might take
longer as the external bus can stall the CPU if required. 

Even with this lack of pipelining, the processor can run at > 80MHz in an Artix-7 grade
1 FPGA, and a compact "minimal version" can run at over 50MHz.

A full 32-bit system, with 4kB of Program memory and 4kB of RAM and a serial port can
be realized in little as 750 LUTs - 575 for the CPU itself, the rest for the system
bus and serial console.

## Project structure

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

## Current Peripherals

* 19200 serial console
* 32-bit wide GPIO
* Millisecond counter

## Current known issues / gotchas

* Unaligned memory accesses are not supported by the current bus bridge design - currently high bits read as zeros
* Still in active development and testing - most likely has unknown issues.
* Needs more documentation on how to configure and use.

## Getting started

It's not hard - as long as you get the right RISC-V GNU toolchain installed.

* Install Xilinx Vivado
* Install RISC-V GNU toolchain from https://github.com/riscv/riscv-gnu-toolchain in /opt/riscv - use the rv32ia ISA and ilp32 ABI. Use this configure command when building the RISC-V toolchain:
```
./configure --prefix=/opt/riscv --with-arch=rv32ia --with-abi=ilp32
```
* In the './c' directory run 'make' to build the memory images from "test.c"
* In the "./vivado" directory, run "build.sh" to build the bitstream

You should now have a bitstream for Basys3 in ./bitstreams - program it and connect to the serial port at 19200.

## Performance/size in different configurations:

Different configurations can be configured by setting the generics on the top level design:

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

(clock_freq is used to work out baud rate dividers - it does not actually set the clock frequency)

All configurations include a serial port, a GPIO port and a millisecond counter. Apart fgrom the first line these were contrainted to where timing was just met.

    +------------+-----------+--------------------+----------------------+--------------------+-- -----+-----+----------+--------+
    | Constraint | Clock MHz | Clocked Bus Bridge | Clocked Bus Expander | Minimize CPU Size  | LUTs   | FFs | CPU LUTs | CPU FFs|
    +------------+-----------+--------------------+----------------------+--------------------+-- -----+-----+----------+--------+
    | 20.000 ns  | 50.00 MHz |        No          |         No           |         Yes        |  891   | 301 |    597   |   30   |
    | 17.625 ns  | 56.73 MHz |        No          |         No           |         Yes        |  941   | 306 |    620   |   30   |
    | 16.375 ns  | 61.06 MHz |        No          |        Yes           |         Yes        |  920   | 347 |    598   |   30   |
    | 14.750 ns  | 67.79 MHz |        No          |         No           |          No        | 1108   | 307 |    781   |   31   |
    | 13.625 ns  | 73.39 MHz |       Yes          |         No           |         Yes        |  909   | 377 |    597   |   30   |
    | 12.500 ns  | 80.00 MHz |       Yes          |         No           |          No        | 1078   | 375 |    762   |   31   |
    +------------+-----------+--------------------+----------------------+--------------------+-- -----+-----+----------+--------+

The "Bus Bridge Use Clock" opotion adds a cycle of latency to memory accesses, making loads take three cycles and stores take two cycles. "Bus Expander Use Clock" adds a cycle of latency when talking with peripherals connected to it. Usually if you use the "Clocked Bus Bridge" You would have no need to clock the Bus Expander.

Usage when constained to 50 MHz, with three peripherals, with clocks not used in the bus bridge or bus expander:

    +----------------------------+--------------------+------------+------------+---------+------+-----+--------+
    |          Instance          |       Module       | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 |
    +----------------------------+--------------------+------------+------------+---------+------+-----+--------+
    | basys3_top_level           |              (top) |        891 |        834 |      48 |    9 | 301 |      2 |
    |   (basys3_top_level)       |              (top) |          0 |          0 |       0 |    0 |   0 |      0 |
    |   i_top_level_expanded     | top_level_expanded |        891 |        834 |      48 |    9 | 301 |      2 |
    |     (i_top_level_expanded) | top_level_expanded |          1 |          0 |       0 |    1 |   1 |      0 |
    |     i_bus_bridge           |         bus_bridge |        102 |        102 |       0 |    0 |   0 |      0 |
    |     i_bus_expander         |       bus_expander |         42 |         42 |       0 |    0 |   0 |      0 |
    |     i_peripheral_gpio      |    peripheral_gpio |         35 |         35 |       0 |    0 |  81 |      0 |
    |     i_peripheral_millis    |  peripheral_millis |         42 |         42 |       0 |    0 |  84 |      0 |
    |     i_peripheral_serial    |  peripheral_serial |         67 |         59 |       0 |    8 | 103 |      0 |
    |     i_program_memory       |     program_memory |          5 |          5 |       0 |    0 |   1 |      1 |
    |     i_ram_memory           |         ram_memory |          1 |          1 |       0 |    0 |   1 |      1 |
    |     i_riscv_cpu            |          riscv_cpu |        597 |        549 |      48 |    0 |  30 |      0 |
    |       i_alu                |                alu |        144 |        144 |       0 |    0 |   0 |      0 |
    |       i_branch_test        |        branch_test |         29 |         29 |       0 |    0 |   0 |      0 |
    |       i_data_bus_mux_a     |     data_bus_mux_a |         32 |         32 |       0 |    0 |   0 |      0 |
    |       i_data_bus_mux_b     |     data_bus_mux_b |         22 |         22 |       0 |    0 |   0 |      0 |
    |       i_decoder            |            decoder |         66 |         66 |       0 |    0 |   0 |      0 |
    |       i_program_counter    |    program_counter |         86 |         86 |       0 |    0 |  30 |      0 |
    |       i_register_file      |      register_file |         49 |          1 |      48 |    0 |   0 |      0 |
    |       i_result_bus_mux     |     result_bus_mux |         32 |         32 |       0 |    0 |   0 |      0 |
    |       i_shifter            |            shifter |        113 |        113 |       0 |    0 |   0 |      0 |
    |       i_sign_extender      |      sign_extender |         24 |         24 |       0 |    0 |   0 |      0 |
    +----------------------------+--------------------+------------+------------+---------+------+-----+--------+

Smaller, faster systems are possible by taking short cuts - for example, if you don't fully decode the program memory address
space you can save two levels of logic, and clock closer to 90 MHz.

## Say thanks!
This design is licensed under the MIT license, so you are pretty much free to do whatever you want with it.

If you find this really useful please drop me an email to say thanks. I'll love to hear what you are doing with it.

If you find this really useful or is used commercially, consider buying me a virtual pizza, virtual beer or virtual dinner via PayPal.

