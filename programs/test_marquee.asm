# Test 1: LED Marquee (Running Light Pattern)
# Creates a moving LED pattern that shifts left
# Tests: arithmetic, shifts (emulated), branches, I/O

.text
.globl main

main:
    # Initialize I/O base address
    lui  $s0, 0xFFFF        # $s0 = 0xFFFF0000 (I/O base)
    
    # Initialize LED pattern - single bit lit
    addi $t0, $zero, 1      # Start with LED 0 lit (0x0001)
    
marquee_loop:
    # Display current pattern on LEDs
    sw   $t0, 0($s0)        # Write to LEDs at 0xFFFF0000
    
    # Delay loop (to make LED movement visible)
    addi $t1, $zero, 0      # Reset delay counter
delay:
    addi $t1, $t1, 1        # Increment delay counter
    addi $t2, $zero, 100    # Delay constant (adjust for speed)
    slt  $t3, $t1, $t2      # $t3 = ($t1 < 100) ? 1 : 0
    bne  $t3, $zero, delay  # Keep delaying if not done
    
    # Shift pattern left (multiply by 2)
    add  $t0, $t0, $t0      # $t0 = $t0 * 2 (shift left 1 bit)
    
    # Check if we've reached the end (bit 16 would overflow to 0x10000)
    addi $t4, $zero, 0      # Prepare to check upper bits
    lui  $t4, 0x0001        # $t4 = 0x00010000
    slt  $t5, $t0, $t4      # $t5 = ($t0 < 0x10000) ? 1 : 0
    bne  $t5, $zero, marquee_loop  # If still in range, continue
    
    # Reset to start position
    addi $t0, $zero, 1      # Reset to LED 0
    j    marquee_loop       # Restart marquee

# End of program
