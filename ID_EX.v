module ID_EX(
    input         clk, reset, stall,
    input  [31:0] pc_in, rd1_in, rd2_in, imm_in,
    input  [4:0]  rs_in, rt_in, rd_in,
    input         RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in, ALUSrc_in,
    input  [1:0]  ALUOp_in,
    output reg[31:0] pc_out, rd1_out, rd2_out, imm_out,
    output reg[4:0]  rs_out, rt_out, rd_out,
    output reg       RegWrite_out, MemRead_out, MemWrite_out, MemToReg_out, ALUSrc_out,
    output reg[1:0]  ALUOp_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out<=0; rd1_out<=0; rd2_out<=0; imm_out<=0;
            rs_out<=0; rt_out<=0; rd_out<=0;
            RegWrite_out<=0; MemRead_out<=0; MemWrite_out<=0; MemToReg_out<=0; ALUSrc_out<=0; ALUOp_out<=0;
        end else if (!stall) begin
            pc_out<=pc_in; rd1_out<=rd1_in; rd2_out<=rd2_in; imm_out<=imm_in;
            rs_out<=rs_in; rt_out<=rt_in; rd_out<=rd_in;
            RegWrite_out<=RegWrite_in; MemRead_out<=MemRead_in; MemWrite_out<=MemWrite_in;
            MemToReg_out<=MemToReg_in; ALUSrc_out<=ALUSrc_in; ALUOp_out<=ALUOp_in;
        end
    end
endmodule