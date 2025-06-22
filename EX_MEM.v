module EX_MEM(
    input         clk, reset,
    input  [31:0] alu_in, wdata_in,
    input  [4:0]  rd_in,
    input         RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in,
    output reg[31:0] alu_out, wdata_out,
    output reg[4:0]  rd_out,
    output reg       RegWrite_out, MemRead_out, MemWrite_out, MemToReg_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin alu_out<=0; wdata_out<=0; rd_out<=0; RegWrite_out<=0; MemRead_out<=0; MemWrite_out<=0; MemToReg_out<=0; end
        else begin alu_out<=alu_in; wdata_out<=wdata_in; rd_out<=rd_in; RegWrite_out<=RegWrite_in; MemRead_out<=MemRead_in; MemWrite_out<=MemWrite_in; MemToReg_out<=MemToReg_in; end
    end
endmodule