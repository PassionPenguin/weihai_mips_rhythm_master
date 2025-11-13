# Rhythm Master Game - Assembly Implementation
#
# Registers:
# $t0 (8): game_state (0: IDLE, 1: MENU, 2: GAME)
# $t1 (9): score
# $t2 (10): temporary for button/switch input
# $t3 (11): temporary for LED output value
# $t4 (12): timer/counter for delays
# $t5 (13): random number for LED selection
# $ra (31): return address for subroutines
#
# Memory-Mapped I/O Addresses:
# 0xFFFF0000: Switches input
# 0xFFFF0004: Buttons input
# 0xFFFF0008: LEDs output
# 0xFFFF000C: 7-segment display output

.data
SWITCH_ADDR: .word 0xFFFF0000
BTN_ADDR:    .word 0xFFFF0004
LED_ADDR:    .word 0xFFFF0008
SEG_ADDR:    .word 0xFFFF000C
OVER_MSG:    .word 0xDEADBEEF  # Placeholder for "over" display pattern

.text
.globl main
main:
    # Initialize game state
    ori $t0, $zero, 0       # game_state = IDLE
    ori $t1, $zero, 0       # score = 0

main_loop:
    # Load switch state
    lui $s0, 0xFFFF
    lw $t2, 0($s0)          # lw $t2, SWITCH_ADDR

    # Check switch value to transition from IDLE to MENU
    beq $t0, $zero, check_switch_for_menu
    # If not in IDLE state, jump to the correct state handler
    beq $t0, 1, menu_state
    beq $t0, 2, game_state
    j main_loop

check_switch_for_menu:
    andi $t2, $t2, 0x1      # Check only the first switch
    beq $t2, 1, to_menu     # If switch == 1, go to MENU
    j idle_state            # Otherwise, stay in IDLE

idle_state:
    # IDLE state: can show records, etc. (not implemented)
    # For now, just loop and check switches
    j main_loop

to_menu:
    ori $t0, $zero, 1       # game_state = MENU
menu_state:
    # MENU state: wait for a button press to start the game
    lw $t2, 4($s0)          # lw $t2, BTN_ADDR
    bne $t2, $zero, to_game # If any button is pressed, start game
    j menu_state

to_game:
    ori $t0, $zero, 2       # game_state = GAME
    ori $t1, $zero, 0       # Reset score
game_state:
    # --- Core Game Logic ---
    # 1. Generate a random LED to light up
    # (Pseudo-random for now, just cycle through them)
    addi $t5, $t5, 1
    andi $t5, $t5, 0x7      # Cycle through 0-4 for 5 LEDs
    
    # 2. Light up the LED
    ori $t3, $zero, 1
    sllv $t3, $t3, $t5      # Shift 1 to the correct LED position
    sw $t3, 8($s0)          # sw $t3, LED_ADDR

    # 3. Start a timer (delay loop)
    ori $t4, $zero, 1000    # Load timer counter
delay_loop:
    addi $t4, $t4, -1
    bne $t4, $zero, delay_loop

    # 4. Check for button press within the time
    lw $t2, 4($s0)          # Read buttons

    # 5. Compare button with the lit LED
    # (Assuming button bits correspond to LED bits)
    beq $t2, $t3, correct_press
    # If no correct press, it's a fail
    j fail_press

correct_press:
    # Turn off LED
    sw $zero, 8($s0)
    # Loop back to generate next LED
    j game_state

fail_press:
    # Increment score
    addi $t1, $t1, 1
    # Turn off LED
    sw $zero, 8($s0)

    # Check if score is 3
    slti $at, $t1, 3
    bne $at, $zero, game_state # if score < 3, continue game

game_over:
    # Display "over" on 7-segment
    lw $t3, OVER_MSG
    sw $t3, 12($s0)         # sw $t3, SEG_ADDR
    # Game ends, loop here forever
    j game_over

