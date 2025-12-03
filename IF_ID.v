`timescale 1ns / 1ps
module IF_ID_Reg(
    input clk, reset, en, flush,
    input [31:0] pc_plus4_in, instr_in,
    output reg [31:0] pc_plus4_out, instr_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_plus4_out <= 0;
            instr_out <= 0;
        end else if (en) begin
            pc_plus4_out <= pc_plus4_in;
            instr_out <= instr_in;
        end
    end
endmodule
