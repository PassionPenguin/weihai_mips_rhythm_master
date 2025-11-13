// zerodetect.v: simple zero-detection helper used by datapath
`timescale 1ns/1ps
module zerodetect #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] in,
    output             zero
);
    // Assert 'zero' when input is all zeros
    assign zero = (in == {WIDTH{1'b0}});
endmodule
