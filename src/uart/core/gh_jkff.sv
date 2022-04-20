////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_jkff.vhd
//
//	Description:
//		a JK Flip-Flop
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions  
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	09/03/05  	G Huber 	Initial revision
//	2.0     	10/06/05  	G Huber 	name change to avoid conflict
//	        	          	         	  with other libraries
//	2.1      	05/21/06  	S A Dodd 	fix typo's
//
////////////////////////////////////////////////////////////////////////////-
module gh_jkff (
  input logic clk,
  input logic rst,
  input logic j,
  input logic k,
  output logic q
);

  logic iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 1'b0;
    else begin
      if ((j == 1'b1) && (k == 1'b1)) iq <= ~iq;
      else if (j == 1'b1) iq <= 1'b1;
      else if (k == 1'b1) iq <= 1'b0;
    end;
  end;
endmodule : gh_jkff
