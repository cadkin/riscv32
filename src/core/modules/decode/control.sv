`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
// Revised:
//   November 20, 2018
//
// Module name: Control
// Description:
//   Implements the RISC-V control logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   opcode -- 7-bit opcode field from the 32-bit instruction
//   funct3 -- 3-bit funct3 field from the 32-bit instruction
//   funct7 -- 7-bit funct7 field from the 32-bit instruction
//   ins_zero --
//   flush --
//   hazard --
// Output:
//   alusel2 --
//   alusel1 --
//   alusel0 --
//   addb --
//   rightb --
//   logicb --
//   branch --
//   memwrite --
//   memread --
//   regwrite --
//   alusrc --
//   compare --
//   jal --
//   jalr --
//
//////////////////////////////////////////////////////////////////////////////////

module control (
    input  logic        clk,
    input  logic [ 6:0] opcode,
    input  logic [ 2:0] funct3,
    input  logic [ 6:0] funct7,
    input  logic [11:0] funct12,
    input  logic        ins_zero,
    input  logic        flush,
    input  logic        hazard,
    input  logic [ 4:0] rs1,
    input  logic [ 4:0] rd,
    output logic [ 2:0] alusel,
    output logic [ 2:0] mulsel,
    output logic [ 2:0] divsel,
    output logic [ 2:0] storecntrl,
    output logic [ 4:0] loadcntrl,
    output logic [ 3:0] cmpcntrl,
    output logic        branch,
    output logic        memread,
    output logic        memwrite,
    output logic        regwrite,
    output logic        alusrc,
    output logic        compare,
    output logic        auipc,
    output logic        lui,
    output logic        jal,
    output logic        jalr,
    output logic [ 2:0] csrsel,
    output logic        csrwrite,
    output logic        csrread,
    output logic        trap_ret,
    output logic        mul_inst,
    output logic        div_inst,
    output logic        illegal_ins
);

  // Instruction Classification Signal
  logic stall;

  always_comb begin
    alusel = 3'b000;
    mulsel = 3'b000;
    divsel = 3'b000;
    storecntrl = 3'b000;
    loadcntrl = 5'b00000;
    cmpcntrl = 2'b00;
    branch = 1'b0;
    memread = 1'b0;
    memwrite = 1'b0;
    regwrite = 1'b0;
    alusrc = 1'b0;
    compare = 1'b0;
    auipc = 1'b0;
    lui = 1'b0;
    jal = 1'b0;
    jalr = 1'b0;
    illegal_ins = 1'b0;
    csrsel = 3'b000;
    csrwrite = 1'b0;
    csrread = 0;
    trap_ret = 0;
    mul_inst = 1'b0;
    div_inst = 1'b0;

    // Decodes control signals from 32-bit instructions
    unique case (opcode)
      7'b0000011: begin  // I-type Load Instructions
        memread  = 1'b1;
        regwrite = (!stall) && (1'b1);
        alusel   = 3'b000;
        alusrc   = 1'b1;
        unique case (funct3)
          3'b000:  loadcntrl = 5'b00001;  // LB - Load Byte
          3'b001:  loadcntrl = 5'b00010;  // LH - Load Halfword
          3'b010:  loadcntrl = 5'b00100;  // LW - Load Word
          3'b100:  loadcntrl = 5'b01000;  // LBU - Load Unsigned Byte
          3'b101:  loadcntrl = 5'b10000;  // LHU - Load Unsigned Halfword
          default: illegal_ins = (!flush) && (1'b1);
        endcase
      end
      7'b0110011: begin  // R-type Arithmetic & Compare Instructions
        regwrite = (!stall) && (1'b1);
        unique case ({funct7, funct3})
          {7'h00, 3'b000} : alusel = 3'b000;  // ADD - Addition
          {7'h20, 3'b000} : alusel = 3'b001;  // SUB - Subtraction
          {7'h00, 3'b001} : alusel = 3'b101;  // SLL - Logical Left Shift
          {7'h00, 3'b010} : begin  // SLT - Signed Compare
            compare  = 1'b1;
            cmpcntrl = 4'b0001;
          end
          {7'h00, 3'b011} : begin  // SLTU - Unsigned Compare
            compare  = 1'b1;
            cmpcntrl = 4'b0010;
          end
          {7'h00, 3'b100} : alusel = 3'b100;  // XOR - Bitwise XOR
          {7'h00, 3'b101} : alusel = 3'b110;  // SRL - Logical Right Shift
          {7'h20, 3'b101} : alusel = 3'b111;  // SRA - Arithmetic Right Shift
          {7'h00, 3'b110} : alusel = 3'b011;  // OR - Bitwise OR
          {7'h00, 3'b111} : alusel = 3'b010;  // AND - Bitwise AND
          {7'h01, 3'b000} : begin  // MUL - Lower-bits Multiplication
            mulsel   = 3'b001;
            mul_inst = 1'b1;
          end
          {7'h01, 3'b001} : begin  // MULH - Upper-bits Signed x Signed Multiplication
            mulsel   = 3'b010;
            mul_inst = 1'b1;
          end
          {7'h01, 3'b010} : begin  // MULHSU - Upper-bits Signed x Unsigned Multiplication
            mulsel   = 3'b011;
            mul_inst = 1'b1;
          end
          {7'h01, 3'b011} : begin  // MULHU - Upper-bits Unsigned x Unsigned Multiplication
            mulsel   = 3'b100;
            mul_inst = 1'b1;
          end
          {7'h01, 3'b100} : begin  // DIV - Signed Integer Division
            divsel   = 3'b001;
            div_inst = 1'b1;
          end
          {7'h01, 3'b101} : begin  // DIVU - Unsigned Integer Division
            divsel   = 3'b010;
            div_inst = 1'b1;
          end
          {7'h01, 3'b110} : begin  // REM - Signed Integer Remainder
            divsel   = 3'b011;
            div_inst = 1'b1;
          end
          {7'h01, 3'b111} : begin  // REMU - Unsigned Integer Remainder
            divsel   = 3'b100;
            div_inst = 1'b1;
          end
          default: illegal_ins = 1'b1;
        endcase
      end
      7'b0010011: begin  // I-type Arithmetic Instructions
        regwrite = (!stall) && (1'b1);
        alusrc   = 1'b1;
        unique case (funct3)
          3'b000: alusel = 3'b000;  // ADDI - Add Immediate
          3'b001: begin  // SLLI - Logical Left Shift by Immediate
            if (funct7 == 7'h00) alusel = 3'b101;
            else illegal_ins = (!flush) && (1'b1);
          end
          3'b010: begin  // SLTI - Set Less than Immediate
            compare  = 1'b1;
            cmpcntrl = 4'b0100;
          end
          3'b011: begin  // SLTIU - Unsigned Set Less than Immediate
            compare  = 1'b1;
            cmpcntrl = 4'b1000;
          end
          3'b100: alusel = 3'b100;  // XORI - Bitwise XOR with Immediate
          3'b101:
          unique case (funct7)
            7'h00:   alusel = 3'b110;  // SRLI - Logical Right Shift by Immediate
            7'h20:   alusel = 3'b111;  // SRAI - Arithmetic Right Shift by Immediate
            default: illegal_ins = (!flush) && (1'b1);
          endcase
          3'b110: alusel = 3'b011;  // ORI - Bitwise OR with Immediate
          3'b111: alusel = 3'b010;  // ANDI - Bitwise AND with Immediate
          default: begin
          end
        endcase
      end
      7'b0100011: begin  // S-type Store Instructions
        memwrite = (!stall) && 1'b1;
        alusrc   = 1'b1;
        alusel   = 3'b000;
        unique case (funct3)
          3'b000:  storecntrl = 3'b001;  // SB - Store Byte
          3'b001:  storecntrl = 3'b010;  // SH - Store Halfword
          3'b010:  storecntrl = 3'b100;  // SW - Store Word
          default: illegal_ins = (!flush) && (1'b1);
        endcase
      end
      7'b1100011: begin  // B-type Branch Instructions - BEQ, BNE, BLT, BGE, BLTU, BGEU
        branch = (!flush) && 1'b1;
      end
      7'b1101111: begin  // J-type Jump Instruction: JAL - Jump and Link
        jal = (!flush) && 1'b1;
        regwrite = stall ? 1'b0 : 1'b1;
      end
      7'b1100111: begin  // I-type Jump Instruction: JALR - Jump and Link Register
        jalr = (!flush) && 1'b1;
        regwrite = stall ? 1'b0 : 1'b1;
      end
      7'b0110111: begin  // U-type Instruction: LUI - Load Upper Immediate
        lui = 1'b1;
        alusrc = 1'b1;
        regwrite = stall ? 1'b0 : 1'b1;
      end
      7'b0010111: begin  // U-type Instruction: AUIPC - Add Upper Immediate to PC
        auipc = 1'b1;
        alusrc = 1'b1;
        regwrite = stall ? 1'b0 : 1'b1;
      end
      7'b1110011: begin  // I-type SYSTEM Instructions
        csrsel = funct3;
        unique case (funct3)
          3'b000: begin  // MRET/SRET/URET - Return from Trap in M-mode, S-mode, or U-mode
            if (funct12 == 12'h302) begin
              trap_ret = 1;
            end
          end
          3'b001: begin  // CSRRW - Atomic Read/Write CSR

            regwrite = (rd == 0) ? 1'b0 : ~stall;
            csrread  = (rd == 0) ? 1'b0 : ~stall;
            csrwrite = ~stall;
          end
          3'b010: begin  // CSRRS - Atomic Read and Set Bits in CSR

            regwrite = ~stall;
            csrread  = ~stall;
            csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
          end
          3'b011: begin  // CSRRC - Atomic Read and Clear Bits in CSR
            regwrite = ~stall;
            csrread  = ~stall;
            csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
          end
          3'b101: begin  // CSRRWI - Atomic Read/Write CSR with Immediate
            alusrc   = 1'b1;
            regwrite = (rd == 0) ? 1'b0 : ~stall;
            csrread  = (rd == 0) ? 1'b0 : ~stall;
            csrwrite = ~stall;
          end
          3'b110: begin  // CSRRSI - Atomic Read and Set Bits in CSR with Immediate
            alusrc   = 1'b1;
            regwrite = ~stall;
            csrread  = ~stall;
            csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
          end
          3'b111: begin  // CSRRCI - Atomic Read and Clear Bits in CSR with Immediate
            alusrc   = 1'b1;
            regwrite = ~stall;
            csrread  = ~stall;
            csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
          end
          default: begin
            regwrite = 0;
            csrread  = 0;
            csrwrite = 0;
          end
        endcase
      end
      default: illegal_ins = (!flush) && (1'b1);
    endcase
  end

  // Prevents writes to registers if flushing, a hazard is present, or instruction is 0
  assign stall = flush || hazard || ins_zero;
endmodule : control
