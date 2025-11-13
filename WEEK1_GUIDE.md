# Week 1 Simulation Guide

## Your Current Status ✓

You have successfully implemented:
1. ✓ ALU Control unit (`alucontrol.v`)
2. ✓ Multi-cycle Controller FSM (`controller.v`)
3. ✓ 32-bit Datapath (`datapath.v`)
4. ✓ Top-level CPU module (`mips32.v`)
5. ✓ Unified Memory with I/O (`exmemory.v`)
6. ✓ FPGA top-level for Basys3 (`fpga_top.v`)
7. ✓ Testbench (`testbench.v`)
8. ✓ Test program (assembly and hex)

## Next Steps for Week 1

### Step 1: Run Functional Simulation (PRIORITY)

**Using Vivado Simulator:**
```bash
cd /Users/hoarfroster/Desktop/CPU\ Design\ and\ Impl

# Create a Vivado project or run simulation directly
vivado -mode tcl
```

In Vivado TCL console:
```tcl
# Add all source files
add_files {datapath.v controller.v alucontrol.v mips32.v exmemory.v}
add_files {cpu_modules/alu.v cpu_modules/flop.v cpu_modules/mux.v cpu_modules/regfile.v cpu_modules/zerodetect.v}
add_files -fileset sim_1 testbench.v

# Set top module
set_property top testbench [get_filesets sim_1]

# Run simulation
launch_simulation
run 50us
```

### Step 2: Debug Common Issues

Watch for these in simulation:

1. **PC not incrementing**: Check FETCH state in controller
2. **Instructions not loading**: Check memory read timing
3. **ALU operations wrong**: Check alucontrol decoding
4. **Registers not updating**: Check regwrite signal timing
5. **Branch/Jump errors**: Check PC mux and branch logic

### Step 3: Verify Each Instruction

Create a checklist and verify in waveform viewer:

- [ ] `addi` - Check that register gets immediate value
- [ ] `add` - Check ALU adds two registers
- [ ] `sub` - Check ALU subtracts correctly
- [ ] `and` - Check bitwise AND
- [ ] `or`/`ori` - Check bitwise OR
- [ ] `slt` - Check set-less-than comparison
- [ ] `lui` - Check upper immediate loading
- [ ] `lw` - Check memory read and register write
- [ ] `sw` - Check memory write
- [ ] `beq` - Check branch taken when equal
- [ ] `bne` - Check branch taken when not equal
- [ ] `j` - Check unconditional jump
- [ ] `jal` - Check jump and $ra = PC+4
- [ ] `jr` - Check jump to register value

### Step 4: Timing Analysis

In the waveform, verify these timing requirements:

**FETCH State (typically 4 clock cycles):**
- Cycle 0: memread=1, load instruction
- Cycle 1: PC = PC + 4
- Cycle 2-3: Decode instruction

**EXECUTE States (vary by instruction):**
- R-type: 2 cycles (execute + writeback)
- lw: 4 cycles (addr calc, mem read, writeback)
- sw: 3 cycles (addr calc, mem write)
- Branch: 1-2 cycles
- Jump: 1 cycle

### Step 5: Create Your Rhythm Game Program

Once basic instructions work, translate your game logic:

```assembly
# Game initialization
lui  $s0, 0xFFFF        # I/O base
addi $s1, $zero, 0      # score = 0

game_loop:
    # Generate random LED pattern (simplified)
    lw   $t0, 4($s0)    # Read switches for randomness
    sw   $t0, 0($s0)    # Light up LEDs
    
    # Wait for button press (simplified - needs timer)
    lw   $t1, 8($s0)    # Read buttons
    beq  $t1, $zero, game_loop  # Wait until pressed
    
    # Check if correct button
    # ... your game logic here ...
    
    # Update score
    addi $s1, $s1, 1    # Increment score
    sw   $s1, 12($s0)   # Display on 7-segment
    
    j game_loop
```

## Debugging Tips

1. **Add $display statements** in your Verilog to print values
2. **Start simple**: Test one instruction type at a time
3. **Check control signals**: Use waveform viewer to see all control signals
4. **Verify FSM states**: Make sure controller transitions correctly
5. **Monitor PC progression**: PC should increment or jump correctly

## Week 1 Deliverables

By end of week 1, you should have:
- [ ] All modules compile without errors
- [ ] Functional simulation runs successfully
- [ ] Basic instruction set verified in simulation
- [ ] Waveform screenshots showing correct execution
- [ ] Simple test program executing correctly
- [ ] Documentation of any design issues found

## Getting Help

If simulation fails:
1. Check syntax errors first (Vivado will show these)
2. Look at the first failing instruction in waveform
3. Trace back through the FSM states
4. Verify control signals match your FSM design document
5. Check datapath connections match the diagram

Good luck! The simulation phase is where you'll catch 90% of your bugs.
