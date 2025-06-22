module Mux4to1 #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    input  [WIDTH-1:0] in2,
    input  [WIDTH-1:0] in3,
    input  [1:0]       sel,
    output [WIDTH-1:0] out
);
    wire [WIDTH-1:0] m0 = sel[0] ? in1 : in0;
    wire [WIDTH-1:0] m1 = sel[0] ? in3 : in2;
    assign out = sel[1] ? m1 : m0;
endmodule