`timescale 1ns / 1ps
module EX(
    input  [31:0] A, B, Imm,
    input         ALUSrc,
    input  [1:0]  ALUOp,
    input  [1:0]  ForwardA, ForwardB,
    output reg[31:0] Result, WData,
    output reg[4:0]  Rd
);
    wire [31:0] opA = (ForwardA==2'b10 ? exmem_alu :
                       ForwardA==2'b01 ? memwb_wdata : A);
    wire [31:0] opB0= (ForwardB==2'b10 ? exmem_alu :
                       ForwardB==2'b01 ? memwb_wdata : B);
    wire [31:0] opB  = ALUSrc ? Imm : opB0;
    always @(*) begin
        case(ALUOp)
            2'b00: Result = opA + opB;  // LW/SW
            2'b01: Result = opA - opB;  // BEQ
            2'b10: // R-type
                case(Imm[5:0])
                    6'h20: Result = opA + opB; // ADD
                    6'h22: Result = opA - opB; // SUB
                    default: Result = 0;
                endcase
            default: Result = 0;
        endcase
        WData = opB0;
        Rd    = Imm[15:11]; // rd field
    end
endmodule
