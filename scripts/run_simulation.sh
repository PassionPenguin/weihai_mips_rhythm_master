#!/bin/bash
# run_simulation.sh - Run Verilog simulation with specified test program
# Usage: ./scripts/run_simulation.sh <test_name> [simulator]
# Simulators: iverilog (default), vivado

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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Running Simulation: $TEST_NAME${NC}"
echo -e "${BLUE}  Target: Basys3 (Vivado)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

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

# Copy hex file to expected location for simulation
cp "$HEX_FILE" "$PROJECT_ROOT/programs/simple_program.hex"
echo -e "${GREEN}Using program: $HEX_FILE${NC}"
echo ""

cd "$PROJECT_ROOT"

echo -e "${GREEN}Setting up Vivado simulation...${NC}"
echo ""

# Check if Vivado is available
if command -v vivado &> /dev/null; then
    echo -e "${GREEN}Vivado found, running automated simulation${NC}"
    
    # Run Vivado in batch mode with TCL script
    vivado -mode batch -source scripts/vivado_sim.tcl -tclargs "$TEST_NAME"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Simulation completed${NC}"
        echo "Check vivado_sim/ directory for results"
    else
        echo -e "${RED}✗ Simulation failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Vivado not found in PATH${NC}"
    echo ""
    echo "To run simulation manually:"
    echo "  1. Open Vivado"
    echo "  2. Tools → Run Tcl Script → scripts/vivado_sim.tcl"
    echo "  3. Or use the GUI:"
    echo "     - Create/open project"
    echo "     - Add all .v files as sources"
    echo "     - Add testbench.v as simulation source"
    echo "     - Run behavioral simulation"
    echo ""
    echo "The program file is ready at: programs/simple_program.hex"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Simulation complete for: $TEST_NAME${NC}"
echo -e "${BLUE}========================================${NC}"
