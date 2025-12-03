`timescale 1ns / 1ps
module Mux3(
    input [31:0] d0, d1, d2,
    input [1:0] s,
    output reg [31:0] y
);
    always @(*) begin
        case(s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = 32'bx;
        endcase
    end
endmodule
