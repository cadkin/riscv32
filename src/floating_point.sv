//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Jianjun Xu, 
//   University of Tennessee, Knoxville
// 
// Created:
//   October 28, 2021
// 
// Module name: FPU
// Description:
//   Implements the RISC-V FPU block (part of execute pipeline stage)
//   Only contain the RV32F standard extension
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   a -- 32-bit input "a"
//   b -- 32-bit input "b"
//   c -- 32-bit input "c" for FM and FNM instructions
//   ID_EX_pres_adr -- present address (program counter) from decoder
//   sel -- ALU select bits from decoder stage
// Output:
//   res -- FLU operation result
//   comp_res -- FLU result of comparison
// 
//////////////////////////////////////////////////////////////////////////////////





module FPU
 (input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [31:0] c,
  input  logic [3:0]  fpusel_s,fpusel_d,
  input  logic [2:0]  sd_sel_s,
  input logic [2:0] cvtsel_s,cvtsel_d,
  output logic [31:0] res,
  output logic [31:0] cvt_res,
  output logic        comp_res);
  logic [31:0] s; //temp result for fpu
  logic [32:0] comp_res_temp;

    
  always_comb 
    case(fpusel_s)
      4'b0000 : //fp fadd
      4'b0001 : //fp fsub
      4'b0010 : //fp fmul
      4'b0011 : //fp fdiv
      4'b0100 : //fp fsqurt
      4'b0101 : //fp fsgnj.s
      4'b0110 : //fp fsgnjn
      4'b0111 : //fp fsgnjx
      4'b1000 : //fp fmax.s
      4'b1001 : //fp fmin.s
      4'b1010 : //fp feq.s
      4'b1011 : //fp flt.s
      4'b1100 : //fp fle.s
      4'b1101 : //fp fmv.x.w
      4'b1110 : //fp fclass.s
      4'b1111 : //fp fmv.w.x
    endcase

 always_comb begin
    case (sd_sel_s)
       3'b000: //FMADD.S
       3'b001: //FMSUB.S
       3'b010: //FNMSUB.S
       3'b011: //FNMADD.S
       default: 
    endcase
    
 always_comb begin
    case (cvtsel_s) //room for RV64F extension
       3'b000: //FCVT.W.S
       3'b001: //FCVT.WU.S
       3'b010: //FCVT.S.W
       3'b011: //FCVT.S.WU
       default: 
    endcase



   
endmodule: FPU
