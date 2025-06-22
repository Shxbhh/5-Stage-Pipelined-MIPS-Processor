module Decoder #(
    parameter IN_WIDTH  = 5,
    parameter OUT_WIDTH = 32
)(
    input  [IN_WIDTH-1:0] in,
    input                 en,
    output [OUT_WIDTH-1:0] out
);
    reg [OUT_WIDTH-1:0] tmp;
    integer i;
    always @(*) begin
        tmp = {OUT_WIDTH{1'b0}};
        if (en) begin
            for (i = 0; i < OUT_WIDTH; i = i + 1) begin
                if (i == in)
                    tmp[i] = 1'b1;
            end
        end
    end
    assign out = tmp;
endmodule