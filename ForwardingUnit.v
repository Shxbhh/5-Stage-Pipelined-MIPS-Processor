module ForwardingUnit(
    input         EX_MEM_RegWrite, MEM_WB_RegWrite,
    input  [4:0]  EX_MEM_Rd, MEM_WB_Rd,
    input  [4:0]  ID_EX_Rs, ID_EX_Rt,
    output [1:0]  ForwardA, ForwardB
);
    assign ForwardA = (EX_MEM_RegWrite && EX_MEM_Rd!=0 && EX_MEM_Rd==ID_EX_Rs)?2'b10:
                      (MEM_WB_RegWrite && MEM_WB_Rd!=0 && MEM_WB_Rd==ID_EX_Rs)?2'b01:2'b00;
    assign ForwardB = (EX_MEM_RegWrite && EX_MEM_Rd!=0 && EX_MEM_Rd==ID_EX_Rt)?2'b10:
                      (MEM_WB_RegWrite && MEM_WB_Rd!=0 && MEM_WB_Rd==ID_EX_Rt)?2'b01:2'b00;
endmodule
