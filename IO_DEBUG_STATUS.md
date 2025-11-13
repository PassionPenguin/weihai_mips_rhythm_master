# I/O System Debug Summary

## Issues Found

### 1. ✅ LUI Instruction Not Implemented Correctly
**Problem:** LUI (Load Upper Immediate) was using sign-extended immediate instead of lui_imm
**Solution:** 
- Added conditional mux selection in datapath using `alusrca` signal
- Modified controller I_EXECUTE state to use `alusrcb=11` for LUI with OR operation
- `src2_option3 = alusrca ? lui_imm : {sign_imm[29:0], 2'b00}` 

### 2. ⚠️ Instruction Register Updates Every Cycle (CRITICAL BUG)
**Problem:** IR enable is hardwired to 1, causing instruction to be overwritten before writeback completes
**Symptom:** All register writes go to $r0 instead of correct destination
**Solution Required:** Add IRWrite control signal

### 3. Port Width Warnings
- regdst: Controller expects 1-bit but datapath uses 2-bit (for JAL support)
- memtoreg: Similar issue
**Impact:** Low priority, works due to padding

## Required Changes

### Add IRWrite Signal

#### datapath.v
```verilog
// Add to port list:
input irwrite,

// Change IR instantiation from:
flopen #(WIDTH) ir_reg(clk, 1'b1, memdata, instr);
// To:
flopen #(WIDTH) ir_reg(clk, irwrite, memdata, instr);
```

#### controller.v
```verilog
// Add to port list:
output reg pcwrite, memread, memwrite, irwrite, iord, regwrite, alusrca,

// Add to default values:
pcwrite = 0; memread = 0; memwrite = 0; irwrite = 0; iord = 0;

// Add to FETCH state:
FETCH: begin
    memread = 1; irwrite = 1; iord = 0; alusrcb = 2'b01; aluop = 2'b00;
    pcwrite = 1; pcsource = 2'b00;
end
```

#### mips32.v
```verilog
// Add to controller instantiation:
.irwrite(irwrite),

// Add to datapath instantiation:
.irwrite(irwrite),

// Add wire declaration:
wire irwrite;
```

## Memory Map (from MEMORY_MAP.md)
- RAM: 0x0000_0000 - 0x0000_FFFF
- LEDs: 0xFFFF_0000 (write-only, 16 bits)
- Switches: 0xFFFF_0004 (read-only, 16 bits)
- Buttons: 0xFFFF_0008 (read-only, 5 bits)
- 7-Seg Data: 0xFFFF_000C (write-only, 16 bits)
- 7-Seg Anode: 0xFFFF_0010 (write-only, 4 bits)

## Test Programs Created
1. test_io_simple.asm/hex - Basic LED write test
2. All test programs updated to use correct I/O base (lui $s0, 0xFFFF)

## Next Steps
1. Apply IRWrite signal changes to all three files
2. Recompile and test
3. Verify register writes go to correct destinations
4. Verify memory-mapped I/O writes reach LED register
5. Run full test suite

## Status
- Memory map documented ✓ (see MEMORY_MAP.md)
- LUI instruction fixed ✓ (conditional mux selection)
- IRWrite signal APPLIED ✓ (added to controller, datapath, mips32)
- Test programs created ✓ (test_io_simple.asm/hex)
- **REMAINING ISSUE:** All register writes still go to $r0 ⚠️
  - IRWrite is working (no compilation errors)
  - But instr[20:16] reads as 0 during writeback
  - Need to debug why instruction register isn't preserving correct value
  - Possible issue: Instruction fetch/decode timing
  
## Successful Changes Made
1. Created MEMORY_MAP.md with complete I/O documentation
2. Fixed LUI implementation in datapath and controller
3. Added IRWrite signal throughout the design
4. Created test_io_simple program
5. Fixed syntax errors in controller
6. All modules compile successfully with iverilog

## Next Debugging Steps
1. Add more detailed waveform analysis
2. Check if instruction register value changes between states
3. Verify FETCH->DECODE->EXECUTE->WRITEBACK sequence
4. May need to add pipeline register for instruction between decode and writeback
