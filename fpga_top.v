// fpga_top.v: Top-level module for Basys3 FPGA board
`timescale 1ns/1ps
module fpga_top(
    input clk,              // 100MHz clock from Basys3
    input btnC,             // Center button (used as reset)
    input btnU, btnD, btnL, btnR, // Other buttons
    input [15:0] sw,        // 16 slide switches
    output [15:0] led,      // 16 LEDs
    output [6:0] seg,       // 7-segment display segments (cathodes)
    output [3:0] an         // 7-segment display anodes
);

    // --- Clock Divider ---
    // The Basys3 has a 100MHz clock, which is too fast for our CPU.
    // We'll divide it down to a reasonable frequency (e.g., ~1-10 MHz for testing).
    // For initial testing, use a slow clock so you can see what's happening.
    
    reg [25:0] clk_divider;
    wire cpu_clk;
    
    always @(posedge clk) begin
        clk_divider <= clk_divider + 1;
    end
    
    // Select which bit to use as CPU clock:
    // clk_divider[0]  = 50 MHz
    // clk_divider[1]  = 25 MHz
    // clk_divider[5]  = ~1.5 MHz
    // clk_divider[10] = ~48 KHz
    // clk_divider[15] = ~1.5 KHz (good for initial debugging)
    // clk_divider[20] = ~47 Hz (very slow, visible on LEDs)
    assign cpu_clk = clk_divider[15]; // Start with a slow clock for debugging

    // --- Reset (synchronized) ---
    // Use the center button as reset
    reg reset_sync1, reset_sync2;
    always @(posedge cpu_clk) begin
        reset_sync1 <= btnC;
        reset_sync2 <= reset_sync1;
    end
    wire cpu_reset = reset_sync2;

    // --- CPU-Memory Interface Signals ---
    wire [31:0] cpu_addr;
    wire [31:0] cpu_writedata;
    wire [31:0] cpu_readdata;
    wire cpu_memread, cpu_memwrite;

    // --- Button Input (combine all buttons into one bus) ---
    wire [4:0] buttons = {btnU, btnD, btnL, btnR, btnC};

    // --- 7-Segment Display Signals ---
    wire [15:0] seg_data_from_mem;
    wire [3:0] seg_an_from_mem;

    // Instantiate the MIPS CPU
    mips32 cpu(
        .clk(cpu_clk),
        .reset(cpu_reset),
        .adr(cpu_addr),
        .writedata(cpu_writedata),
        .memread(cpu_memread),
        .memwrite(cpu_memwrite),
        .memdata(cpu_readdata)
    );

    // Instantiate the unified memory module
    exmemory mem(
        .clk(cpu_clk),
        .memread(cpu_memread),
        .memwrite(cpu_memwrite),
        .addr(cpu_addr),
        .writedata(cpu_writedata),
        .readdata(cpu_readdata),
        .switches_in(sw),
        .buttons_in(buttons),
        .leds_out(led),
        .seven_seg_data(seg_data_from_mem),
        .seven_seg_an(seg_an_from_mem)
    );

    // --- 7-Segment Display Driver ---
    // The seg_data_from_mem contains segments for each digit
    // We need to decode this based on which digit is active
    // For simplicity, we'll assume seg_data_from_mem[15:12] = digit3,
    // [11:8] = digit2, [7:4] = digit1, [3:0] = digit0
    
    // Simple display driver (you can make this more sophisticated)
    // For now, we'll use the lower 16 bits as raw segment data
    assign an = seg_an_from_mem;  // Which digit to turn on
    
    // Decode hex digit to 7-segment (common cathode for Basys3)
    // seg_data_from_mem contains 4-bit hex values for each digit
    reg [6:0] seg_decoded;
    wire [3:0] active_digit;
    
    // Select which digit to display based on anodes
    assign active_digit = (seg_an_from_mem == 4'b1110) ? seg_data_from_mem[3:0] :
                          (seg_an_from_mem == 4'b1101) ? seg_data_from_mem[7:4] :
                          (seg_an_from_mem == 4'b1011) ? seg_data_from_mem[11:8] :
                          seg_data_from_mem[15:12];
    
    // Hex to 7-segment decoder (common cathode, active low)
    always @(*) begin
        case (active_digit)
            4'h0: seg_decoded = 7'b1000000; // 0
            4'h1: seg_decoded = 7'b1111001; // 1
            4'h2: seg_decoded = 7'b0100100; // 2
            4'h3: seg_decoded = 7'b0110000; // 3
            4'h4: seg_decoded = 7'b0011001; // 4
            4'h5: seg_decoded = 7'b0010010; // 5
            4'h6: seg_decoded = 7'b0000010; // 6
            4'h7: seg_decoded = 7'b1111000; // 7
            4'h8: seg_decoded = 7'b0000000; // 8
            4'h9: seg_decoded = 7'b0010000; // 9
            4'hA: seg_decoded = 7'b0001000; // A
            4'hB: seg_decoded = 7'b0000011; // b
            4'hC: seg_decoded = 7'b1000110; // C
            4'hD: seg_decoded = 7'b0100001; // d
            4'hE: seg_decoded = 7'b0000110; // E
            4'hF: seg_decoded = 7'b0001110; // F
        endcase
    end
    
    assign seg = seg_decoded;

endmodule
