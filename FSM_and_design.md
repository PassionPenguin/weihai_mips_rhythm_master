# FSM and Design for MIPS CPU

This document outlines the design of the multi-cycle MIPS CPU controller's Finite State Machine (FSM) and the rationale for the selected instruction set based on the "Rhythm Master" game requirements.

## 1. Game Logic & State Analysis

Based on the provided diagrams, the application has three main states:
1.  **Score Check (`IDLE`)**: The initial state. Allows viewing past scores.
2.  **Game Menu (`MENU`)**: A pre-game state, entered when `switch=1`. Pressing a button starts the game.
3.  **Rhythm Master (`GAME`)**: The core gameplay state.

The game logic requires the following operations:
-   **State Transitions**: Switching between `IDLE`, `MENU`, and `GAME`.
-   **I/O Operations**:
    -   Reading from switches (to select game mode and speed).
    -   Reading from buttons (player input).
    -   Writing to LEDs (to show the random light).
    -   Writing to a 7-segment display (to show score or "over").
-   **Game Variables**:
    -   `score`: Tracks deducted points.
    -   `random_led`: Stores which LED is currently lit.
    -   `game_state`: The current state of the application FSM.
-   **Control Flow**:
    -   Conditional branches (e.g., `if (button_pressed == correct_button)`).
    -   Unconditional jumps (for state transitions).
    -   Loops (for the main game loop).
-   **Timers**: The logic implies timers for how long an LED stays lit. This can be implemented with delay loops in software.

## 2. Controller FSM Design

The CPU's controller will use a multi-cycle FSM to execute one instruction over several clock cycles. The states are based on the classic MIPS multi-cycle design.

-   **State 0: `FETCH`**:
    -   `MemRead <= 1`, `IRWrite <= 1` (Fetch 32-bit instruction).
    -   `ALUSrcA <= 0`, `ALUSrcB <= 1`, `ALUOp <= 0` (Calculate PC + 4).
    -   `PCWrite <= 1`.
    -   Next state: `DECODE`.

-   **State 1: `DECODE`**:
    -   Decode instruction in `IR`.
    -   `ALUSrcA <= 0`, `ALUSrcB <= 3` (prepare for branch offset calculation).
    -   Based on `Opcode`, transition to the appropriate execution state path.
        -   `Op=R-type` -> `R_EXECUTE`
        -   `Op=lw/sw` -> `MEM_ADDR_COMP`
        -   `Op=beq/bne` -> `BRANCH_COMP`
        -   `Op=j` -> `JUMP_EXECUTE`
        -   `Op=addi/ori` -> `I_EXECUTE`

-   **State 2: `MEM_ADDR_COMP`** (for `lw`, `sw`):
    -   `ALUSrcA <= 1`, `ALUSrcB <= 2` (calculate `rs + sign_extended_immediate`).
    -   `ALUOp <= 0` (add).
    -   If `lw`, next state is `LW_READ`.
    -   If `sw`, next state is `SW_WRITE`.

-   **State 3: `LW_READ`**:
    -   `MemRead <= 1`, `IorD <= 1` (read from data memory at address in `ALUOut`).
    -   Next state: `LW_WRITEBACK`.

-   **State 4: `LW_WRITEBACK`**:
    -   `RegWrite <= 1`, `MemToReg <= 1`, `RegDst <= 0` (write `MDR` to `rt`).
    -   Next state: `FETCH`.

-   **State 5: `SW_WRITE`**:
    -   `MemWrite <= 1`, `IorD <= 1` (write `B` register to data memory).
    -   Next state: `FETCH`.

-   **State 6: `R_EXECUTE`** (for R-type instructions like `add`, `sub`, `slt`):
    -   `ALUSrcA <= 1`, `ALUSrcB <= 0` (ALU operates on `A` and `B` from register file).
    -   `ALUOp <= 2` (let `ALUControl` decide based on `funct`).
    -   Next state: `R_WRITEBACK`.

-   **State 7: `R_WRITEBACK`**:
    -   `RegWrite <= 1`, `MemToReg <= 0`, `RegDst <= 1` (write `ALUOut` to `rd`).
    -   Next state: `FETCH`.

-   **State 8: `BRANCH_COMP`** (for `beq`, `bne`):
    -   `ALUSrcA <= 1`, `ALUSrcB <= 0` (compare `rs` and `rt`).
    -   `ALUOp <= 1` (subtract to check for zero).
    -   `PCWriteCond <= 1`, `PCSource <= 1` (prepare to branch if `Zero` is true/false).
    -   Next state: `FETCH`.

-   **State 9: `JUMP_EXECUTE`** (for `j`):
    -   `PCWrite <= 1`, `PCSource <= 2` (unconditional jump).
    -   Next state: `FETCH`.

-   **State 10: `I_EXECUTE`** (for `addi`, `ori`):
    -   `ALUSrcA <= 1`, `ALUSrcB <= 2` (ALU operates on `rs` and immediate).
    -   `ALUOp <= 0` (for `addi`) or custom for `ori`.
    -   Next state: `I_WRITEBACK`.

-   **State 11: `I_WRITEBACK`**:
    -   `RegWrite <= 1`, `MemToReg <= 0`, `RegDst <= 0` (write `ALUOut` to `rt`).
    -   Next state: `FETCH`.

---

## 3. Selected Weihai MIPS Instruction Set

To implement the game logic, the following minimal and effective instruction set is chosen:

-   **`lw` (Load Word)**: To read from memory-mapped I/O (buttons, switches).
-   **`sw` (Store Word)**: To write to memory-mapped I/O (LEDs, 7-segment display).
-   **`addi` (Add Immediate)**: To increment/decrement counters and scores.
-   **`ori` (OR Immediate)**: To manipulate bitmasks for I/O control.
-   **`slt` (Set Less Than)**: For comparisons (e.g., `score < 3`).
-   **`beq` (Branch on Equal)**: For conditional state changes (e.g., `if (button == expected_button)`).
-   **`bne` (Branch on Not Equal)**: For conditional loops and checks.
-   **`j` (Jump)**: For unconditional state transitions in the game's FSM.
-   **`add` (Add)**: For general arithmetic operations.
-   **`sub` (Subtract)**: For general arithmetic operations.
-   **`and` (AND)**: For bitmasking operations.
-   **`lui` (Load Upper Immediate)**: To load 32-bit addresses for I/O devices.
-   **`jr` (Jump Register)**: For returning from subroutines (e.g., delay loops).
-   **`jal` (Jump and Link)**: For calling subroutines.
