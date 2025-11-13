// exmemory.v: Unified memory and memory-mapped I/O module
`timescale 1ns/1ps
module exmemory(
    input clk,
    input memread, memwrite,
    input [31:0] addr,
    input [31:0] writedata,
    output reg [31:0] readdata,

    // I/O Device Ports (to be connected at the top level to FPGA pins)
    // Basys3 has 16 switches, 5 buttons, 16 LEDs
    input  [15:0] switches_in,   // Connect to 16 physical switches
    input  [4:0]  buttons_in,    // Connect to 5 physical buttons
    output [15:0] leds_out,      // Connect to 16 physical LEDs
    output [15:0] seven_seg_data,// Data for 7-segment display
    output [3:0]  seven_seg_an   // Anode control for 7-segment display
);

    // --- Address Map ---
    // High addresses are used for I/O to keep them separate from main memory.
    parameter ADDR_LEDS     = 32'hFFFF0000; // Address for LED register (write-only)
    parameter ADDR_SWITCHES = 32'hFFFF0004; // Address for Switches (read-only)
    parameter ADDR_BUTTONS  = 32'hFFFF0008; // Address for Buttons (read-only)
    parameter ADDR_7SEG_DATA= 32'hFFFF000C; // Address for 7-segment data (write-only)
    parameter ADDR_7SEG_AN  = 32'hFFFF0010; // Address for 7-segment anodes (write-only)

    // --- Main Memory (RAM) ---
    // 64KB RAM (16384 words of 32 bits).
    // For FPGA synthesis, this behavioral model should be replaced with an
    // IP Core Block RAM for efficiency and performance.
    parameter RAM_DEPTH = 16384;
    reg [31:0] ram[RAM_DEPTH-1:0];

    // The CPU provides a byte address, but our RAM is word-addressable.
    // We use addr[15:2] to get a 14-bit word address for our 16K-word RAM.
    wire [13:0] ram_addr = addr[15:2];

    // --- I/O Registers ---
    reg [15:0] led_reg;
    reg [15:0] seven_seg_data_reg;
    reg [3:0]  seven_seg_an_reg;

    // Assign output ports directly to the I/O registers.
    // This continuously drives the external pins with the register values.
    assign leds_out = led_reg;
    assign seven_seg_data = seven_seg_data_reg;
    assign seven_seg_an = seven_seg_an_reg;

    // --- Write Logic (Synchronous) ---
    // Handles writes to either RAM or I/O registers on the rising clock edge.
    always @(posedge clk) begin
        if (memwrite) begin
            // Check if the address is within the RAM address range (0x00000000 to 0x0000FFFF for 64KB)
            if (addr < RAM_DEPTH * 4) begin
                ram[ram_addr] <= writedata;
            end
            // Check if the address matches a memory-mapped I/O device
            else if (addr == ADDR_LEDS) begin
                led_reg <= writedata[15:0];
            end
            else if (addr == ADDR_7SEG_DATA) begin
                seven_seg_data_reg <= writedata[15:0];
            end
            else if (addr == ADDR_7SEG_AN) begin
                seven_seg_an_reg <= writedata[3:0];
            end
        end
    end

    // --- Read Logic (Combinational) ---
    // Handles reads from either RAM or I/O devices.
    // The CPU expects data to be available combinationally based on the address.
    always @(*) begin
        if (memread) begin
            // Check if the address is within the RAM address range
            if (addr < RAM_DEPTH * 4) begin
                readdata = ram[ram_addr];
            end
            // Check if the address matches a readable I/O device
            else if (addr == ADDR_SWITCHES) begin
                readdata = {16'h0, switches_in}; // Read switches (zero-extended to 32 bits)
            end
            else if (addr == ADDR_BUTTONS) begin
                readdata = {27'h0, buttons_in}; // Read buttons (zero-extended to 32 bits)
            end
            else begin
                readdata = 32'h0; // Reading from a write-only or unused address returns 0
            end
        end else begin
            readdata = 32'h0; // Default output when not reading to avoid latches
        end
    end

    // --- (Optional) Program Loading for Simulation ---
    // This allows you to load your assembled machine code into RAM at the start of a simulation.
    // The file "program.hex" should contain your machine code.
    // This block is ignored by synthesis tools.
    integer i;
    initial begin
        // Initialize RAM to zero to avoid unknown states in simulation
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            ram[i] = 32'h0;
        end
        // Initialize I/O registers
        led_reg = 16'h0;
        seven_seg_data_reg = 16'h0;
        seven_seg_an_reg = 4'h0;
        // Load the program from a hex file
        $readmemh("programs/simple_program.hex", ram);
    end

endmodule
