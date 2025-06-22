module MEM_WB(
    input         clk, reset,
    input  [31:0] rdata_in, alu_in,
    input  [4:0]  rd_in,
    input         RegWrite_in, MemToReg_in,
    output reg[31:0] rdata_out, alu_out,
    output reg[4:0]  rd_out,
    output reg       RegWrite_out, MemToReg_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin rdata_out<=0; alu_out<=0; rd_out<=0; RegWrite_out<=0; MemToReg_out<=0; end
        else begin rdata_out<=rdata_in; alu_out<=alu_in; rd_out<=rd_in; RegWrite_out<=RegWrite_in; MemToReg_out<=MemToReg_in; end
    end
endmodule