flowchart LR
  %% IF stage
  subgraph IF["IF Stage"]
    PC_reg["DFF32 PC_reg"]
    pc_adder["Adder (PC + 4)"]
    CacheI["Cache (unified I/D)"]
    PC_reg --> pc_adder --> PC_next["pc_plus4"]
    PC_reg --> CacheI["addr=pc / read=1"] --> IF_ID_IR["IF_ID_IR DFF"]
    PC_reg --> IF_ID_PC["IF_ID_PC DFF"]
  end

  %% ID stage
  subgraph ID["ID Stage"]
    IF_ID_IR --> Decode["ControlUnit\n(opcode→RegWrite, MemRead, …)"]
    IF_ID_IR --> RF["RegisterFile"]
    IF_ID_IR --> SignExt["SignExt"]
    Decode --> ID_EX_ctrl["ID/EX_CTRL DFF"]
    RF --> ID_EX_RD1["ID/EX_RD1 DFF"]
    RF --> ID_EX_RD2["ID/EX_RD2 DFF"]
    SignExt --> ID_EX_IMM["ID/EX_IMM DFF"]
    IF_ID_PC --> ID_EX_PC["ID/EX_PC DFF"]
    Decode --> Hazard["HazardUnit"]
  end

  %% EX stage
  subgraph EX["EX Stage"]
    ID_EX_RD1 --> FwdA["ForwardingUnit -> sel=fwdA"]
    ID_EX_RD2 --> FwdB["ForwardingUnit -> sel=fwdB"]
    FwdA --> MuxA["Mux4to1 -> opA"]
    FwdB --> MuxB["Mux4to1 -> pre-opB"]
    ID_EX_IMM --> MuxB
    ID_EX_ctrl --> ALUSrc
    MuxB --> MuxB2["Mux2to1 (ALUSrc) -> opB"]
    MuxA & MuxB2 & ID_EX_ctrl --> EX_ALU["EX_Alu"]
    EX_ALU --> EX_MEM_ALU["EX/MEM_ALU DFF"]
    MuxB2 --> EX_MEM_WD["EX/MEM_WD DFF"]
    ID_EX_RD2 --> EX_MEM_WD
    ID_EX_RD --> EX_MEM_RD["EX/MEM_RD DFF"]
    ID_EX_ctrl --> EX_MEM_CTRL["EX/MEM_CTRL DFF"]
  end

  %% MEM stage
  subgraph MEM["MEM Stage"]
    EX_MEM_ALU --> CacheD["Cache (addr=ALU)"]
    EX_MEM_WD --> CacheD
    EX_MEM_CTRL --> CacheD
    CacheD --> MEM_WB_RDATA["MEM/WB_RDATA DFF"]
    EX_MEM_ALU --> MEM_WB_ALU["MEM/WB_ALU DFF"]
    EX_MEM_RD --> MEM_WB_RD["MEM/WB_RD DFF"]
    EX_MEM_CTRL --> MEM_WB_CTRL["MEM/WB_CTRL DFF"]
  end

  %% WB stage
  subgraph WB["WB Stage"]
    MEM_WB_RDATA & MEM_WB_ALU & MEM_WB_CTRL --> WB_MUX["Mux2to1 (MemToReg)"]
    WB_MUX --> RegisterFile
  end

  %% hazard interlock
  Hazard -.-> IF_ID_IR
  Hazard -.-> IF_ID_PC

  style IF fill:#f9f,stroke:#333
  style ID fill:#9ff,stroke:#333
  style EX fill:#ff9,stroke:#333
  style MEM fill:#9f9,stroke:#333
  style WB fill:#99f,stroke:#333


