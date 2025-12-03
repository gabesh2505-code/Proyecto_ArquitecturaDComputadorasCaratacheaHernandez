`timescale 1ns / 1ps
module ALUControl(
    input [2:0] alu_op,
    input [5:0] funct,
    output reg [3:0] alu_action
);
    always @(*) begin
        case(alu_op)
            3'b000: alu_action = 4'b0010; 
            3'b001: alu_action = 4'b0110;
            3'b011: alu_action = 4'b0000; 
            3'b010: case(funct)
                6'b100000: alu_action = 4'b0010; 
                6'b100010: alu_action = 4'b0110; 
                6'b100100: alu_action = 4'b0000; 
                6'b100101: alu_action = 4'b0001; 
                6'b100110: alu_action = 4'b0100; 
                6'b000010: alu_action = 4'b1000; 
                default:   alu_action = 4'b0010;
            endcase
            default: alu_action = 4'b0000;
        endcase
    end
endmodule