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
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_decode_3to8
(	
		input logic [3,0] A;//   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); // address
		input logic G1;//  : IN  STD_LOGIC; // enable positive
		input logic G2n;// : IN  STD_LOGIC; // enable negative
		input logic G3n;// : IN  STD_LOGIC; // enable negative
		output logic [7,0] Y//   : out STD_LOGIC_VECTOR(7 downto 0)
		);
  

begin

	Y <= x"00" when (G3n == 1'b1) else
	     x"00" when (G2n == 1'b1) else
	     x"00" when (G1 == 1'b0) else
	     x"80" when (A == 3'h7) else
	     x"40" when (A == 3'h6) else
	     x"20" when (A == 3'h5) else
	     x"10" when (A == 3'h4) else
	     x"08" when (A == 3'h3) else
	     x"04" when (A == 3'h2) else
	     x"02" when (A == 3'h1) else
	     x"01";// when (A == 3'h0)


endmodule

