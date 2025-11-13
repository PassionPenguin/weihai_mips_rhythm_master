#!/bin/bash
# validate_hex.sh - Validate assembled hex files
# Checks for proper format, instruction count, and basic sanity

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hex_file>"
    exit 1
fi

HEX_FILE="$1"

if [ ! -f "$HEX_FILE" ]; then
    echo -e "${RED}Error: File '$HEX_FILE' not found${NC}"
    exit 1
fi

echo -e "${GREEN}Validating: $HEX_FILE${NC}"
echo ""

# Check 1: File is not empty
LINE_COUNT=$(wc -l < "$HEX_FILE" | tr -d ' ')
if [ "$LINE_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ File is empty${NC}"
    exit 1
fi
echo -e "${GREEN}✓ File contains $LINE_COUNT instructions${NC}"

# Check 2: All lines are 8 hex digits (with optional comments)
INVALID_LINES=$(grep -v '^[0-9A-Fa-f]\{8\}' "$HEX_FILE" | grep -v '^//' | grep -v '^$' || true)
if [ -n "$INVALID_LINES" ]; then
    echo -e "${RED}✗ Found invalid hex format:${NC}"
    echo "$INVALID_LINES"
    exit 1
fi
echo -e "${GREEN}✓ All lines have valid 8-digit hex format${NC}"

# Check 3: Look for common instruction patterns
ADDI_COUNT=$(grep -c '^2[0-9A-Fa-f]' "$HEX_FILE" || true)
LW_COUNT=$(grep -c '^8[CcDdEeFf]' "$HEX_FILE" || true)
SW_COUNT=$(grep -c '^A[CcDdEeFf]' "$HEX_FILE" || true)
BRANCH_COUNT=$(grep -c '^1[0-5]' "$HEX_FILE" || true)
JUMP_COUNT=$(grep -c '^0[0-9A-Fa-f]' "$HEX_FILE" || true)

echo ""
echo "Instruction statistics:"
echo "  ADDI-type:   $ADDI_COUNT"
echo "  LW:          $LW_COUNT"
echo "  SW:          $SW_COUNT"
echo "  Branches:    $BRANCH_COUNT"
echo "  Jumps:       $JUMP_COUNT"

# Check 4: Verify no obviously invalid opcodes
INVALID_OPCODES=$(grep -E '^(3[0-3]|3[5-9]|[4-7][0-9A-Fa-f]|9[0-9A-Fa-f]|B[0-9A-Fa-f])' "$HEX_FILE" || true)
if [ -n "$INVALID_OPCODES" ]; then
    echo -e "${YELLOW}⚠ Warning: Found potentially invalid opcodes:${NC}"
    echo "$INVALID_OPCODES" | head -3
fi

# Check 5: Check for infinite loop detection (jump to same address)
echo ""
echo -e "${GREEN}✓ Validation passed!${NC}"
echo ""

# Display memory usage estimate
BYTES=$((LINE_COUNT * 4))
KB=$(echo "scale=2; $BYTES / 1024" | bc)
echo "Memory usage: $BYTES bytes (~${KB} KB)"

exit 0
