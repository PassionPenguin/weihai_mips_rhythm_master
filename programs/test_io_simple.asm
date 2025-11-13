# Simple I/O Test Program
# Tests basic LED write functionality
# Expected: LEDs should show 0xAAAA (alternating pattern)

.text
.globl main

main:
    # Initialize I/O base address
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base address)
    
    # Test 1: Write pattern to LEDs
    addi $t0, $zero, 0xAA   # Load pattern 0x000000AA
    sw   $t0, 0($s0)        # Write to LEDs at 0xFFFF0000
    
    # Small delay loop
    addi $t1, $zero, 0      # Counter = 0
delay_loop:
    addi $t1, $t1, 1        # Increment counter
    addi $t2, $zero, 100    # Load comparison value
    slt  $t3, $t1, $t2      # Check if counter < 100
    bne  $t3, $zero, delay_loop  # Continue if not done
    
    # Test 2: Write different pattern
    addi $t0, $zero, 0x55   # Load pattern 0x00000055
    sw   $t0, 0($s0)        # Write to LEDs
    
    # Another delay
    addi $t1, $zero, 0      # Reset counter
delay_loop2:
    addi $t1, $t1, 1        # Increment counter
    addi $t2, $zero, 100    # Load comparison value
    slt  $t3, $t1, $t2      # Check if counter < 100
    bne  $t3, $zero, delay_loop2  # Continue if not done
    
    # Test 3: Write maximum pattern
    addi $t0, $zero, 0xFF   # Load pattern 0x000000FF
    sw   $t0, 0($s0)        # Write to LEDs
    
    # Infinite loop
infinite:
    j    infinite           # Stay here forever
