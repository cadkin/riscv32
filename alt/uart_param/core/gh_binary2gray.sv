////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_binary2gray.sv
//
//  Description:
//    a binary to gray code converter
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
module gh_binary2gray #(
  parameter int SIZE = 8
) (
  input logic [SIZE-1:0] b, // binary value in
  output logic [SIZE-1:0] g // gray code out
);

  genvar j;
  generate
    for (j = 0; j < SIZE-1; j = j+1) begin : gen_b2g
      assign g[j] = b[j] ^ b[j+1];
    end
  endgenerate
  assign g[SIZE-1] = b[SIZE-1];
endmodule : gh_binary2gray
