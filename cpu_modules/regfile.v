// regfile.v: 32 registers x WIDTH bits. reg 0 hardwired to 0.
`timescale 1ns/1ps
module regfile #(parameter WIDTH = 32, REGBITS = 5)(
    input clk,
    input regwrite,
    input [REGBITS-1:0] ra1, ra2, wa,
    input [WIDTH-1:0] wd,
    output [WIDTH-1:0] rd1, rd2
);
    localparam N = (1<<REGBITS);
    reg [WIDTH-1:0] RAM [0:N-1];

    integer i;
    initial begin
        for (i=0;i<N;i=i+1) RAM[i] = {WIDTH{1'b0}};
    end

    always @(posedge clk) begin
        if (regwrite && |wa) RAM[wa] <= wd; // do not write register 0
    end

    assign rd1 = ra1 ? RAM[ra1] : {WIDTH{1'b0}};
    assign rd2 = ra2 ? RAM[ra2] : {WIDTH{1'b0}};
endmodule
