# =========================================================================
# Makefile syntax:
# variable = value
# variable ?= value (if value isn't already set, such as an environment variable)
#
# target:  dependency1 dependency2 ...
#    <tab> command

# =========================================================================
# Key project names and directories
# Note: The top level HDL file must be named ${PROJECT}_top_level
#       The build system expects it to be placed in Rudi-RV32I\src\boards\${PROJECT}
PROJECT = basys3
DEVICE  = xc7a35tcpg236-1
OUT_DIR = ${DEVICE}

PROJECT_TOP = ${PROJECT}_top_level

# =========================================================================
# Build names
SYNTH_NAME = ${PROJECT}_synth
ROUTE_NAME = ${PROJECT}_route


# =========================================================================
# Xilinx Vivado build flags are in the respective '.tcl' files
# See UG894 for details


# =========================================================================
# Build recipes
# 00 - Miscellaneous 'make' recpies
#
# 01a - Load design/cores: read_vhdl xxx.vhd  read_checkpoint xxx.dcp
# 01b - Synthesis: synth_design
#
# 02  - Place and Route:
# 02a - Optimisation: opt_design -verbose
# 02b - Place: place_design
# 02c - Route: route_design
#
# 03 - BitGen (Bitstream Generation): write_bitstream


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 00a - Make everything
# Typing 'make' by itself runs the first target entry in the makefile
all: synth route

# 00b - Housekeeping
clean:
	rm -fR .Xil ${OUT_DIR}

clean_all:
	rm -fR .Xil ${OUT_DIR} ${PROJECT}.bit

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 01 - Synthesis
.PHONY: synth
synth: ${OUT_DIR}/${SYNTH_NAME}.dcp
${OUT_DIR}/${SYNTH_NAME}.dcp : ../../src/boards/${PROJECT}/${PROJECT_TOP}.vhd ${SYNTH_NAME}.tcl

# Invoke the synthesis script
	@echo
	@echo
	@echo '## ---  Running Synthesis  --- ##'
	@echo
	mkdir -p ${OUT_DIR}
	vivado -mode batch -source ${SYNTH_NAME}.tcl \
		-log ${OUT_DIR}/${SYNTH_NAME}.log -journal ${OUT_DIR}/${SYNTH_NAME}.jou \
		-tclargs ${OUT_DIR} ${SYNTH_NAME} ${DEVICE} ${PROJECT} ${PROJECT_TOP}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 02 - Optimise, Place and Route: route_design
.PHONY: route
route: ${OUT_DIR}/${ROUTE_NAME}.dcp
${OUT_DIR}/${ROUTE_NAME}.dcp : ${OUT_DIR}/${SYNTH_NAME}.dcp ${ROUTE_NAME}.tcl

# Invoke the opt, place and route script
	@echo
	@echo
	@echo '## ---  Running Place and Route  --- ##'
	@echo
	vivado -mode batch -source ${ROUTE_NAME}.tcl \
		-log ${OUT_DIR}/${ROUTE_NAME}.log -journal ${OUT_DIR}/${ROUTE_NAME}.jou \
		-tclargs ${OUT_DIR} ${SYNTH_NAME} ${ROUTE_NAME} ${PROJECT}
