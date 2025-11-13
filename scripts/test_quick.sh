#!/bin/bash
# test_quick.sh - Quick test with iverilog (for development iteration)
# Usage: ./scripts/test_quick.sh [test_name]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_NAME="${1:-test_memory}"

echo "╔════════════════════════════════════════╗"
echo "║  Quick Test with Icarus Verilog        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Step 1: Assemble if needed
if [ ! -f "$SCRIPT_DIR/../programs/${TEST_NAME}.hex" ]; then
    echo "[1/2] Assembling $TEST_NAME..."
    "$SCRIPT_DIR/assemble.sh" "$SCRIPT_DIR/../programs/${TEST_NAME}.asm"
else
    echo "[1/2] Using existing hex file"
fi

echo ""

# Step 2: Simulate
echo "[2/2] Running simulation..."
"$SCRIPT_DIR/sim_iverilog.sh" "$TEST_NAME"

echo ""
echo "✓ Quick test complete!"
