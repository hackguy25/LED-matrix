#!/bin/sh

# Compile a verilog file into a Gowin FPGA bitstream.

# Fail on error.
set -e

# Extract the name of the source file.
fname=$(echo $1 | cut -f 1 -d '.')
shift 1
echo "Compiling ${fname}.v..."

# Create the "target" directory, if it doesn't exist yet.
mkdir -p "target"

# Fail if a file exists that has the same name as the build directory.
if [ -f "target/${fname}" ]
then
    >&2 echo "Target dir is a file!!"
    exit 1
fi

# Create or empty out the build directory.
if [ -d "target/${fname}" ]
then
    rm -rf "target/${fname}/*"
    mkdir -p "target/${fname}"
else
    mkdir "target/${fname}"
fi

# Compile Verilog.
echo "Running yosys..."
yosys \
    -p "read_verilog ${fname}.v; synth_gowin -json target/${fname}/yosys_${fname}.json" \
    $@ \
    > "target/${fname}/yosys.log"

# Place and route the design.
echo "Running nextpnr..."
export LD_LIBRARY_PATH=/home/apicula/.pyenv/versions/3.12.3/lib
    nextpnr-himbaechel \
    --json "target/${fname}/yosys_${fname}.json" \
    --write "target/${fname}/pnr_${fname}.json" \
    --device "GW1NR-LV9QN88PC6/I5" \
    --vopt family=GW1N-9C \
    --vopt cst=tangnano9k.cst \
    2>&1 \
    | cat > "target/${fname}/nextpnr.log" # This is needed because nextpnr prints to stderr??

# Fail if nextpnr failed.
if [ ! -f "target/${fname}/pnr_${fname}.json" ]
then
    echo "Nextpnr failed, check \"target/${fname}/nextpnr.log\" for more details."
    exit 1
fi

# Pack the bitstream.
echo "Running gowin_pack..."
/home/apicula/.pyenv/shims/gowin_pack \
    -d GW1N-9C \
    -o "target/${fname}/pack.fs" \
    "target/${fname}/pnr_${fname}.json"

echo "Done compiling!"