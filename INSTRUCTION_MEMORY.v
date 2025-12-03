`timescale 1ns / 1ps
module InstructionMemory(
    input [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];
    
    initial begin
        $readmemb("instrucciones.txt", mem);
    end
    
    assign instr = mem[addr >> 2];
endmodule
