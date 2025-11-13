# Test 3: Memory Store and Fetch Test
# Writes a sequence to RAM, reads it back, verifies correctness
# Tests: lw, sw, memory operations, address calculation

.text
.globl main

main:
    # Initialize I/O base
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base)
    
    # Initialize memory base address (use low RAM area)
    addi $s1, $zero, 0x0100 # $s1 = 0x00000100 (start of test data)
    
    # Test pattern 1: Store sequential values
    addi $t0, $zero, 0xAA   # Value 1
    sw   $t0, 0($s1)        # Store at 0x0100
    
    addi $t0, $zero, 0xBB   # Value 2
    sw   $t0, 4($s1)        # Store at 0x0104
    
    addi $t0, $zero, 0xCC   # Value 3
    sw   $t0, 8($s1)        # Store at 0x0108
    
    addi $t0, $zero, 0xDD   # Value 4
    sw   $t0, 12($s1)       # Store at 0x010C
    
    # Display success pattern on LEDs (all stored)
    addi $t0, $zero, 0x0F   # 4 bits lit
    sw   $t0, 0($s0)        # Write to LEDs
    
    # Small delay
    addi $t1, $zero, 0
delay1:
    addi $t1, $t1, 1
    addi $t2, $zero, 200
    slt  $t2, $t1, $t2
    bne  $t2, $zero, delay1
    
    # Now read back and verify
    # Read value 1
    lw   $t0, 0($s1)        # Load from 0x0100
    addi $t3, $zero, 0xAA   # Expected value
    sub  $t4, $t0, $t3      # Should be 0 if match
    bne  $t4, $zero, error  # If not zero, error
    
    # Read value 2
    lw   $t0, 4($s1)        # Load from 0x0104
    addi $t3, $zero, 0xBB   # Expected value
    sub  $t4, $t0, $t3
    bne  $t4, $zero, error
    
    # Read value 3
    lw   $t0, 8($s1)        # Load from 0x0108
    addi $t3, $zero, 0xCC   # Expected value
    sub  $t4, $t0, $t3
    bne  $t4, $zero, error
    
    # Read value 4
    lw   $t0, 12($s1)       # Load from 0x010C
    addi $t3, $zero, 0xDD   # Expected value
    sub  $t4, $t0, $t3
    bne  $t4, $zero, error
    
    # All values matched! Show success pattern
success:
    addi $t0, $zero, 0      # LED pattern counter
success_loop:
    sw   $t0, 0($s0)        # Display counter on LEDs
    addi $t0, $t0, 1        # Increment
    
    # Wrap at 256
    addi $t5, $zero, 0
    lui  $t5, 0x0001        # $t5 = 0x00010000
    slt  $t6, $t0, $t5
    bne  $t6, $zero, success_delay
    addi $t0, $zero, 0      # Reset counter
    
success_delay:
    addi $t1, $zero, 0
sd_loop:
    addi $t1, $t1, 1
    addi $t2, $zero, 100
    slt  $t2, $t1, $t2
    bne  $t2, $zero, sd_loop
    j    success_loop
    
error:
    # Show error pattern - alternating pattern
    addi $t0, $zero, 0x5555 # Alternating 0101...
    sw   $t0, 0($s0)        # Write to LEDs
    
error_loop:
    # Blink the error pattern
    addi $t1, $zero, 0
err_delay:
    addi $t1, $t1, 1
    addi $t2, $zero, 200
    slt  $t2, $t1, $t2
    bne  $t2, $zero, err_delay
    
    # Toggle pattern
    addi $t3, $zero, 0xAAAA # Alternating 1010...
    sw   $t3, 0($s0)
    
    addi $t1, $zero, 0
err_delay2:
    addi $t1, $t1, 1
    addi $t2, $zero, 200
    slt  $t2, $t1, $t2
    bne  $t2, $zero, err_delay2
    
    j    error

# End of program
