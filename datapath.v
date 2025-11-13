// datapath.v: 32-bit datapath for Weihai MIPS subset
`timescale 1ns/1ps
module datapath(
    input clk, reset,
    input [31:0] memdata,
    input alusrca, iord, pcen, irwrite,
    input regwrite,
    input [1:0] memtoreg, regdst, // Now 2 bits for JAL
    input [1:0] pcsource, alusrcb,
    input [2:0] alucont,
    output zero,
    output [31:0] instr,
    output [31:0] adr,
    output [31:0] writedata
);
    parameter WIDTH = 32;
    parameter REGBITS = 5;

    // internal signals
    wire [REGBITS-1:0] wa;
    wire [WIDTH-1:0] pc, nextpc, aluout_pc, rd1, rd2, wd, a, src1, src2, aluresult, aluout;
    wire [WIDTH-1:0] sign_imm, zero_ext_imm, lui_imm;
    
    // Pipeline registers for instruction fields
    // These preserve rs, rt, rd during multi-cycle execution
    reg [REGBITS-1:0] rs_latch, rt_latch, rd_latch;
    reg [15:0] imm_latch;
    
    // Latch instruction fields during DECODE
    always @(posedge clk) begin
        if (irwrite) begin  // When loading new instruction, also prepare to latch fields
            rs_latch <= memdata[25:21];
            rt_latch <= memdata[20:16];
            rd_latch <= memdata[15:11];
            imm_latch <= memdata[15:0];
        end
    end

    // Instruction Register
    // The instruction is fetched in one cycle, so a simple register is sufficient.
    flopen #(WIDTH) ir_reg(clk, irwrite, memdata, instr);

    // PC register and PC+4 calculation
    flopenr #(WIDTH) pcreg(clk, reset, pcen, nextpc, pc);
    // This ALU is just for PC+4, could be a simple adder
    alu #(WIDTH) pcadd(pc, 32'd4, 3'b010, aluout_pc);

    // Register file
    mux3 #(REGBITS) wamux(rt_latch, rd_latch, 5'd31, regdst, wa);
    regfile #(WIDTH, REGBITS) rf(clk, regwrite, rs_latch, rt_latch, wa, wd, rd1, rd2);

    // Data path registers (A, B, ALUOut)
    flop #(WIDTH) areg(clk, rd1, a);
    flop #(WIDTH) breg(clk, rd2, writedata); // B register holds rd2
    flop #(WIDTH) aluoutreg(clk, aluresult, aluout);

    // Address Mux (selects between PC and ALUOut for memory address)
    mux2 #(WIDTH) adrmux(pc, aluout, iord, adr);

    // ALU source Muxes
    mux2 #(WIDTH) src1mux(pc, a, alusrca, src1);

    // Immediate value processing
    assign sign_imm = {{16{imm_latch[15]}}, imm_latch};
    assign zero_ext_imm = {16'b0, imm_latch};
    assign lui_imm = {imm_latch, 16'b0};

    // Select between branch offset and LUI immediate for alusrcb=11
    wire [WIDTH-1:0] src2_option3;
    assign src2_option3 = alusrca ? lui_imm : {sign_imm[29:0], 2'b00};
    
    mux4 #(WIDTH) src2mux(
        writedata,                  // 00: from B register (rd2)
        32'd4,                      // 01: constant 4 for PC increment
        sign_imm,                   // 10: sign-extended immediate (for addi, lw, sw, ori)
        src2_option3,               // 11: branch offset (when alusrca=0) or lui_imm (when alusrca=1)
        alusrcb,
        src2
    );

    // Main ALU
    alu #(WIDTH) main_alu(src1, src2, alucont, aluresult);
    zerodetect #(WIDTH) zd(aluresult, zero);

    // Next PC Mux
    mux4 #(WIDTH) pcmux(
        aluout_pc,                          // 00: PC+4
        aluout,                             // 01: branch target from ALUOut
        {pc[31:28], instr[25:0], 2'b00}, // 10: jump target
        rd1,                                // 11: for jr (from register A)
        pcsource,
        nextpc
    );

    // Write-back Mux (to register file)
    // Selects between ALUOut, data from memory, or PC+4 for JAL
    mux3 #(WIDTH) wdmux(aluout, memdata, aluout_pc, memtoreg, wd);

endmodule
