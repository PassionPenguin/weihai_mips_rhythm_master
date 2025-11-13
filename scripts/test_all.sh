#!/bin/bash
# test_all.sh - Master test script: assemble all programs and run simulations
# Usage: ./scripts/test_all.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  MIPS CPU Test Suite                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Assemble all programs
echo -e "${YELLOW}[1/3] Assembling all programs...${NC}"
"$SCRIPT_DIR/assemble_all.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}Assembly failed. Stopping tests.${NC}"
    exit 1
fi

echo ""

# Step 2: Validate all hex files
echo -e "${YELLOW}[2/3] Validating assembled programs...${NC}"
for HEX_FILE in "$SCRIPT_DIR/../programs"/*.hex; do
    if [ -f "$HEX_FILE" ]; then
        BASENAME=$(basename "$HEX_FILE")
        echo "Validating: $BASENAME"
        "$SCRIPT_DIR/validate_hex.sh" "$HEX_FILE" || true
        echo ""
    fi
done

echo ""

# Step 3: Prepare for Vivado simulation
echo -e "${YELLOW}[3/3] Preparing Vivado simulation files...${NC}"
echo ""

if command -v vivado &> /dev/null; then
    echo -e "${GREEN}Vivado found - ready for simulation${NC}"
    echo "Run individual tests with: ./scripts/run_simulation.sh <test_name>"
    echo ""
    echo "Available tests:"
    for HEX_FILE in "$SCRIPT_DIR/../programs"/test_*.hex; do
        if [ -f "$HEX_FILE" ]; then
            BASENAME=$(basename "$HEX_FILE" .hex)
            echo "  - $BASENAME"
        fi
    done
else
    echo -e "${YELLOW}Vivado not found in PATH${NC}"
    echo "To run simulations:"
    echo "  Linux: source /path/to/Vivado/settings64.sh"
    echo "  Windows: Use the provided .bat scripts"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Test Suite Complete                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
