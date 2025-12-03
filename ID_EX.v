`timescale 1ns / 1ps
module ID_EX_Reg(
    input clk, reset, flush,

    input reg_write_in, mem_to_reg_in, mem_write_in, alu_src_in,
    input [2:0] alu_op_in,
 
    input [31:0] pc_plus4_in, rd1_in, rd2_in, sign_ext_in,
    input [4:0] rs_in, rt_in, rd_in,
  
    output reg reg_write_out, mem_to_reg_out, mem_write_out, alu_src_out,
    output reg [2:0] alu_op_out,
    output reg [31:0] pc_plus4_out, rd1_out, rd2_out, sign_ext_out,
    output reg [4:0] rs_out, rt_out, rd_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; mem_write_out <= 0;
            alu_src_out <= 0; alu_op_out <= 0;
            pc_plus4_out <= 0; rd1_out <= 0; rd2_out <= 0; sign_ext_out <= 0;
            rs_out <= 0; rt_out <= 0; rd_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in; alu_op_out <= alu_op_in;
            pc_plus4_out <= pc_plus4_in; rd1_out <= rd1_in; rd2_out <= rd2_in; sign_ext_out <= sign_ext_in;
            rs_out <= rs_in; rt_out <= rt_in; rd_out <= rd_in;
        end
    end
endmodule
