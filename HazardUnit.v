`timescale 1ns / 1ps
module HazardUnit(
    input id_ex_mem_read,
    input [4:0] id_ex_rt,
    input [4:0] if_id_rs, if_id_rt,
    output reg pc_write, if_id_write, stall_mux
);
    always @(*) begin
       
        if (id_ex_mem_read && ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            stall_mux = 1;
            pc_write = 0;
            if_id_write = 0;
        end else begin
            stall_mux = 0;
            pc_write = 1;
            if_id_write = 1;
        end
    end
endmodule
