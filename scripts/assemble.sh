#!/bin/bash
# assemble.sh - Automated assembly script using weihai_mips_assembler
# Usage: ./scripts/assemble.sh <input.asm> [output.hex]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSEMBLER_DIR="$PROJECT_ROOT/assembler"

# Check if assembler exists
if [ ! -d "$ASSEMBLER_DIR" ]; then
    echo -e "${RED}Error: Assembler directory not found at $ASSEMBLER_DIR${NC}"
    echo "Please clone the assembler:"
    echo "  git clone https://github.com/PassionPenguin/weihai_mips_assembler.git assembler"
    exit 1
fi

# Check if assembler is built
if [ ! -f "$ASSEMBLER_DIR/target/release/weihai_mips_assembler" ] && [ ! -f "$ASSEMBLER_DIR/target/debug/weihai_mips_assembler" ]; then
    echo -e "${YELLOW}Building assembler...${NC}"
    cd "$ASSEMBLER_DIR"
    cargo build --release
    cd "$PROJECT_ROOT"
fi

# Determine assembler binary path
if [ -f "$ASSEMBLER_DIR/target/release/weihai_mips_assembler" ]; then
    ASSEMBLER="$ASSEMBLER_DIR/target/release/weihai_mips_assembler"
else
    ASSEMBLER="$ASSEMBLER_DIR/target/debug/weihai_mips_assembler"
fi

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.asm> [output.hex]"
    echo ""
    echo "Examples:"
    echo "  $0 programs/test_memory.asm"
    echo "  $0 programs/test_marquee.asm programs/custom_output.hex"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.asm}.hex}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file '$INPUT_FILE' not found${NC}"
    exit 1
fi

echo -e "${GREEN}Assembling: $INPUT_FILE${NC}"
echo "Output: $OUTPUT_FILE"

# Run assembler
if $ASSEMBLER "$INPUT_FILE" -o "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ Assembly successful!${NC}"
    
    # Show file size
    SIZE=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    echo "  Generated $SIZE lines of machine code"
    
    # Show first few instructions
    echo ""
    echo "First 5 instructions:"
    head -5 "$OUTPUT_FILE" | nl -v 0 -w 4 -s ': '
    
    exit 0
else
    echo -e "${RED}✗ Assembly failed!${NC}"
    exit 1
fi
