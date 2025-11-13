# MIPS-style CPU (Course Project) — Overview and Current Status

This repository implements a 32-bit, multi-cycle MIPS-style CPU in Verilog with memory-mapped I/O. The project targets the Digilent Basys3 (Artix-7) board and is structured for simulation first, then FPGA implementation.

## Project Goals

- Implement a MIPS-like CPU with a 32-bit datapath and 32 general-purpose registers.
- Support a minimal instruction subset (arithmetic, logic, memory, branches, jumps) sufficient to implement the "Rhythm Master" game.
- Use a unified address space (memory-mapped I/O) for switches, buttons, LEDs, and a 7-segment display.
- Verify the design thoroughly by functional simulation before synthesizing and programming the Basys3 board.

## Architecture (high level)

- Multi-cycle CPU with separate `controller` (FSM) and `datapath` modules.
- Datapath components: `PC`, `IR`, register file (32 × 32-bit), `A/B` pipeline registers, `ALU`, `ALUOut`, `MDR`/memory interface.
- ALUControl module translates `ALUOp` + `funct` to an ALU operation.
- Memory module (`exmemory.v`) implements RAM and memory-mapped I/O.

## Instruction subset (implemented / planned)

- R-type: add, sub, and, or, slt (and other common R-type ops can be added)
- I-type: addi, ori, lui, lw, sw
- Branch / jump: beq, bne, j, jal, jr

This subset covers arithmetic, logical, memory access, and control flow required by the game.

## Hardware target: Basys3 (Digilent)

- FPGA: Xilinx Artix-7 (XC7A35T)
- On-board resources used:
   - 16 slide switches (SW0–SW15)
   - 5 push-buttons (BTNC, BTNU, BTND, BTNL, BTNR)
   - 16 LEDs (LD0–LD15)
   - 4-digit 7-segment display
   - 100 MHz system clock

I/O is mapped to high addresses (e.g., `0xFFFF0000` region) in `exmemory.v` for ease of access via `lw`/`sw`.

## Repository structure (current)

- `mips32.v` — CPU top-level, connects `controller`, `datapath`, and `alucontrol`.
- `controller.v` — Multi-cycle FSM controller (produces control signals).
- `datapath.v` — 32-bit datapath implementation.
- `alucontrol.v` — Maps `ALUOp` + `funct` to ALU control codes.
- `exmemory.v` — Unified RAM + memory-mapped I/O (Basys3-friendly I/O ports).
- `fpga_top.v` — Board-level top that connects the CPU to Basys3 pins and includes clock divider/reset.
- `cpu_modules/` — Small building blocks: `alu.v`, `regfile.v`, `flop.v`, `mux.v`, `zerodetect.v`, etc.
- `testbench.v` — Functional testbench for simulation.
- `programs/` — Assembly examples and HEX memory image used for simulation.
- `basys3_constraints.xdc` — Example XDC mapping top-level ports to Basys3 pins.

## Current status

- Implemented: `alucontrol`, updated `controller` FSM (multi-cycle), `datapath`, unified `exmemory` (Basys3 I/O), `mips32` top, `fpga_top`, testbench, and a simple test program.
- Added `mux3` helper and simulation/test infrastructure.
- Ready for functional simulation and instruction-by-instruction verification.

## How to run functional simulation (recommended)

Option A — Icarus Verilog (fast, CLI):

```bash
# From project root
iverilog -g2005 -o simv testbench.v mips32.v controller.v datapath.v alucontrol.v exmemory.v cpu_modules/*.v
vvp simv
# Open waveform
gtkwave cpu_sim.vcd
```

Option B — Vivado Simulator (GUI, more integrated):

1. Create a Vivado project and add all source files.
2. Add `testbench.v` to the simulation fileset and set it as the top for simulation.
3. Run simulation and inspect waveforms.

### Things to check in simulation

- PC progression and instruction fetch
- ALU outputs for R/I-type operations
- Correct sequencing of control FSM states
- Memory read/write and memory-mapped I/O behavior
- Register file write-backs and `jal`/`jr` behavior

## FPGA flow (after simulation passes)

1. Open Vivado, create a project for the Basys3 (XC7A35T).
2. Add RTL sources and `basys3_constraints.xdc` (update pin mappings if needed).
3. Synthesize, implement, and generate a bitstream.
4. Program the Basys3 board and test with the sample program that toggles LEDs / reads switches.

## Next steps and priorities (week 1)

1. Run functional simulation and fix any failing instructions or control timing issues.
2. Verify each instruction in the chosen subset (use small assembly tests).
3. Once stable in simulation, synthesize a small smoke-test and run it on Basys3 (LED toggle, read switches).
4. Implement the Rhythm Master game in assembly, test in simulation, then run on hardware.

## Notes and tips

- For synthesis on Basys3, replace behavioral RAM with a Block RAM IP core for reliable timing and resource usage.
- Use the `basys3_constraints.xdc` as a starting point and update pin names to match your board revision.
- Keep simulation traces (waveforms) for each debugging session — they greatly speed up root-cause analysis.