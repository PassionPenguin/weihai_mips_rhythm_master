// testbench.v: Comprehensive testbench for MIPS CPU simulation
`timescale 1ns/1ps

module testbench();
    reg clk;
    reg reset;
    
    // I/O signals for simulation
    reg [15:0] switches;
    reg [4:0] buttons;
    wire [15:0] leds;
    wire [15:0] seven_seg_data;
    wire [3:0] seven_seg_an;
    
    // CPU-Memory interface
    wire [31:0] cpu_addr;
    wire [31:0] cpu_writedata;
    wire [31:0] cpu_readdata;
    wire cpu_memread, cpu_memwrite;
    
    // Instantiate the CPU
    mips32 cpu(
        .clk(clk),
        .reset(reset),
        .adr(cpu_addr),
        .writedata(cpu_writedata),
        .memread(cpu_memread),
        .memwrite(cpu_memwrite),
        .memdata(cpu_readdata)
    );
    
    // Instantiate the memory module
    exmemory mem(
        .clk(clk),
        .memread(cpu_memread),
        .memwrite(cpu_memwrite),
        .addr(cpu_addr),
        .writedata(cpu_writedata),
        .readdata(cpu_readdata),
        .switches_in(switches),
        .buttons_in(buttons),
        .leds_out(leds),
        .seven_seg_data(seven_seg_data),
        .seven_seg_an(seven_seg_an)
    );
    
    // Clock generation: 10ns period = 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize waveform dump for viewing in simulator
        $dumpfile("cpu_sim.vcd");
        $dumpvars(0, testbench);
        
        // Display header
        $display("========================================");
        $display("MIPS CPU Simulation Testbench");
        $display("========================================");
        $display("Time\tPC\t\tInstr\t\tALUOut\t\tLEDs");
        $display("----------------------------------------");
        
        // Initialize inputs
        switches = 16'h0000;
        buttons = 5'b00000;
        reset = 1;
        
        // Hold reset for a few cycles
        repeat(5) @(posedge clk);
        reset = 0;
        
        // Check initial PC value
        @(posedge clk);
        $display("\n[INIT] First PC after reset: %h", cpu.dp.pc);
        $display("[INIT] First instruction: %h\n", mem.ram[cpu.dp.pc[15:2]]);
        
        // Monitor key signals during simulation
        // The program should run automatically from memory
        
        // Simulate some input changes during execution
        #1000;
        switches = 16'h0001;  // Turn on switch 0
        $display("\n[%0t] Switches changed to: %h", $time, switches);
        
        #1000;
        buttons = 5'b00001;   // Press center button
        $display("[%0t] Button pressed: %b", $time, buttons);
        
        #100;
        buttons = 5'b00000;   // Release button
        
        #2000;
        switches = 16'h0003;  // Change switches
        $display("[%0t] Switches changed to: %h", $time, switches);
        
        // Let the simulation run for a while
        #10000;
        
        // Display final state
        $display("\n========================================");
        $display("Simulation Complete");
        $display("Final LED state: %b (%h)", leds, leds);
        $display("7-Segment Display: %h", seven_seg_data);
        $display("========================================");
        
        $finish;
    end
    
    // Monitor important signals every clock cycle
    always @(posedge clk) begin
        if (!reset) begin
            $display("%0t\t%h\t%h\t%h\t%b", 
                     $time, 
                     cpu.dp.pc,           // Program Counter
                     mem.ram[cpu.dp.pc[15:2]],  // Current instruction
                     cpu.dp.aluout,       // ALU output
                     leds);               // LED state
            
            // Debug memory writes
            if (cpu_memwrite) begin
                $display("  [MEM WRITE] Addr=%h, Data=%h, IsIO=%b", 
                         cpu_addr, cpu_writedata, (cpu_addr >= 32'hFFFF0000));
            end
            
            // Debug register writes
            if (cpu.dp.regwrite) begin
                $display("  [REG WRITE] $r%0d <= %h (PC=%h, state=%b, instr=%h, rt=%d, rd=%d)", 
                         cpu.dp.wa, cpu.dp.wd, cpu.dp.pc, cpu.c.state, cpu.dp.instr, 
                         cpu.dp.instr[20:16], cpu.dp.instr[15:11]);
            end
            
            // Debug controller state (show first 100 cycles)
            if ($time < 1000) begin
                $display("  [STATE] %b, regwrite=%b, memwrite=%b, op=%h, irwrite=%b, memdata=%h, instr=%h", 
                         cpu.c.state, cpu.c.regwrite, cpu.c.memwrite, cpu.c.op, cpu.c.irwrite, 
                         cpu.dp.memdata, cpu.dp.instr);
            end
        end
    end
    
    // Timeout watchdog
    initial begin
        #50000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule
