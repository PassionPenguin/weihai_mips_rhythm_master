// flop.v, flopen, flopenr simple storage elements
`timescale 1ns/1ps
module flop #(parameter WIDTH = 32)(
    input clk,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) q <= d;
endmodule

module flopen #(parameter WIDTH = 32)(
    input clk, en,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) if (en) q <= d;
endmodule

module flopenr #(parameter WIDTH = 32)(
    input clk, reset, en,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else if (en) q <= d;
    end
endmodule
