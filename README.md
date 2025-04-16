# Traffic Light Controller FPGA Design

## Overview

This project implements a traffic light controller for a 2-way intersection using FPGA. The controller utilizes a finite state machine (FSM) to handle the timing and state transitions for the traffic lights (North-South and East-West).

## Requirements

- **FPGA Board:** [FPGA model]
- **Clock Frequency:** 50 MHz (default, configurable)
- **Tools:** QuestaSim

## Files

- `src/`: Verilog source code for the traffic light controller.
- `testbench/`: Testbench and simulation files.
- `docs/`: Documentation including design specifications and user manual.
- `constraints/`: FPGA constraints file for pin assignments and clock setup.
- `scripts/`: Setup and automation scripts.

## How to Compile and Simulate

1. Clone this repository.
2. Compile the design using the provided `Makefile`.
3. Run the simulation using `run_simulation.sh`.

## How to Deploy to FPGA

1. Configure your FPGA toolchain (e.g., Vivado).
2. Program the FPGA with the generated bitstream file.

## License

This project is licensed under the MIT-License.
