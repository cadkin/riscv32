`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Immediate Generator
// Description:
//   Implements the RISC-V immediate generation logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   ins -- 32-bit instruction operation code
//   jalr -- 1-bit control for jump and link for subrouting return
// Output:
//   imm -- 32-bit immediate value to be used during execution
//
//////////////////////////////////////////////////////////////////////////////////

module imm_gen (
    input  logic [31:0] ins,
    output logic [31:0] imm
);

  // Separates the immediate fields from the 32-bit instructions
  always_comb
    unique case (ins[6:2])
      5'b00100: imm = {{21{ins[31]}}, ins[30:20]};             // I-type Arithmetic Instructions
      5'b00000: imm = {{21{ins[31]}}, ins[30:20]};             // I-type Load Instructions
      5'b01000: imm = {{21{ins[31]}}, ins[30:25], ins[11:7]};  // S-type Store Instructions
      5'b01101: imm = {ins[31:12], {12{1'b0}}};                // U-type Instruction: LUI
      5'b00101: imm = {ins[31:12], {12{1'b0}}};                // U-type Instruction: AUIPC
      5'b11100: imm = {27'b0, ins[19:15]};                     // I-type SYSTEM Instructions
      default:  imm = {{21{ins[31]}}, ins[30:20]};
    endcase
endmodule : imm_gen
