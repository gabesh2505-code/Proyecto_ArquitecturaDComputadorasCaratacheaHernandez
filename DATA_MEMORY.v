`timescale 1ns / 1ps
module DataMemory(
    input clk, mem_write,
    input [31:0] addr, write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:127];
    integer i;
    
    initial begin
        for(i=0; i<128; i=i+1) mem[i] = 0;
       
        mem[0]=15; mem[1]=20; mem[2]=10; mem[3]=5; mem[4]=-1;
     
        mem[5]=12; mem[6]=20; mem[7]=8; mem[8]=1; mem[9]=-1;
       
        mem[15]=5;
    end
    
    always @(posedge clk) begin
        if (mem_write) mem[addr >> 2] <= write_data;
    end
    
    assign read_data = mem[addr >> 2];
endmodule
