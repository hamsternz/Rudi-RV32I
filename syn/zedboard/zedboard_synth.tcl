# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Project TCL command file
# See UG835: Vivado Design Suite Tcl Command Reference Guide for details


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Read TCL script command-line arguments
set OUT_DIR      [ lindex $argv 0 ]
set SYNTH_DCP    [ lindex $argv 1 ]
set DEVICE       [ lindex $argv 2 ]
set PROJECT      [ lindex $argv 3 ]
set PROJECT_TOP  [ lindex $argv 4 ]


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the Vivado project
#   Options used are:
#     -in_memory : Create an in-memory project
create_project -in_memory -part ${DEVICE}

set_property target_language VHDL [ current_project ]


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Load the project's source files
source hdl_filelist.tcl


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Read physical and timing constraints from one of more files
source constraint_filelist.tcl


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Synthesize a design using Vivado Synthesis and open that design
# synth_design [-generic G_BLAHBLAH] -top <TOP_LEVEL> -part <PART>
#   Options used are:
#     -top  : Specify the top module name
#     -part : Target part
synth_design -top ${PROJECT_TOP} -part ${DEVICE}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Write a checkpoint of the current design.
#   Options used are:
#     -force : overwrite existing
write_checkpoint ${OUT_DIR}/${SYNTH_DCP}.dcp -force
