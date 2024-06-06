#!/bin/sh

# Compile a verilog file into a Gowin FPGA bitstream, and flash it.

# Fail on error.
set -e

# Source the compilation script.
. $(dirname "$0")/compile.sh

# Flash the FPGA.
echo "Flashing..."
openFPGALoader -b tangnano9k "target/${fname}/pack.fs" > "target/${fname}/flasher.log"

echo "Done flashing!"