`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Branch Decision
// Description:
//   Implements the RISC-V branch decision logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   rs1_mod -- modified rs1 value from branch_forward
//   rs2_mod -- modified rs1 value from branch_forward
//   branch -- indicates branch
//   funct3 -- funct3 opcode field
//   jal -- indicates jump and link
//   jalr -- indicates jump and link for subrouting return
// Output:
//   branch_taken -- flag branch taken
//
//////////////////////////////////////////////////////////////////////////////////

module branch_decision (
    input  logic [31:0] rs1_mod,
    input  logic [31:0] rs2_mod,
    input  logic        branch,
    input  logic [ 2:0] funct3,
    output logic        branch_taken,
    input  logic        hazard,
    input  logic        jal,
    input  logic        jalr
);

  logic [32:0] sub_res;
  logic sel, zero, less, lessu;
  logic beq, bne, blt, bge, bltu, bgeu;

  // BEQ/BNE: Checks if data (or forwarded data) in rs1 and rs2 are equal
  assign sub_res = rs1_mod - rs2_mod;
  assign zero = !(|sub_res[31:0]);

  // BLT/BGE: Checks if data (or forwarded data) in rs1 is less than rs2 using signed values
  assign less = ($signed(rs1_mod) < $signed(rs2_mod));

  // BLT/BGE: Checks if data (or forwarded data) in rs1 is less than rs2 using unsigned values
  assign lessu = (rs1_mod < rs2_mod);

  // Checks the type of branch operation.
  assign beq = !(|funct3) && branch;                                  // Branch if Equal
  assign bne = (!funct3[2]) && (!funct3[1]) && (funct3[0]) && branch; // Branch if Not Equal
  assign blt = (funct3[2]) && (!funct3[1]) && (!funct3[0]) && branch; // Branch if Less than, Signed
  assign bge = (funct3[2]) && (!funct3[1]) && funct3[0] && branch;    // Branch if Greater than or Equal, Signed
  assign bltu = (funct3[2]) && (funct3[1]) && (!funct3[0]) && branch; // Branch if Less than, Unsigned
  assign bgeu = (funct3[2]) && (funct3[1]) && (funct3[0]) && branch;  // Branch if Greater than or Equal, Unsigned

  // Designates branch as taken if instruction and condition match
  assign branch_taken = ((beq && zero) ||
                         (bne && (!zero)) ||
                         (blt && less) ||
                         (bge &&  (!less)) ||
                         (bltu && lessu) ||
                         (bgeu && (!lessu)) ||
                         jal ||
                         jalr) &&
                        (!hazard);
endmodule : branch_decision
