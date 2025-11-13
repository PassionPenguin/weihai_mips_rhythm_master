# MIPS CPU Scripts Usage Guide

This directory contains automation scripts for assembly, simulation, synthesis, and FPGA programming.

## Platform Support

- **Linux/macOS**: Use `.sh` scripts
- **Windows**: Use `.bat` scripts
- **Both**: Vivado TCL scripts (`.tcl`)

## Quick Start

### Windows (Recommended for Basys3)

```batch
REM 1. Assemble all programs
scripts\assemble_all.bat

REM 2. Run full test suite
scripts\test_all.bat

REM 3. Simulate specific test
scripts\run_simulation.bat test_memory

REM 4. Synthesize for Basys3
scripts\synthesize.bat

REM 5. Program the board
scripts\program_fpga.bat
```

### Linux/macOS

```bash
# 1. Assemble all programs
./scripts/assemble_all.sh

# 2. Run full test suite
./scripts/test_all.sh

# 3. Simulate specific test
./scripts/run_simulation.sh test_memory

# 4. Synthesize for Basys3
vivado -mode batch -source scripts/vivado_synth.tcl

# 5. Program the board
vivado -mode batch -source scripts/vivado_program.tcl
```

## Script Reference

### Assembly Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `assemble.sh/bat` | Both | Assemble single .asm file to .hex |
| `assemble_all.sh/bat` | Both | Assemble all programs in programs/ |
| `validate_hex.sh/bat` | Both | Validate hex file format |
| `compare_hex.sh` | Linux/macOS | Compare two hex files |

### Simulation Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `run_simulation.sh/bat` | Both | Run Vivado simulation |
| `vivado_sim.tcl` | Both | Vivado TCL simulation automation |
| `test_all.sh/bat` | Both | Run complete test suite |

### Synthesis & Programming

| Script | Platform | Purpose |
|--------|----------|---------|
| `synthesize.bat` | Windows | Synthesize and implement for Basys3 |
| `program_fpga.bat` | Windows | Program Basys3 via USB |
| `vivado_synth.tcl` | Both | Vivado synthesis/implementation TCL |
| `vivado_program.tcl` | Both | Vivado programming TCL |

## Prerequisites

### Windows
- Xilinx Vivado (with Basys3 support)
- Rust toolchain (for assembler)
- Digilent board drivers

### Linux
- Xilinx Vivado
- Rust toolchain
- Digilent cable drivers

## Common Workflows

### Week 1: Simulation & Testing
```batch
REM Assemble and validate
scripts\assemble_all.bat

REM Run memory test
scripts\run_simulation.bat test_memory

REM Run marquee test
scripts\run_simulation.bat test_marquee

REM Run switch test
scripts\run_simulation.bat test_switch_decimal
```

### Week 2+: FPGA Implementation
```batch
REM After simulation passes, synthesize
scripts\synthesize.bat

REM Program board
scripts\program_fpga.bat

REM Test on hardware with different programs
scripts\assemble.bat programs\your_game.asm
REM (manually load via Vivado Hardware Manager if needed)
```

## Troubleshooting

### "Vivado not found"
- **Windows**: Run scripts from "Vivado Command Prompt"
- **Linux**: Source settings64.sh first: `source /opt/Xilinx/Vivado/2023.2/settings64.sh`

### "Assembler not found"
- Build it first: `cd assembler && cargo build --release`

### "Programming failed"
- Check USB cable connection
- Verify board is powered on
- Install/update Digilent drivers
- Try hardware manager GUI instead

## Files Generated

- `programs/*.hex` - Assembled machine code
- `vivado_sim/` - Simulation project and waveforms
- `vivado_impl/` - Synthesis outputs and bitstream
- `*.log` - Various log files

## Notes

- All scripts assume they're run from project root
- Simulation requires ~2-5 minutes
- Synthesis requires ~10-20 minutes (first run)
- Incremental builds are faster
