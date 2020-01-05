# read all design files
read_vhdl ../src/cpu/sign_extender.vhd
read_vhdl ../src/cpu/data_bus_mux_a.vhd
read_vhdl ../src/cpu/decode.vhd
read_vhdl ../src/cpu/data_bus_mux_b.vhd
read_vhdl ../src/cpu/program_counter.vhd
read_vhdl ../src/cpu/alu.vhd
read_vhdl ../src/cpu/result_bus_mux.vhd
read_vhdl ../src/cpu/riscv_cpu.vhd
read_vhdl ../src/cpu/register_file.vhd
read_vhdl ../src/cpu/branch_test.vhd
read_vhdl ../src/cpu/shifter.vhd

# Top level system design (CPU + Memories + Peripherals)
read_vhdl ../src/systems/top_level.vhd

# The memory containing test code
read_vhdl ../src/program_memory/program_memory.vhd
read_vhdl ../src/program_memory/ram_memory.vhd

# The CPU bus - bridge, RAM and Serial peripherals
read_vhdl ../src/bus/bus_bridge.vhd
read_vhdl ../src/peripheral/peripheral_serial.vhd
read_vhdl ../src/peripheral/peripheral_gpio.vhd
read_vhdl ../src/peripheral/peripheral_ram.vhd

# Test bench
read_vhdl ../src/test_benches/tb_riscv.vhd

save_project_as sim -force
set_property top tb_riscv [get_fileset sim_1]
launch_simulation -simset sim_1 -mode behavioral
run 5us
quit
