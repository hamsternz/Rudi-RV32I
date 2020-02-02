# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Project TCL command file
# See UG835: Vivado Design Suite Tcl Command Reference Guide for details


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Read TCL script command-line arguments
set OUT_DIR      [ lindex $argv 0 ]
set SYNTH_DCP    [ lindex $argv 1 ]
set ROUTE_DCP    [ lindex $argv 2 ]
set PROJECT      [ lindex $argv 3 ]


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Open a design checkpoint in a new project
#   Options used are:
#     (none)
open_checkpoint ${OUT_DIR}/${SYNTH_DCP}.dcp


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Optimize the current netlist. This will perform the retarget, propconst,
# sweep and bram_power_opt optimizations by default.
#   Options used are:
#     (none)
opt_design


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Automatically place ports and leaf-level instances.
#   Options used are:
#     (none)
place_design


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Route the current design
#   Options used are:
#     (none)
route_design


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check the design for possible timing problems
#   Options used are:
#     -file : Filename to output results to.
check_timing -file ${OUT_DIR}/${ROUTE_DCP}_timing.txt


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Generate the FPGA usage report
#   Options used are:
#     -file : Filename to output results to.
report_utilization -file ${OUT_DIR}/${ROUTE_DCP}_util.txt


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Write a checkpoint of the current design.
#   Options used are:
#     -force : overwrite existing
write_checkpoint ${OUT_DIR}/${ROUTE_DCP}.dcp -force


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Write a bitstream for the current design.
#   Options used are:
#     -force : Overwrite existing file
write_bitstream ${PROJECT}.bit -force
