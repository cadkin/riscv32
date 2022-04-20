////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_parity_gen_Serial.vhd
//
//	Description:
//		a Serial parity bit generator
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	10/15/05  	S A Dodd	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
module gh_parity_gen_serial (
  input logic clk,
  input logic rst,
  input logic srst,
  input logic sd, // sample data pulse
  input logic d,  // data
  output logic q  // parity
);

  logic parity;

  assign q = parity;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) parity <= 1'b0;
    else begin
      if (srst == 1'b1) parity <= 1'b0; // need to clear before start of data word
      else if (sd == 1'b1) parity <= (parity ^ d); // sample data bit for parity generation
    end
  end
endmodule : gh_parity_gen_serial
