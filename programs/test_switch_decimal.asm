# Test 2: Switch to Decimal Display
# Reads 4 switches as binary, calculates decimal value, displays on LEDs and 7-segment
# Tests: lw, sw, arithmetic operations, I/O

.text
.globl main

main:
    # Initialize I/O base address
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base)
    
read_loop:
    # Read switch state
    lw   $t0, 4($s0)        # Read from 0xFFFF0004 (switches)
    
    # Mask to get only lower 4 bits (switches 0-3)
    addi $t1, $zero, 15     # $t1 = 0x0F (mask for 4 bits)
    and  $t2, $t0, $t1      # $t2 = lower 4 bits of switches
    
    # Display raw binary on LEDs
    sw   $t2, 0($s0)        # Write to 0xFFFF0000 (LEDs)
    
    # Convert to decimal representation for 7-segment
    # For 0-15, we'll create a simple lookup or calculation
    # Since we're limited, let's display the hex value directly
    # (A real conversion would need division by 10)
    
    # Calculate tens digit (value / 10)
    addi $t3, $zero, 10     # Divisor = 10
    addi $t4, $zero, 0      # Quotient (tens) = 0
    add  $t5, $zero, $t2    # Dividend = input value
    
divide_loop:
    slt  $t6, $t5, $t3      # Is dividend < 10?
    bne  $t6, $zero, divide_done  # If yes, done
    sub  $t5, $t5, $t3      # dividend -= 10
    addi $t4, $t4, 1        # quotient++
    j    divide_loop
    
divide_done:
    # Now $t4 = tens digit, $t5 = ones digit
    # Pack into display format: tens in upper nibble, ones in lower
    add  $t6, $t4, $t4      # $t6 = tens * 2
    add  $t6, $t6, $t6      # $t6 = tens * 4
    add  $t6, $t6, $t6      # $t6 = tens * 8
    add  $t6, $t6, $t6      # $t6 = tens * 16 (shift left 4)
    add  $t7, $t6, $t5      # Combine tens and ones
    
    # Display on 7-segment
    sw   $t7, 12($s0)       # Write to 0xFFFF000C (7-seg data)
    
    # Small delay
    addi $t8, $zero, 0      # Reset delay counter
delay:
    addi $t8, $t8, 1
    addi $t9, $zero, 50     # Delay constant
    slt  $t9, $t8, $t9
    bne  $t9, $zero, delay
    
    # Repeat
    j    read_loop

# End of program
