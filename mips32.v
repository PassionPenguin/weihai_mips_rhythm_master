// mips32.v: Top-level module for the Weihai MIPS CPU
`timescale 1ns/1ps
module mips32(
    input clk, reset,
    // This top-level module will be connected to memory and I/O in the final system
    // For simulation, a testbench will provide memory data.
    output [31:0] adr,          // Memory address from CPU
    output [31:0] writedata,    // Data to be written to memory
    output memread, memwrite,   // Memory control signals
    input  [31:0] memdata       // Data read from memory
);

    // Internal control signals
    wire zero;
    wire alusrca, iord, regwrite, irwrite;
    wire [1:0] memtoreg, regdst; // Now 2 bits
    wire pcen, pcwrite;
    wire [1:0] pcsource, alusrcb, aluop;
    wire [2:0] alucont;
    wire [31:0] instr;

    // Instantiate Controller
    controller c(
        .clk(clk), .reset(reset),
        .op(instr[31:26]), .funct(instr[5:0]), .zero(zero),
        .memread(memread), .memwrite(memwrite), .irwrite(irwrite), .alusrca(alusrca),
        .iord(iord), .memtoreg(memtoreg), .regwrite(regwrite),
        .regdst(regdst), .pcen(pcen), .pcwrite(pcwrite),
        .pcsource(pcsource), .alusrcb(alusrcb), .aluop(aluop)
    );

    // Instantiate ALU Control
    alucontrol acont(
        .aluop(aluop), .funct(instr[5:0]), .alucont(alucont)
    );

    // Instantiate Datapath
    datapath dp(
        .clk(clk), .reset(reset), .memdata(memdata),
        .alusrca(alusrca), .memtoreg(memtoreg), .iord(iord),
        .pcen(pcen), .irwrite(irwrite), .regwrite(regwrite), .regdst(regdst),
        .pcsource(pcsource), .alusrcb(alusrcb), .alucont(alucont),
        .zero(zero), .instr(instr), .adr(adr), .writedata(writedata)
    );

endmodule
