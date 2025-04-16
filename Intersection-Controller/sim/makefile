# Directories
SRC_DIR = ../src/advanced_controller
TB_DIR = ../test

# test and executable name
TB = test

# Source and testbench files
SRC_FILES = $(SRC_DIR)/intersection_controller.v \
            $(SRC_DIR)/adaptive_time_delay.v \
            $(SRC_DIR)/base_fsm.v \
            $(SRC_DIR)/pedestrian_light_controller.v \
            $(SRC_DIR)/pedestrian_timer_display.v

TB_FILE = $(TB_DIR)/testbench.v

# Default target
all: compile run

# Compile the testbench and source files
compile:
	iverilog -o $(TB) $(TB_FILE) $(SRC_FILES)

# Run the simulation
run:
	vvp $(TB)

# Clean up generated files
clean:
	rm -f $(TB) waveform.vcd

# Generate waveforms (optional)
waveform:
	iverilog -o $(TB) $(TB_FILE) $(SRC_FILES)
	vvp $(TB)
	gtkwave waveform.vcd