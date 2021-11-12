//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Jianjun Xu, Tanner Fowler, Cameron Adkins, Dr. Garrett S. Rose
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
//   c -- 32-bit input "c" for FMADD/SUB and FNMADD/SUB instructions
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
  output logic [31:0] res,
  output logic  comp_res);
  logic [31:0] input_a,input_b; //temp input for fpu
  logic [31:0] output_z; //temp result for fpu
  logic [32:0] comp_res_temp);

  adder(input_a,input_b,input_a_stb, input_b_stb, output_z_ack,clk,rst,output_z,output_z_stb,input_a_ack,input_b_ack);
  divider(input_a,input_b,input_a_stb,input_b_stb,output_z_ack,clk,rst,output_z,output_z_stb,input_a_ack,input_b_ack);
  multiplier(input_a,input_b,input_a_stb,input_b_stb,output_z_ack,clk,rst,output_z,output_z_stb,input_a_ack,input_b_ack);

  float_to_int(input_a,input_a_stb,output_z_ack,clk,rst,input_a_ack,input_b_ack);
  int_to_float(input_a,input_a_stb,output_z_ack,clk,rst,output_z,input_a_ack,input_a_ack);

  always_comb //fpu instuction selction
    case(fpusel_s)
      5'b00000 : //fp fadd
	
      5'b00001 : //fp fsub
      5'b00010 : //fp fmul
      5'b00011 : //fp fdiv
      5'b00100 : //fp fsqurt
      5'b00101 : //fp fsgnj.s
      5'b00110 : //fp fsgnjn
      5'b00111 : //fp fsgnjx
      5'b01000 : //fp fmax.s   compare_get_large
      5'b01001 : //fp fmin.s   compare_get_small
      5'b01010 : //fp feq.s    compare_eq
      5'b01011 : //fp flt.s    compare_less_than
      5'b01100 : //fp fle.s    compare_less_equite
      5'b01101 : //fp fmv.x.w  
      5'b01110 : //fp fclass.s
      5'b01111 : //fp fmv.w.x
      5'b10000 : //FMADD.S
      5'b10001 : //FMSUB.S
      5'b10010 : //FNMSUB.S
      5'b10011 : //FNMADD.S 
      5'b10100 : //FCVT.W.S int_to_float
      5'b10101 : //FCVT.WU.S unsign_int_to_float
      5'b10110 : //FCVT.S.W float_to_int
      5'b10111 : //FCVT.S.WU unsign_int_to_float
      default:
    endcase
  end;

       
   
   
endmodule: FPU
