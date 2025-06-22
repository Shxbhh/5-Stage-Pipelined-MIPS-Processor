# 5-Stage Pipelined MIPS Processor

This repository implements a classic 5-stage pipelined MIPS processor in pure Verilog. It features instruction fetch, decode, execute, memory access, and writeback stages, along with hazard detection and simple forwarding to handle data hazards.

---

## 🚀 Features

* **Standard 5-Stage Pipeline**: IF → ID → EX → MEM → WB
* **Detailed Processor Operation**: Step-by-step execution flow explained below
* **Hazard Detection & Forwarding**: Resolves control and data hazards
* **Control Unit**: Supports Arithmetic, Logic, Load/Store, Branch, and Jump instructions
* **Register File**: 32×32-bit registers with two read ports and one write port
* **Parameterizable Memories**: Easily swap in custom instruction/data memories
* **Testbench Included**: Basic instruction sequence to verify functionality

---

## 🏗 Processor Architecture & Operation

The 5-stage pipeline breaks instruction execution into five distinct steps. Each stage operates concurrently on different instructions, increasing throughput by overlapping tasks.

1. **Instruction Fetch (IF)**

   * **PC Register**: Holds address of current instruction.
   * **Instruction Memory**: Stores program; indexed by PC.
   * **PC Incrementer**: PC + 4 for sequential execution, or branch target if a branch is taken.

2. **Instruction Decode (ID)**

   * **Register File Read**: Reads source registers based on instruction fields `rs` and `rt`.
   * **Immediate Sign-Extension**: Extends 16-bit immediate values to 32 bits.
   * **Control Unit**: Generates control signals (ALUOp, MemRead, MemWrite, RegWrite, etc.) based on the opcode and function fields.

3. **Execute (EX)**

   * **ALU Operations**: Performs arithmetic or logical operations based on ALU control signals.
   * **Forwarding Logic**: Bypasses data from later pipeline stages to the ALU inputs to resolve data hazards without stalling.
   * **Branch Target Calculation**: Computes target address for branch instructions (`PC + 4 + (imm << 2)`).

4. **Memory Access (MEM)**

   * **Data Memory Read/Write**: For load/store instructions, accesses data memory.
   * **Hazard Detection**: Inserts stalls when a load-use hazard is detected (the next instruction needs data being loaded).

5. **Writeback (WB)**

   * **Register Write**: Writes ALU result or loaded data back into the register file if `RegWrite` is asserted.

### Pipeline Control & Hazard Handling

* **Control Hazards (Branches/Jumps)**:

  * Branch decision and target address are resolved in EX stage.
  * On a taken branch, instructions in IF/ID are flushed to avoid executing incorrect instructions.

* **Data Hazards**:

  * **Forwarding Unit**: Detects when EX stage inputs depend on values yet to be written back and forwards them directly.
  * **Hazard Detection Unit**: Inserts a single-cycle stall when a load instruction is followed by an instruction that uses its result.

---

## 📂 Repository Structure

```
├── src/                     # Verilog source files
│   ├── MIPS_Processor.v     # Top-level module orchestrating pipeline
│   ├── IF.v                 # Instruction Fetch stage
│   ├── ID.v                 # Instruction Decode stage
│   ├── EX.v                 # Execute stage
│   ├── MEM.v                # Memory Access stage
│   ├── WB.v                 # Writeback stage
│   ├── HazardUnit.v         # Hazard detection logic
│   ├── ForwardUnit.v        # Forwarding logic
│   ├── ControlUnit.v        # Main control signal generator
│   └── RegFile.v            # Register file implementation
│
├── tb/                      # Testbench files
│   └── tb_mips.v            # Top-level testbench
│
├── constraints/             # Pin constraints for FPGA boards
│   └── Constraints.xdc           # Basys-3 (XC7A35T) constraints
│
│
└── README.md                # (This file)
