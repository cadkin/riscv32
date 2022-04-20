////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_gray2binary.vhd
//
//	Description:
//		a gray code to binary converter
//
//	Copyright (c) 2006 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	12/26/06  	G Huber 	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
module gh_gray2binary #(
  parameter int size = 8
) (
  input logic [size-1:0] g, // gray code in
  output logic [size-1:0] b // binary value out
);

  logic [size-1:0] ib;

  assign b = ib;

  genvar j;
  generate
    for (j = 0; j < size-1; j = j+1) begin : gen_g2b
      assign ib[j] = g[j] ^ ib[j+1];
    end
  endgenerate
  assign ib[size-1] = g[size-1];
endmodule : gh_gray2binary
