`timescale 1ns / 1ps

module mips_pipeline(
    input clk,
    input reset
);
    
    wire [31:0] pc_in, pc_out, pc_plus4, instr;
    wire pc_write_en;
    
    
    wire [31:0] if_id_pc4, if_id_instr;
    wire if_id_write_en, flush;
    
    
    wire [31:0] rd1, rd2, sign_ext, branch_addr_sl2, branch_target, jump_target;
    wire [4:0] rs, rt, rd;
    wire [5:0] opcode, funct;
    wire ctrl_mux;
    wire reg_write_d, mem_to_reg_d, mem_write_d, alu_src_d, branch_d, jump_d;
    wire [2:0] alu_op_d;
    wire branch_taken;

    
    wire reg_write_e, mem_to_reg_e, mem_write_e, alu_src_e;
    wire [2:0] alu_op_e;
    wire [31:0] pc4_e, rd1_e, rd2_e, sign_ext_e;
    wire [4:0] rs_e, rt_e, rd_e;
    
    
    wire [31:0] alu_in_a, alu_in_b, alu_src_b_imm, alu_res;
    wire [4:0] write_reg_e;
    wire [3:0] alu_ctrl;
    wire [1:0] fwd_a, fwd_b;
    wire [31:0] fwd_val_a, fwd_val_b;

    
    wire reg_write_m, mem_to_reg_m, mem_write_m;
    wire [31:0] alu_res_m, write_data_m;
    wire [4:0] write_reg_m;
    
   
    wire [31:0] read_data_m;

    
    wire reg_write_w, mem_to_reg_w;
    wire [31:0] read_data_w, alu_res_w;
    wire [4:0] write_reg_w;

    
    wire [31:0] result_w;

    
    ProgramCounter PC (.clk(clk), .reset(reset), .en(pc_write_en), .in(pc_in), .out(pc_out));
    Adder AddPC (.a(pc_out), .b(32'd4), .y(pc_plus4));
    InstructionMemory IM (.addr(pc_out), .instr(instr));
   
    wire [31:0] branch_mux_out;
    Mux2 MuxBranch (.d0(pc_plus4), .d1(branch_target), .s(branch_taken), .y(branch_mux_out));
    Mux2 MuxJump   (.d0(branch_mux_out), .d1(jump_target), .s(jump_d), .y(pc_in));

    
    IF_ID_Reg IF_ID (
        .clk(clk), .reset(reset), .en(if_id_write_en), .flush(flush),
        .pc_plus4_in(pc_plus4), .instr_in(instr),
        .pc_plus4_out(if_id_pc4), .instr_out(if_id_instr)
    );

    
    assign opcode = if_id_instr[31:26];
    assign rs = if_id_instr[25:21];
    assign rt = if_id_instr[20:16];
    assign rd = if_id_instr[15:11];
    assign funct = if_id_instr[5:0];

    ControlUnit CU (
        .opcode(opcode), .stall(ctrl_mux),
        .reg_write(reg_write_d), .mem_to_reg(mem_to_reg_d), .mem_write(mem_write_d),
        .alu_src(alu_src_d), .branch(branch_d), .jump(jump_d), .alu_op(alu_op_d)
    );

    RegisterFile RF (
        .clk(clk), .reset(reset), .ra1(rs), .ra2(rt), .wa(write_reg_w),
        .wd(result_w), .we(reg_write_w), .rd1(rd1), .rd2(rd2)
    );

    SignExtend SE (.in(if_id_instr[15:0]), .out(sign_ext));
    
    
    ShiftLeft2 SL2 (.in(sign_ext), .out(branch_addr_sl2));
    Adder AddBranch (.a(if_id_pc4), .b(branch_addr_sl2), .y(branch_target));
    assign jump_target = {if_id_pc4[31:28], if_id_instr[25:0], 2'b00};
    assign branch_taken = (rd1 == rd2) && branch_d;
    assign flush = jump_d || branch_taken;

    HazardUnit HDU (
        .id_ex_mem_read(mem_to_reg_e), .id_ex_rt(rt_e),
        .if_id_rs(rs), .if_id_rt(rt),
        .pc_write(pc_write_en), .if_id_write(if_id_write_en), .stall_mux(ctrl_mux)
    );

    
    ID_EX_Reg ID_EX (
        .clk(clk), .reset(reset), .flush(flush),
        .reg_write_in(reg_write_d), .mem_to_reg_in(mem_to_reg_d), .mem_write_in(mem_write_d),
        .alu_src_in(alu_src_d), .alu_op_in(alu_op_d),
        .pc_plus4_in(if_id_pc4), .rd1_in(rd1), .rd2_in(rd2), .sign_ext_in(sign_ext),
        .rs_in(rs), .rt_in(rt), .rd_in(rd),
        
        .reg_write_out(reg_write_e), .mem_to_reg_out(mem_to_reg_e), .mem_write_out(mem_write_e),
        .alu_src_out(alu_src_e), .alu_op_out(alu_op_e),
        .rd1_out(rd1_e), .rd2_out(rd2_e), .sign_ext_out(sign_ext_e),
        .rs_out(rs_e), .rt_out(rt_e), .rd_out(rd_e)
    );

    
    Mux3 MuxFwdA (.d0(rd1_e), .d1(result_w), .d2(alu_res_m), .s(fwd_a), .y(fwd_val_a));
    Mux3 MuxFwdB (.d0(rd2_e), .d1(result_w), .d2(alu_res_m), .s(fwd_b), .y(fwd_val_b));
    
    
    Mux2 MuxAluSrc (.d0(fwd_val_b), .d1(sign_ext_e), .s(alu_src_e), .y(alu_src_b_imm));
    
    ALUControl ALU_Ctrl (.alu_op(alu_op_e), .funct(sign_ext_e[5:0]), .alu_action(alu_ctrl));
    ALU MainALU (.a(fwd_val_a), .b(alu_src_b_imm), .control(alu_ctrl), .result(alu_res));
    
 
    Mux2_5bits MuxDstReg (.d0(rt_e), .d1(rd_e), .s((rd_e != 0)), .y(write_reg_e)); // Simplificado para R-type vs I-type

    ForwardingUnit FWU (
        .id_ex_rs(rs_e), .id_ex_rt(rt_e),
        .ex_mem_rd(write_reg_m), .ex_mem_reg_write(reg_write_m),
        .mem_wb_rd(write_reg_w), .mem_wb_reg_write(reg_write_w),
        .forward_a(fwd_a), .forward_b(fwd_b)
    );

    
    EX_MEM_Reg EX_MEM (
        .clk(clk), .reset(reset),
        .reg_write_in(reg_write_e), .mem_to_reg_in(mem_to_reg_e), .mem_write_in(mem_write_e),
        .alu_res_in(alu_res), .write_data_in(fwd_val_b), .write_reg_in(write_reg_e),
        
        .reg_write_out(reg_write_m), .mem_to_reg_out(mem_to_reg_m), .mem_write_out(mem_write_m),
        .alu_res_out(alu_res_m), .write_data_out(write_data_m), .write_reg_out(write_reg_m)
    );

    
    DataMemory DM (
        .clk(clk), .mem_write(mem_write_m),
        .addr(alu_res_m), .write_data(write_data_m),
        .read_data(read_data_m)
    );

   
    MEM_WB_Reg MEM_WB (
        .clk(clk), .reset(reset),
        .reg_write_in(reg_write_m), .mem_to_reg_in(mem_to_reg_m),
        .read_data_in(read_data_m), .alu_res_in(alu_res_m), .write_reg_in(write_reg_m),
        
        .reg_write_out(reg_write_w), .mem_to_reg_out(mem_to_reg_w),
        .read_data_out(read_data_w), .alu_res_out(alu_res_w), .write_reg_out(write_reg_w)
    );

    
    Mux2 MuxWB (.d0(alu_res_w), .d1(read_data_w), .s(mem_to_reg_w), .y(result_w));

endmodule