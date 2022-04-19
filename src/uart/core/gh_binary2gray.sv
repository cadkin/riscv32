////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_binary2gray.vhd
//
//	Description:
//		a binary to gray code converter
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

module gh_binary2gray
	GENERIC (size: INTEGER := 8);
(	
		input logic [size-1,0] B;//   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);	// binary value in
		output logic [size-1,0] G;//   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0) // gray code out
		);
endmodule

always	(B)
begin
	//The for-loop creates 16 assign statements
	genvar i;
	generate
		for (i=0; i < size-2; i++) begin
			G(i) <= B(i) xor B(i+1);
		end
	endgenerate
	G(size-1) <= B(size-1);
end
		
endmodule

