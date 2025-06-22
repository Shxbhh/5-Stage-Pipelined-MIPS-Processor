module MIPS_Processor(
    input         clk,
    input         reset
);
    // ---------------------
    // IF Stage: PC + Adder
    // ---------------------
    wire [31:0] pc, pc_plus4;
    DFF PC_reg [31:0](.clk(clk), .reset(reset), .d(pc_plus4), .q(pc));
    Adder pc_adder(.a(pc), .b(32'd4), .sum(pc_plus4));

    // InstrucStion Fetch via Cache
    wire [31:0] instr;
    wire [31:0] cache_addr = pc;
    wire        cache_read  = 1'b1;
    wire        cache_write = 1'b0;
    wire [31:0] cache_wdata = 32'b0;
    wire        stall_cache;
    Cache cache(.clk(clk), .reset(reset), .addr(cache_addr), .read(cache_read), .write(cache_write), .write_data(cache_wdata), .read_data(instr), .stall_out(stall_cache));

    // IF/ID Pipeline Registers
    wire [31:0] if_id_pc, if_id_instr;
    DFF IF_ID_PC   [31:0](.clk(clk), .reset(reset), .d(pc),    .q(if_id_pc));
    DFF IF_ID_IR   [31:0](.clk(clk), .reset(reset), .d(instr), .q(if_id_instr));

    // ---------------------
    // ID Stage: Decode, Register File, Sign Extend
    // ---------------------
    wire [5:0]  opcode = if_id_instr[31:26];
    wire [4:0]  rs     = if_id_instr[25:21];
    wire [4:0]  rt     = if_id_instr[20:16];
    wire [4:0]  rd     = if_id_instr[15:11];
    wire [15:0] imm16  = if_id_instr[15:0];

    // Control Signals
    wire        RegWrite, MemRead, MemWrite, MemToReg, ALUSrc;
    wire [1:0]  ALUOp;
    ControlUnit ctrl(.opcode(opcode), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg), .ALUSrc(ALUSrc), .ALUOp(ALUOp));

    // Register File
    wire [31:0] rd1, rd2;
    RegisterFile rf(.clk(clk), .RegWrite(memwb_RegWrite), .rs(rs), .rt(rt), .rd(memwb_rd), .wd(memwb_wdata), .rd1(rd1), .rd2(rd2));

    // Sign Extend
    wire [31:0] signext_imm;
    SignExt se(.in(imm16), .out(signext_imm));

    // Hazard Detection
    wire stall_hz;
    HazardUnit hz(.ID_EX_MemRead(idex_MemRead), .ID_EX_Rt(idex_rt), .IF_ID_Rs(rs), .IF_ID_Rt(rt), .stall(stall_hz));

    // Stall IF on cache miss or hazard
    wire stall_if = stall_cache || stall_hz;
    assign /* prevent register update */ ;

    // ---------------------
    // ID/EX Pipeline Registers (DFF arrays)
    // ---------------------
    wire [31:0] idex_pc, idex_rd1, idex_rd2, idex_imm;
    wire [4:0]  idex_rs, idex_rt, idex_rd;
    wire [6:0]  idex_ctrl;
    assign idex_ctrl = {RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, ALUOp};
    DFF IDEX_PC   [31:0](.clk(clk), .reset(reset), .d(if_id_pc),    .q(idex_pc));
    DFF IDEX_RD1  [31:0](.clk(clk), .reset(reset), .d(rd1),         .q(idex_rd1));
    DFF IDEX_RD2  [31:0](.clk(clk), .reset(reset), .d(rd2),         .q(idex_rd2));
    DFF IDEX_IMM  [31:0](.clk(clk), .reset(reset), .d(signext_imm), .q(idex_imm));
    DFF IDEX_RS   [4:0](.clk(clk), .reset(reset), .d(rs),           .q(idex_rs));
    DFF IDEX_RT   [4:0](.clk(clk), .reset(reset), .d(rt),           .q(idex_rt));
    DFF IDEX_RD   [4:0](.clk(clk), .reset(reset), .d(rd),           .q(idex_rd));
    DFF IDEX_CTRL [6:0](.clk(clk), .reset(reset), .d(idex_ctrl),   .q(idex_ctrl));

    // Control signals unpack
    wire idex_RegWrite = idex_ctrl[6];
    wire idex_MemRead  = idex_ctrl[5];
    wire idex_MemWrite = idex_ctrl[4];
    wire idex_MemToReg = idex_ctrl[3];
    wire idex_ALUSrc   = idex_ctrl[2];
    wire [1:0] idex_ALUOp = idex_ctrl[1:0];

    // ---------------------
    // EX Stage: ALU + Forwarding (Mux4to1)
    // ---------------------
    wire [1:0] fwdA, fwdB;
    ForwardingUnit fwd(.EX_MEM_RegWrite(exmem_RegWrite), .EX_MEM_Rd(exmem_rd), .MEM_WB_RegWrite(memwb_RegWrite), .MEM_WB_Rd(memwb_rd), .ID_EX_Rs(idex_rs), .ID_EX_Rt(idex_rt), .ForwardA(fwdA), .ForwardB(fwdB));

    // Mux for operand A
    wire [31:0] ex_opA0 = idex_rd1;
    wire [31:0] ex_opA1 = memwb_wdata;
    wire [31:0] ex_opA2 = exmem_alu;
    wire [31:0] ex_opA = Mux4to1 #(.WIDTH(32)) muxA(.in0(ex_opA0), .in1(ex_opA1), .in2(ex_opA2), .in3(32'b0), .sel(fwdA), .out());

    // Mux for operand B
    wire [31:0] ex_opB0 = idex_rd2;
    wire [31:0] ex_opB1 = memwb_wdata;
    wire [31:0] ex_opB2 = exmem_alu;
    wire [31:0] ex_opB_pre = Mux4to1 #(.WIDTH(32)) muxB(.in0(ex_opB0), .in1(ex_opB1), .in2(ex_opB2), .in3(32'b0), .sel(fwdB), .out());
    wire [31:0] ex_opB = idex_ALUSrc ? idex_imm : ex_opB_pre;

    wire [31:0] ex_aluout;
    EX_Alu ex_alu(.A(ex_opA), .B(ex_opB), .ALUOp(idex_ALUOp), .Result(ex_aluout));

    // Destination register
    wire [4:0] ex_rd = idex_rd;

    // ---------------------
    // EX/MEM Pipeline Registers
    // ---------------------
    wire [31:0] exmem_alu, exmem_wd;
    wire [4:0]  exmem_rd;
    wire [3:0]  exmem_ctrl;
    assign exmem_ctrl = {idex_RegWrite, idex_MemRead, idex_MemWrite, idex_MemToReg};
    DFF EXMEM_ALU   [31:0](.clk(clk), .reset(reset), .d(ex_aluout), .q(exmem_alu));
    DFF EXMEM_WD    [31:0](.clk(clk), .reset(reset), .d(ex_opB_pre), .q(exmem_wd));
    DFF EXMEM_RD    [4:0](.clk(clk), .reset(reset), .d(ex_rd),      .q(exmem_rd));
    DFF EXMEM_CTRL  [3:0](.clk(clk), .reset(reset), .d(exmem_ctrl), .q(exmem_ctrl));

    wire exmem_RegWrite = exmem_ctrl[3];
    wire exmem_MemRead  = exmem_ctrl[2];
    wire exmem_MemWrite = exmem_ctrl[1];
    wire exmem_MemToReg = exmem_ctrl[0];

    // ---------------------
    // MEM Stage: Cache Access
    // ---------------------
    wire [31:0] mem_rdata;
    Cache dcache(.clk(clk), .reset(reset), .addr(exmem_alu), .read(exmem_MemRead), .write(exmem_MemWrite), .write_data(exmem_wd), .read_data(mem_rdata), .stall_out());

    // ---------------------
    // MEM/WB Pipeline Registers
    // ---------------------
    wire [31:0] memwb_rdata, memwb_alu;
    wire [4:0]  memwb_rd;
    wire [1:0]  memwb_ctrl;
    assign memwb_ctrl = {exmem_RegWrite, exmem_MemToReg};
    DFF MEMWB_RD    [4:0](.clk(clk), .reset(reset), .d(exmem_rd),    .q(memwb_rd));
    DFF MEMWB_ALU   [31:0](.clk(clk), .reset(reset), .d(exmem_alu),  .q(memwb_alu));
    DFF MEMWB_RDATA [31:0](.clk(clk), .reset(reset), .d(mem_rdata),  .q(memwb_rdata));
    DFF MEMWB_CTRL  [1:0](.clk(clk), .reset(reset), .d(memwb_ctrl), .q(memwb_ctrl));

    wire memwb_RegWrite = memwb_ctrl[1];
    wire memwb_MemToReg = memwb_ctrl[0];

    // ---------------------
    // WB Stage: Writeback Multiplexer
    // ---------------------
    wire [31:0] memwb_wdata = memwb_MemToReg ? memwb_rdata : memwb_alu;

endmodule

    
