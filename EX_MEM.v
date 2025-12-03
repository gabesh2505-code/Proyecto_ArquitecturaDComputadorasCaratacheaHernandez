`timescale 1ns / 1ps
module EX_MEM_Reg(
    input clk, reset,
    input reg_write_in, mem_to_reg_in, mem_write_in,
    input [31:0] alu_res_in, write_data_in,
    input [4:0] write_reg_in,
    output reg reg_write_out, mem_to_reg_out, mem_write_out,
    output reg [31:0] alu_res_out, write_data_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; mem_write_out <= 0;
            alu_res_out <= 0; write_data_out <= 0; write_reg_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; mem_write_out <= mem_write_in;
            alu_res_out <= alu_res_in; write_data_out <= write_data_in; write_reg_out <= write_reg_in;
        end
    end
endmodule
