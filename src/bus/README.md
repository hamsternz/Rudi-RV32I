./src/bus - Bus adapters to allow peripherals to be connected to the CPU

Bus bridges connect the CPU to peripherals

- README.md	- this file
- bus_bridge.vhd - Can connect the top level CPU bus to three devices (usually RAM, ROM and one peripheral)
- bus_expander.vhd - Expands one device port to three more device ports

If you set "use_clk" to '1' on these the bus will be registered, increasing latency of loads and stores 
by one cycle, but possibly improving overall system timing.

NOTE: Output bus addresses are masked using the "window mask", setting these bits
to zero. So say you connect a bus to 0xE000000 with the mask of 0xFFFF0000, the
addresses on the device will be mapped to 0x00000000 to 0x0000FFFF - so the downstream
devices should then be looking for that range. If you look for the original 
0xE0000000-0xE000FFFF range you will never see it!
