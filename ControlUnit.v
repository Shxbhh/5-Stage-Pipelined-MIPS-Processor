module ControlUnit(
    input  [5:0] opcode,
    output       RegWrite, MemRead, MemWrite, MemToReg, ALUSrc,
    output [1:0] ALUOp
);
    assign {RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, ALUOp} =
        (opcode==6'h0) ? 6'b1000010 : // R-type
        (opcode==6'h23)? 6'b1011010 : // LW
        (opcode==6'h2B)? 6'b0011000 : // SW
        (opcode==6'h4) ? 6'b0000101 : // BEQ
                         6'b0000000;  // default NOP
endmodule
