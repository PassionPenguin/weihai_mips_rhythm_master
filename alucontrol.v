// alucontrol.v: map aluop/funct to 3-bit alu control
// alucontrol.v: Decodes ALU operations for the Weihai MIPS subset
`timescale 1ns/1ps
module alucontrol(
    input [1:0] aluop,      // From main controller
    input [5:0] funct,      // From instruction's funct field
    output reg [2:0] alucont   // To ALU
);

    // ALU Operations (matching the ALU in cpu_modules/alu.v)
    parameter ALU_ADD = 3'b010;
    parameter ALU_SUB = 3'b110;
    parameter ALU_AND = 3'b000;
    parameter ALU_OR  = 3'b001;
    parameter ALU_SLT = 3'b111;

    // Funct codes for R-type instructions from MIPS specification
    parameter F_ADD = 6'b100000;
    parameter F_SUB = 6'b100010;
    parameter F_AND = 6'b100100;
    parameter F_OR  = 6'b100101;
    parameter F_SLT = 6'b101010;
    parameter F_JR  = 6'b001000;

    always @(*) begin
        case (aluop)
            2'b00: alucont = ALU_ADD; // For lw, sw, addi, lui
            2'b01: alucont = ALU_SUB; // For beq, bne
            2'b11: alucont = ALU_OR;  // For ori
            2'b10: // R-type, decode funct field
                case (funct)
                    F_ADD: alucont = ALU_ADD;
                    F_SUB: alucont = ALU_SUB;
                    F_AND: alucont = ALU_AND;
                    F_OR:  alucont = ALU_OR;
                    F_SLT: alucont = ALU_SLT;
                    default: alucont = 3'bxxx; // Should not happen for valid R-type
                endcase
            default: alucont = 3'bxxx; // Should not happen
        endcase
    end

endmodule

