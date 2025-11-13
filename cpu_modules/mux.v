// mux2 and mux4 modules
`timescale 1ns/1ps
module mux2 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] d0, d1,
    input s,
    output [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] d0, d1, d2,
    input [1:0] s,
    output reg [WIDTH-1:0] y
);
    always @(*) begin
        case (s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = {WIDTH{1'bx}};
        endcase
    end
endmodule

module mux4 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] d0, d1, d2, d3,
    input [1:0] s,
    output reg [WIDTH-1:0] y
);
    always @(*) begin
        case (s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
            default: y = {WIDTH{1'bx}};
        endcase
    end
endmodule
