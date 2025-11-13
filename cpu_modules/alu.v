// alu.v: simple parameterized ALU
`timescale 1ns/1ps
module alu #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a, b,
    input [2:0] alucont,
    output reg [WIDTH-1:0] result
);
    wire [WIDTH-1:0] b2 = alucont[2] ? ~b : b;
    wire [WIDTH-1:0] sum = a + b2 + alucont[2];
    wire [WIDTH-1:0] slt = {{(WIDTH-1){1'b0}}, sum[WIDTH-1]};

    always @(*) begin
        case (alucont[1:0])
            2'b00: result = a & b;
            2'b01: result = a | b;
            2'b10: result = sum;
            2'b11: result = slt;
            default: result = {WIDTH{1'bx}};
        endcase
    end
endmodule
