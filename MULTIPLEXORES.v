`timescale 1ns / 1ps
module Mux2(
    input [31:0] d0, d1,
    input s,
    output [31:0] y
);
    assign y = (s) ? d1 : d0;
endmodule
