`timescale 1ns / 1ps
module testbench;
    reg clk;
    reg reset;
    
    mips_pipeline uut (.clk(clk), .reset(reset));

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        reset = 1;
        #20;
        reset = 0;
        
        $display("--- Start Simulation ---");
        
        #6000; 
        
        $display("--- Check Memory Results ---");
        $display("Result[0]: %d (Expected: 2)", uut.DM.mem[10]);
        $display("Result[1]: %d (Expected: 0)", uut.DM.mem[11]);
        $display("Result[2]: %d (Expected: 2)", uut.DM.mem[12]);
        $display("Result[3]: %d (Expected: 1)", uut.DM.mem[13]);
        $display("Result[4]: %d (Expected: 0)", uut.DM.mem[14]);
        
        $stop;
    end
endmodule
