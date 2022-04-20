////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_DECODE_3to8.vhd
//
//	Description:
//		a 3 to 8 decoder	 
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date      	Author   	Comment
//	//////// 	//////////	////////-	//////////-
//	1.0      	09/17/05  	G Huber  	Initial revision
//	1.1     	05/05/06  	G Huber  	fix typo
//
////////////////////////////////////////////////////////////////////////////-
module gh_decode_3to8 (
  input logic [2:0] a, // address
  input logic g1, // enable positive
  input logic g2n, // enable negative
  input logic g3n, // enable negative
  output logic [7:0] y
);

  assign y = (g3n == 1'b1) ? 8'h00 :
             (g2n == 1'b1) ? 8'h00 :
             (g1 == 1'b0) ? 8'h00 :
             (a == 7) ? 8'h80 :
             (a == 6) ? 8'h40 :
             (a == 5) ? 8'h20 :
             (a == 4) ? 8'h10 :
             (a == 3) ? 8'h08 :
             (a == 2) ? 8'h04 :
             (a == 1) ? 8'h02 : 8'h01; // when (a == 0)
endmodule : gh_decode_3to8
