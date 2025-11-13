# Simple test program for MIPS CPU
# Tests basic instructions and I/O
# Assemble this to programs/simple_program.hex

.text
.globl main

main:
    # Initialize: Set all registers to known values
    addi $t0, $zero, 0      # $t0 = 0
    addi $t1, $zero, 1      # $t1 = 1
    addi $t2, $zero, 5      # $t2 = 5
    
    # Test arithmetic
    add  $t3, $t1, $t2      # $t3 = 1 + 5 = 6
    sub  $t4, $t3, $t1      # $t4 = 6 - 1 = 5
    
    # Test logic operations
    ori  $t5, $zero, 0x00FF # $t5 = 0x00FF
    and  $t6, $t5, $t2      # $t6 = 0x00FF & 5 = 5
    
    # Load upper immediate for I/O addresses
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base address)
    
loop:
    # Read switches
    lw   $t7, 4($s0)        # Read from 0xFFFF0004 (switches)
    
    # Simple logic: Copy switches to LEDs
    sw   $t7, 0($s0)        # Write to 0xFFFF0000 (LEDs)
    
    # Read buttons
    lw   $t8, 8($s0)        # Read from 0xFFFF0008 (buttons)
    
    # Display button state on 7-segment
    sw   $t8, 12($s0)       # Write to 0xFFFF000C (7-seg data)
    
    # Simple counter for 7-segment display
    addi $t0, $t0, 1        # Increment counter
    
    # Branch: if counter < 10, continue
    addi $t9, $zero, 10     # $t9 = 10
    slt  $t9, $t0, $t9      # $t9 = ($t0 < 10) ? 1 : 0
    bne  $t9, $zero, loop   # If $t9 != 0, goto loop
    
    # Reset counter
    addi $t0, $zero, 0      # $t0 = 0
    j    loop               # Jump back to loop

# End of program
