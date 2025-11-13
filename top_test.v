// top_test.v: simple testbench that instantiates mips32 and exmemory
`timescale 1ns/1ps
module top_test();
    reg clk;
    reg reset;
    wire memread, memwrite;
    wire [31:0] adr, writedata;
    wire [31:0] memdata;

    // instantiate DUT
    mips32 dut(clk, reset, memdata, memread, memwrite, adr, writedata);

    // instantiate external memory
    exmemory #(32) exmem(clk, memwrite, adr, writedata, memdata);

    initial begin
        reset <= 1; #22; reset <= 0;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(negedge clk) begin
        if (memwrite) begin
            $display("[%0t] MEMWRITE adr=%h data=%h", $time, adr, writedata);
        end
    end

    // simple termination: if memory at address 4 gets value 7
    always @(negedge clk) begin
        if (memwrite) begin
            if (adr == 32'h4 && writedata == 32'h7) begin
                $display("Simulation completely successful");
                $finish;
            end
        end
    end
endmodule
