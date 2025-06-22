
module Cache #(
    parameter LINE_COUNT  = 256,
    parameter BLOCK_WORDS = 4
)(
    input              clk,
    input              reset,
    // CPU interface
    input      [31:0]  addr,
    input      [31:0]  write_data,
    input              read,
    input              write,
    output reg [31:0]  read_data,
    output             stall_out,
);


    // Cache storage
    reg [31:0] tags    [LINE_COUNT-1:0];
    reg        valid   [LINE_COUNT-1:0];
    reg        dirty   [LINE_COUNT-1:0];
    reg [31:0] data_blk[LINE_COUNT-1:0][BLOCK_WORDS-1:0];

    // FSM states
    localparam IDLE      = 2'b00,
               WRITEBACK = 2'b01,
               REFILL    = 2'b10;

    reg [1:0]  state;
    integer    i;
    integer    idx;
    integer    off;

    // On reset, invalidate all lines
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            for (i = 0; i < LINE_COUNT; i = i + 1) begin
                valid[i] <= 1'b0;
                dirty[i] <= 1'b0;
            end
        end else begin
            idx = addr[BLOCK_WORDS*2+1:2] % LINE_COUNT;
            off = addr[3:2];

            case (state)
            IDLE: begin
                if (read || write) begin
                    if (valid[idx] && tags[idx] == addr[31:BLOCK_WORDS*2+2]) begin
                        // HIT
                        if (read)  read_data <= data_blk[idx][off];
                        if (write) begin
                            data_blk[idx][off] <= write_data;
                            dirty[idx]        <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        // MISS → go to WRITEBACK if needed, else REFILL
                        if (dirty[idx])
                            state <= WRITEBACK;
                        else
                            state <= REFILL;
                    end
                end
            end

            WRITEBACK: begin
                // Write back entire block to memory
                // for (i = 0; i < BLOCK_WORDS; i = i + 1) begin
                //     mem_addr  <= {tags[idx], idx, i};
                //     mem_wdata <= data_blk[idx][i];
                //     mem_write <= 1;
                // end
                dirty[idx] <= 1'b0;
                state      <= REFILL;
            end

            REFILL: begin
                // Fetch new block from memory
                // for (i = 0; i < BLOCK_WORDS; i = i + 1) begin
                //     mem_addr <= {addr[31:BLOCK_WORDS*2+2], idx, i};
                //     mem_read <= 1;
                //     data_blk[idx][i] <= mem_rdata;
                // end
                tags[idx]  <= addr[31:BLOCK_WORDS*2+2];
                valid[idx] <= 1'b1;
                dirty[idx] <= write;               // allocate-on-write
                // Deliver the requested word
                read_data  <= data_blk[idx][off];
                state      <= IDLE;
            end

            default: state <= IDLE;
            endcase
        end
    end

    assign stall_out = (state != IDLE);

endmodule

