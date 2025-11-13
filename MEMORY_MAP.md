# MIPS CPU Memory Map Documentation

## Overview
This document defines the complete memory address space for the MIPS CPU system, including RAM and memory-mapped I/O devices for the Basys3 FPGA board.

## Memory Address Space Layout

### RAM Region: 0x0000_0000 - 0x0000_FFFF (64KB)
- **Base Address:** `0x00000000`
- **End Address:** `0x0000FFFF`
- **Size:** 64KB (16,384 words of 32 bits)
- **Access:** Read/Write
- **Word Addressing:** Address bits [15:2] select word, bits [1:0] should be 00 for word-aligned access

### I/O Region: 0xFFFF_0000 - 0xFFFF_00FF (256 bytes)
All I/O devices are memory-mapped to high addresses starting at `0xFFFF0000`.

## Memory-Mapped I/O Devices

### 1. LED Register (16 LEDs)
- **Address:** `0xFFFF0000`
- **Width:** 32-bit register (only lower 16 bits used)
- **Access:** Write-only
- **Bits Used:** [15:0]
- **Bits Unused:** [31:16] - ignored
- **Hardware:** Basys3 board has 16 discrete LEDs
- **Usage Example:**
  ```asm
  lui  $s0, 0xFFFF        # Load I/O base (0xFFFF0000)
  addi $t0, $zero, 0xFF   # Pattern: 0x000000FF
  sw   $t0, 0($s0)        # Write to LEDs at 0xFFFF0000
  ```

### 2. Switch Register (16 Switches)
- **Address:** `0xFFFF0004`
- **Width:** 32-bit register (only lower 16 bits used)
- **Access:** Read-only
- **Bits Used:** [15:0]
- **Bits Unused:** [31:16] - read as 0
- **Hardware:** Basys3 board has 16 slide switches
- **Usage Example:**
  ```asm
  lui  $s0, 0xFFFF        # Load I/O base
  lw   $t0, 4($s0)        # Read switches from 0xFFFF0004
  andi $t0, $t0, 0xFFFF   # Mask to 16 bits (optional)
  ```

### 3. Button Register (5 Buttons)
- **Address:** `0xFFFF0008`
- **Width:** 32-bit register (only lower 5 bits used)
- **Access:** Read-only
- **Bits Used:** [4:0]
- **Bits Unused:** [31:5] - read as 0
- **Hardware:** Basys3 board has 5 push buttons (Center, Up, Down, Left, Right)
- **Bit Mapping:**
  - Bit 0: Center button
  - Bit 1: Up button
  - Bit 2: Down button
  - Bit 3: Left button
  - Bit 4: Right button
- **Usage Example:**
  ```asm
  lui  $s0, 0xFFFF        # Load I/O base
  lw   $t0, 8($s0)        # Read buttons from 0xFFFF0008
  andi $t1, $t0, 0x01     # Check center button
  ```

### 4. Seven-Segment Display Data Register
- **Address:** `0xFFFF000C`
- **Width:** 32-bit register (only lower 16 bits used)
- **Access:** Write-only
- **Bits Used:** [15:0]
- **Bits Unused:** [31:16] - ignored
- **Hardware:** 4-digit 7-segment display
- **Format:** Each nibble controls one digit in hexadecimal
  - Bits [3:0]: Rightmost digit (digit 0)
  - Bits [7:4]: Digit 1
  - Bits [11:8]: Digit 2
  - Bits [15:12]: Leftmost digit (digit 3)
- **Usage Example:**
  ```asm
  lui  $s0, 0xFFFF        # Load I/O base
  addi $t0, $zero, 0x1234 # Value to display: 1234 in hex
  sw   $t0, 12($s0)       # Write to 7-seg data at 0xFFFF000C
  addi $t1, $zero, 0x0F   # Enable all 4 digits
  sw   $t1, 16($s0)       # Write to 7-seg anode at 0xFFFF0010
  ```

