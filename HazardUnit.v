module HazardUnit(
    input        ID_EX_MemRead,
    input  [4:0] ID_EX_Rt,
    input  [4:0] IF_ID_Rs,
    input  [4:0] IF_ID_Rt,
    output       stall
);
    assign stall = ID_EX_MemRead &&
                   ((ID_EX_Rt==IF_ID_Rs)||(ID_EX_Rt==IF_ID_Rt));
endmodule