////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_gray2binary.sv
//
//  Description:
//    a gray code to binary converter
//
//  Copyright (c) 2006 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author    Comment
//  ////////   //////////   ////////  //////////-
//  1.0        12/26/06     G Huber   Initial revision
//  2.0        04/20/22     SenecaUTK Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_gray2binary #(
  parameter int SIZE = 8
) (
  input logic [SIZE-1:0] g, // gray code in
  output logic [SIZE-1:0] b // binary value out
);

  logic [SIZE-1:0] ib;

  assign b = ib;

  genvar j;
  generate
    for (j = 0; j < SIZE-1; j = j+1) begin : gen_g2b
      assign ib[j] = g[j] ^ ib[j+1];
    end
  endgenerate
  assign ib[SIZE-1] = g[SIZE-1];
endmodule : gh_gray2binary
