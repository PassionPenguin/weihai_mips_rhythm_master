#!/bin/bash
# compare_hex.sh - Compare two hex files and show differences
# Useful for debugging assembler output vs hand-assembled code

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 2 ]; then
    echo "Usage: $0 <file1.hex> <file2.hex>"
    exit 1
fi

FILE1="$1"
FILE2="$2"

if [ ! -f "$FILE1" ]; then
    echo -e "${RED}Error: $FILE1 not found${NC}"
    exit 1
fi

if [ ! -f "$FILE2" ]; then
    echo -e "${RED}Error: $FILE2 not found${NC}"
    exit 1
fi

echo -e "${GREEN}Comparing:${NC}"
echo "  File 1: $FILE1"
echo "  File 2: $FILE2"
echo ""

# Strip comments and empty lines for comparison
clean_hex() {
    grep '^[0-9A-Fa-f]\{8\}' "$1" | tr '[:lower:]' '[:upper:]'
}

CLEAN1=$(mktemp)
CLEAN2=$(mktemp)
clean_hex "$FILE1" > "$CLEAN1"
clean_hex "$FILE2" > "$CLEAN2"

# Compare line counts
LINES1=$(wc -l < "$CLEAN1" | tr -d ' ')
LINES2=$(wc -l < "$CLEAN2" | tr -d ' ')

if [ "$LINES1" -ne "$LINES2" ]; then
    echo -e "${YELLOW}⚠ Line count mismatch: $LINES1 vs $LINES2${NC}"
fi

# Perform diff
if diff -q "$CLEAN1" "$CLEAN2" > /dev/null; then
    echo -e "${GREEN}✓ Files are identical${NC}"
    rm "$CLEAN1" "$CLEAN2"
    exit 0
else
    echo -e "${RED}✗ Files differ:${NC}"
    echo ""
    diff -y --suppress-common-lines "$CLEAN1" "$CLEAN2" | head -20
    echo ""
    
    DIFF_COUNT=$(diff "$CLEAN1" "$CLEAN2" | grep '^<' | wc -l)
    echo -e "${RED}Total differences: $DIFF_COUNT lines${NC}"
    
    rm "$CLEAN1" "$CLEAN2"
    exit 1
fi
