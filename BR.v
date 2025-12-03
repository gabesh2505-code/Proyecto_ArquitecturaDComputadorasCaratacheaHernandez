`timescale 1ns / 1ps
module RegisterFile(
    input clk, reset, we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] rf [0:31];
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) rf[i] <= 0;
        end else if (we && wa != 0) begin
            rf[wa] <= wd;
        end
    end
    
    assign rd1 = (ra1 == 0) ? 0 : rf[ra1];
    assign rd2 = (ra2 == 0) ? 0 : rf[ra2];
endmodule
