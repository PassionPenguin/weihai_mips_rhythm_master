#!/bin/bash
# sim_iverilog.sh - Fast local simulation using Icarus Verilog
# Usage: ./scripts/sim_iverilog.sh <test_name> [duration]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
TEST_NAME="${1:-test_memory}"
DURATION="${2:-50us}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Icarus Verilog Simulation${NC}"
echo -e "${BLUE}  Test: $TEST_NAME${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if iverilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}Error: iverilog not found${NC}"
    echo "Install with: brew install icarus-verilog"
    exit 1
fi

# Find the hex file
HEX_FILE="$PROJECT_ROOT/programs/${TEST_NAME}.hex"
if [ ! -f "$HEX_FILE" ]; then
    echo -e "${YELLOW}Hex file not found, attempting to assemble...${NC}"
    ASM_FILE="$PROJECT_ROOT/programs/${TEST_NAME}.asm"
    
    if [ ! -f "$ASM_FILE" ]; then
        echo -e "${RED}Error: Neither .hex nor .asm file found for '$TEST_NAME'${NC}"
        exit 1
    fi
    
    "$SCRIPT_DIR/assemble.sh" "$ASM_FILE"
fi

# Copy hex file to expected location
cp "$HEX_FILE" "$PROJECT_ROOT/programs/simple_program.hex"
echo -e "${GREEN}Using program: $HEX_FILE${NC}"
echo ""

# Create sim directory and programs subdirectory
mkdir -p "$PROJECT_ROOT/sim_iverilog/programs"
cd "$PROJECT_ROOT"

# Copy hex file to sim directory for $readmemh
cp "$PROJECT_ROOT/programs/simple_program.hex" "$PROJECT_ROOT/sim_iverilog/programs/"

echo -e "${GREEN}Compiling with Icarus Verilog...${NC}"

# Compile all Verilog files
iverilog -g2012 -o sim_iverilog/cpu_sim \
    -s testbench \
    testbench.v \
    mips32.v \
    controller.v \
    datapath.v \
    alucontrol.v \
    exmemory.v \
    cpu_modules/alu.v \
    cpu_modules/flop.v \
    cpu_modules/mux.v \
    cpu_modules/regfile.v \
    cpu_modules/zerodetect.v

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Compilation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Compilation successful${NC}"
echo ""
echo -e "${GREEN}Running simulation for $DURATION...${NC}"
echo ""

# Run simulation
cd sim_iverilog
vvp cpu_sim

SIM_RESULT=$?

if [ $SIM_RESULT -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Simulation completed${NC}"
    
    # Check if VCD file was generated
    if [ -f "cpu_sim.vcd" ]; then
        echo -e "${GREEN}Waveform saved to: sim_iverilog/cpu_sim.vcd${NC}"
        echo ""
        echo "View waveform with:"
        echo "  gtkwave sim_iverilog/cpu_sim.vcd"
    fi
else
    echo -e "${RED}✗ Simulation failed with exit code $SIM_RESULT${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Simulation complete for: $TEST_NAME${NC}"
echo -e "${BLUE}========================================${NC}"

exit 0
