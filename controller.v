// controller.v: multi-cycle controller for the Weihai MIPS subset
`timescale 1ns/1ps
module controller(
    input clk, reset,
    input [5:0] op, funct,
    input zero,
    output pcen,
    output reg pcwrite, memread, memwrite, irwrite, iord, regwrite, alusrca,
    output reg [1:0] pcsource, alusrcb, aluop, memtoreg, regdst
);
    reg [3:0] state, nextstate;

    // FSM States
    parameter FETCH         = 4'b0000;
    parameter DECODE        = 4'b0001;
    parameter MEM_ADDR_COMP = 4'b0010;
    parameter LW_READ       = 4'b0011;
    parameter LW_WRITEBACK  = 4'b0100;
    parameter SW_WRITE      = 4'b0101;
    parameter R_EXECUTE     = 4'b0110;
    parameter R_WRITEBACK   = 4'b0111;
    parameter BRANCH_COMP   = 4'b1000;
    parameter JUMP_EXECUTE  = 4'b1001;
    parameter I_EXECUTE     = 4'b1010;
    parameter I_WRITEBACK   = 4'b1011;
    parameter JAL_WRITEBACK = 4'b1100; // New state for JAL

    // Opcodes from FSM_and_design.md
    parameter RTYPE = 6'b000000;
    parameter J     = 6'b000010;
    parameter JAL   = 6'b000011;
    parameter BEQ   = 6'b000100;
    parameter BNE   = 6'b000101;
    parameter ADDI  = 6'b001000;
    parameter ORI   = 6'b001101;
    parameter LUI   = 6'b001111;
    parameter LW    = 6'b100011;
    parameter SW    = 6'b101011;

    // Funct codes
    parameter F_JR = 6'b001000;

    // PC write logic
    wire pcwritecond = (state == BRANCH_COMP);
    wire cond = (op == BNE) ? ~zero : zero;
    assign pcen = pcwrite | (pcwritecond & cond);

    always @(posedge clk) begin
        if (reset) state <= FETCH;
        else state <= nextstate;
    end

    // Next State Logic
    always @(*) begin
        case (state)
            FETCH: nextstate = DECODE;
            DECODE: case (op)
                        RTYPE:  nextstate = (funct == F_JR) ? JUMP_EXECUTE : R_EXECUTE;
                        LW, SW: nextstate = MEM_ADDR_COMP;
                        BEQ, BNE: nextstate = BRANCH_COMP;
                        J:      nextstate = JUMP_EXECUTE;
                        JAL:    nextstate = JUMP_EXECUTE;
                        ADDI, ORI, LUI: nextstate = I_EXECUTE;
                        default: nextstate = FETCH;
                     endcase
            MEM_ADDR_COMP: case (op)
                        LW: nextstate = LW_READ;
                        SW: nextstate = SW_WRITE;
                        default: nextstate = FETCH;
                    endcase
            LW_READ:       nextstate = LW_WRITEBACK;
            JUMP_EXECUTE:  nextstate = (op == JAL) ? JAL_WRITEBACK : FETCH;
            JAL_WRITEBACK: nextstate = FETCH;
            LW_WRITEBACK, SW_WRITE, R_WRITEBACK, BRANCH_COMP, I_WRITEBACK: nextstate = FETCH;
            R_EXECUTE:     nextstate = R_WRITEBACK;
            I_EXECUTE:     nextstate = I_WRITEBACK;
            default:       nextstate = FETCH;
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default signal values
        pcwrite = 0; memread = 0; memwrite = 0; irwrite = 0; iord = 0;
        regwrite = 0; alusrca = 0; alusrcb = 2'b00; aluop = 2'b00;
        pcsource = 2'b00; memtoreg = 2'b00; regdst = 2'b00;

        case (state)
            FETCH: begin
                memread = 1;
                irwrite = 1;       // Latch instruction
                alusrcb = 2'b01;   // PC + 4
                pcwrite = 1;
                aluop = 2'b00;     // ADD
            end
            DECODE: begin
                alusrcb = 2'b11; // For branch offset calculation
            end
            MEM_ADDR_COMP: begin // lw, sw
                alusrca = 1; alusrcb = 2'b10; aluop = 2'b00; // add
            end
            LW_READ: begin
                memread = 1; iord = 1;
            end
            LW_WRITEBACK: begin
                regwrite = 1; memtoreg = 1; regdst = 0; // Write MDR to rt
            end
            SW_WRITE: begin
                memwrite = 1; iord = 1;
            end
            R_EXECUTE: begin // add, sub, slt, and, or
                alusrca = 1; alusrcb = 2'b00; aluop = 2'b10; // R-type
            end
            R_WRITEBACK: begin
                regwrite = 1; memtoreg = 0; regdst = 1; // Write ALUOut to rd
            end
            BRANCH_COMP: begin // beq, bne
                alusrca = 1; alusrcb = 2'b00; aluop = 2'b01; // sub
                pcsource = 2'b01;
            end
            JUMP_EXECUTE: begin // j, jal, jr
                pcwrite = 1;
                if (op == RTYPE && funct == F_JR) pcsource = 2'b11; // jr
                else pcsource = 2'b10; // j, jal
            end
            JAL_WRITEBACK: begin // New state for JAL
                regwrite = 1; memtoreg = 0; regdst = 2'b10; // Write PC+4 to $ra (31)
            end
            I_EXECUTE: begin // addi, ori, lui
                alusrca = 1;
                if (op == LUI) begin
                    alusrcb = 2'b11;  // Select lui_imm (reuse branch offset mux input)
                    aluop = 2'b11;    // OR operation (0 OR lui_imm = lui_imm)
                end
                else begin
                    alusrcb = 2'b10;  // Select sign_imm
                    if (op == ORI) aluop = 2'b11; // ORI
                    else aluop = 2'b00; // ADDI
                end
            end
            I_WRITEBACK: begin
                regwrite = 1; memtoreg = 0; regdst = 0; // Write ALUOut to rt
            end
        endcase
    end
endmodule