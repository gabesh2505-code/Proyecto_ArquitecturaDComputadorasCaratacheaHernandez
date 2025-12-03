`timescale 1ns / 1ps
module ProgramCounter(
    input clk, reset, en,
    input [31:0] in,
    output reg [31:0] out
);
    always @(posedge clk or posedge reset) begin
        if (reset) out <= 0;
        else if (en) out <= in;
    end
endmodule
