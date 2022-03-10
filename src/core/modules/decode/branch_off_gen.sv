`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Branch Offset Generator
// Description:
//   Implements the RISC-V branch offset generation logic (part of decoder)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   ins -- 32-bit instruction op code
//   rs1_mod -- 32-bit source register 1 value
//   jal -- indicates jump and link
//   jalr -- indicated jump and link for subrouting return
// Output:
//   branoff -- 16-bit branch offset value
//
//////////////////////////////////////////////////////////////////////////////////

module branch_off_gen (
    input logic [31:0] ins,
    input logic [31:0] rs1_mod,
    input logic comp_sig,
    input logic [31:0] comp_imm,
    input logic jal,
    input logic jalr,
    output logic [31:0] branoff
);

  logic [31:0] branoff_branch, branoff_jal, branoff_jalr;
  logic [31:0] imm;

  // Generates the offsets added to the PC in branch and jump instructions.
  // If the instruction is compressed, the compressed immediate is used instead

  // B-immediate: Used in BEQ, BNE, BLT, BGE, BLTU, BGEU
  // Offset added to PC
  assign branoff_branch = comp_sig ? comp_imm : {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};

  // J-immediate: Used in JAL
  // Offset added to PC
  assign branoff_jal = comp_sig ? comp_imm : {{12{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};

  // I-immediate: Used in JALR
  // Offset added to address in rs1
  assign imm = comp_sig ? comp_imm : (ins[31] ? {20'hfffff, ins[31:20]} : {20'h00000, ins[31:20]});
  assign branoff_jalr = rs1_mod + imm;

  // Outputs either offset added to PC for B-instr. and JAL or address to jump to for JALR
  assign branoff = jal ? branoff_jal : jalr ? branoff_jalr : branoff_branch;
endmodule : branch_off_gen
