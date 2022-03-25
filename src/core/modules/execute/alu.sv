`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: ALU
// Description:
//   Implements the RISC-V ALU block (part of execute pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   a -- 32-bit input "a"
//   b -- 32-bit input "b"
//   ID_EX_pres_adr -- present address (program counter) from decoder
//   sel -- ALU select bits from decoder stage
//   addb --
//   logicb --
//   rightb --
//   ID_EX_jal --
//   ID_EX_jalr --
//   ID_EX_compare --
// Output:
//   res -- ALU operation result
//   comp_res -- ALU result of comparison
//
//////////////////////////////////////////////////////////////////////////////////

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] ID_EX_pres_adr,  //jal instr
    input  logic [ 2:0] alusel,
    input  logic        ID_EX_lui,
    input  logic        ID_EX_jal,
    input  logic        ID_EX_jalr,
    input  logic        ID_EX_auipc,
    input  logic        ID_EX_compare,
    input  logic [ 2:0] csrsel,
    input  logic [31:0] CSR_in,
    input  logic        ID_EX_comp_sig,
    output logic [31:0] res,
    output logic        comp_res,
    output logic [31:0] CSR_res
);

  logic [31:0] s;
  logic [32:0] comp_res_temp;
  logic [31:0] addr_incr;

  // Compare data in rs1 and rs2 (high if rs1 < rs2)
  assign comp_res_temp = (a < b);

  // Increment PC by 4 for 32-bit instructions or by 2 for 16-bit compressed instructions
  assign addr_incr = ID_EX_comp_sig ? 2 : 4;

  // ALU operations
  always_comb
    case (alusel)
      3'b000:  s = a + b;         // Addition, Load, Store
      3'b001:  s = a - b;         // Subtraction
      3'b010:  s = a & b;         // Bitwise AND
      3'b011:  s = a | b;         // Bitwise OR
      3'b100:  s = a ^ b;         // Bitwise XOR
      3'b101:  s = a << b[4:0];   // Logical Left Shift
      3'b110:  s = a >> b[4:0];   // Logical Right Shift
      3'b111:  s = a >>> b[4:0];  // Arithmetic Right Shift
      default: s = 0;
    endcase

  // CSR ALU operations
  always_comb begin
    case (csrsel)
      3'b001:  CSR_res = a;            // Atomic Read/Write CSR
      3'b010:  CSR_res = CSR_in | a;   // Atomic Read and Set Bits in CSR
      3'b011:  CSR_res = CSR_in | ~a;  // Atomic Read and Clear Bits in CSR
      3'b101:  CSR_res = b;            // Atomic Read/Write CSR with Immediate
      3'b110:  CSR_res = CSR_in | b;   // Atomic Read and Set Bits in CSR with Immediate
      3'b111:  CSR_res = CSR_in | ~b;  // Atomic Read and Clear Bits in CSR with Immediate
      default: CSR_res = 0;
    endcase
  end

  // Output either immediate, PC incremented by 2/4/offset, compare result, or ALU result
  assign res = (ID_EX_lui) ? b :                                // Load Upper Immediate
               (ID_EX_auipc) ? (b + ID_EX_pres_adr[11:0]) :     // Add Upper Immediate to PC
               (ID_EX_jal) ? (ID_EX_pres_adr + addr_incr) :     // Jump and Link (inc. PC)
               (ID_EX_jalr) ? (ID_EX_pres_adr + addr_incr) :    // Jump and Link Register (inc. PC)
               ((ID_EX_compare && comp_res_temp) ? 32'h1 : s);  // Compare or ALU result
endmodule : alu
