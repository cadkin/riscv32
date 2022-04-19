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
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_gray2binary
	parameter(size= 8);
(	
		input logic [size-1,0] G;	// gray code in
		output logic[size-1,0] B  // binary value out
		);
wire [size-1,0] iB;

BEGIN

assign B = iB;
	
always(G,iB)
begin
//The for-loop creates 16 assign statements
genvar i;
generate
	for (i=0; i < size-2; i++) begin
		assign iB(i) <= G(i) xor iB(i+1);
	end
endgenerate

iB(size-1) <= G(size-1);
end
		
endmodule

