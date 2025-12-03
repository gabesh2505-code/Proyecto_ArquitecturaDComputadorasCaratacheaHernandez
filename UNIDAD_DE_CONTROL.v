`timescale 1ns / 1ps
module ControlUnit(
    input [5:0] opcode,
    input stall,
    output reg reg_write, mem_to_reg, mem_write, alu_src, branch, jump,
    output reg [2:0] alu_op
);
    always @(*) begin
        if (stall) {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = 0;
        else case(opcode)
            6'b000000: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010}; // R-type
            6'b100011: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000}; // LW
            6'b101011: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 3'b000}; // SW
            6'b000100: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 3'b001}; // BEQ
            6'b001000: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000}; // ADDI
            6'b001100: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b011}; // ANDI
            6'b000010: {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 3'b000}; // J
            default:   {reg_write, mem_to_reg, mem_write, alu_src, branch, jump, alu_op} = 0;
        endcase
    end
endmodule