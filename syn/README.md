## Usage:

To build the full project, type `cd syn` then `make`.  The default project is `basys3`.

To build for another board/project, type `PROJECT=zedboard make` (replace `zedboard` with your project name).  `make PROJECT=zedboard` also works.

Build commands are:

​	`make` - Create a bitfile for this project

​	`make synth` - Only run synthesis for this project.

​	`make route` - Don't re-run synthesis, just place and route the design, then make a bitfile

​	`make clean` - Delete all build files (but not the bitfile)

​	`make clean_all` - Delete all build files (including the bitfile)

The build flow will create a subdirectory under `<project>/<device>` which it will build in.  It will create a `synth.dcp` file and a `route.dcp` file, which you can open in Vivado using "File -> Open Checkpoint".  The final bitfile is saved under `<project>`.



## Files:

./syn - The FPGA build area

This directory contains:

* README.md - This file
* common/hdl_filelist.tcl (important) - a list of the VHDL files that are common to all boards
* common/constraint_filelist.tcl (optional) - a list of constraint files that are common to all boards
* <project>/device.mak - A single line which gives the FPGA part
* <project>/hdl_filelist.tcl - a list of VHDL files that are unique to this board/project
* <project>/constraint_filelist.tcl - a list of constraint files that are unique to this board/project



## Board/Project Filename Requirements:

If you're adding a new board/project, then you need:

`syn/<project>/device.mak` - A single line which sets the FPGA part

`syn/<project>/hdl_filelist.tcl` - a TCL file which points to the board-specific HDL files (kept in `src/boards/<project>/`)

`syn/<project>/constraint_filelist.tcl` - a TCL file which points to the board-specific constraint files (kept in `src/boards/<project>/`)

`src/boards/<project>/<project>.xdc` (pointed to by `syn/<project>/constraint_filelist.tcl`)

`src/boards/<project>/<project>_top_level.vhd` (pointed to by `syn/<project>/hdl_filelist.tcl` )