### 5. Seven-Segment Display Anode Control Register
- **Address:** `0xFFFF0010`
- **Width:** 32-bit register (only lower 4 bits used)
- **Access:** Write-only
- **Bits Used:** [3:0]
- **Bits Unused:** [31:4] - ignored
- **Hardware:** Controls which digits are active (active LOW)
- **Bit Mapping:**
  - Bit 0: Anode for digit 0 (rightmost) - 0=ON, 1=OFF
  - Bit 1: Anode for digit 1 - 0=ON, 1=OFF
  - Bit 2: Anode for digit 2 - 0=ON, 1=OFF
  - Bit 3: Anode for digit 3 (leftmost) - 0=ON, 1=OFF
- **Default:** `0x0` (all digits ON)
- **Usage Example:**
  ```asm
  addi $t0, $zero, 0x03   # Turn off digits 0,1 (bits 0,1 = 1)
  sw   $t0, 16($s0)       # Only digits 2,3 will be visible
  ```

## Address Decoding Rules

### For Software (Assembly Programming)
1. **Initialize I/O base pointer:**
   ```asm
   lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000
   ```

2. **Access I/O devices using offsets:**
   ```asm
   sw   $t0, 0($s0)        # Write to LEDs (0xFFFF0000)
   lw   $t1, 4($s0)        # Read from Switches (0xFFFF0004)
   lw   $t2, 8($s0)        # Read from Buttons (0xFFFF0008)
   sw   $t3, 12($s0)       # Write to 7-seg data (0xFFFF000C)
   sw   $t4, 16($s0)       # Write to 7-seg anode (0xFFFF0010)
   ```

### For Hardware (Verilog Implementation)
The `exmemory.v` module decodes addresses as follows:

```verilog
// Address constants
parameter ADDR_LEDS       = 32'hFFFF0000;
parameter ADDR_SWITCHES   = 32'hFFFF0004;
parameter ADDR_BUTTONS    = 32'hFFFF0008;
parameter ADDR_7SEG_DATA  = 32'hFFFF000C;
parameter ADDR_7SEG_AN    = 32'hFFFF0010;

// RAM range check
if (addr < 32'h00010000)  // addr in [0x0000_0000, 0x0000_FFFF]
    // Access RAM
else if (addr == ADDR_LEDS)
    // Write to LED register
else if (addr == ADDR_SWITCHES)
    // Read from switch inputs
// ... etc
```

## Register File Conventions

### Recommended I/O Base Register
- **Register:** `$s0` (register 16)
- **Value:** `0xFFFF0000`
- **Initialization:** `lui $s0, 0xFFFF`
- **Rationale:** Saved register, preserved across function calls

### Temporary Registers for I/O Operations
- `$t0-$t7` (registers 8-15): Use for I/O data transfer
- `$v0-$v1` (registers 2-3): Use for return values from I/O reads

## Important Notes

### Word Alignment
- All memory accesses must be word-aligned (addresses must be multiples of 4)
- The CPU uses byte addressing but accesses full 32-bit words
- Non-aligned accesses are undefined behavior

### Address Bit Width
- Full address bus is 32 bits
- RAM only decodes lower 16 bits (addr[15:0])
- I/O devices use full 32-bit address comparison

### Endianness
- System uses **little-endian** byte ordering
- When storing multi-byte values, least significant byte is at lowest address

### Reset Behavior
- All I/O registers reset to 0 on system reset
- RAM contents are undefined on reset (initialized to 0 in simulation)

## Testing Checklist

When testing I/O operations, verify:
- ✅ LED register writes change LED outputs
- ✅ Switch register reads return current switch positions
- ✅ Button register reads return current button states
- ✅ 7-segment data writes appear on display
- ✅ 7-segment anode control enables/disables digits correctly
- ✅ RAM read/write operations work independently of I/O
- ✅ Address decoding separates RAM from I/O correctly

## Example Program Structure

```asm
# Initialization
.text
.globl main

main:
    # Set up I/O base pointer
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base)
    
    # Set up RAM base for data storage
    addi $s1, $zero, 0x0100 # $s1 = 0x00000100 (RAM data area)
    
    # Example: Read switches, write to LEDs
loop:
    lw   $t0, 4($s0)        # Read switches
    sw   $t0, 0($s0)        # Echo to LEDs
    j    loop               # Repeat forever
```

## Revision History
- **Version 1.0** (2025-11-13): Initial memory map definition
