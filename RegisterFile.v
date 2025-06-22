module RegisterFile(
    input         clk, RegWrite,
    input  [4:0]  rs, rt, rd,
    input  [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] regs[31:0];
    assign rd1 = regs[rs];
    assign rd2 = regs[rt];
    always @(posedge clk) if (RegWrite && rd!=0) regs[rd] <= wd;
endmodule