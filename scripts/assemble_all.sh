#!/bin/bash
# assemble_all.sh - Assemble all test programs in the programs directory
# Usage: ./scripts/assemble_all.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROGRAMS_DIR="$PROJECT_ROOT/programs"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Assembling All Test Programs${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Find all .asm files
ASM_FILES=$(find "$PROGRAMS_DIR" -name "*.asm" -type f)

if [ -z "$ASM_FILES" ]; then
    echo -e "${RED}No .asm files found in $PROGRAMS_DIR${NC}"
    exit 1
fi

SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# Assemble each file
for ASM_FILE in $ASM_FILES; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    BASENAME=$(basename "$ASM_FILE")
    
    echo -e "${GREEN}[$TOTAL_COUNT] Assembling: $BASENAME${NC}"
    
    if "$SCRIPT_DIR/assemble.sh" "$ASM_FILE" 2>&1 | grep -q "successful"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "  ${GREEN}✓ Success${NC}"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo -e "  ${RED}✗ Failed${NC}"
    fi
    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "Summary: ${GREEN}$SUCCESS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC} (out of $TOTAL_COUNT)"
echo -e "${BLUE}========================================${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi
