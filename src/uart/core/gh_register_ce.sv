////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_register_ce.vhd
//
//	Description:
//		register with clock enable
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	09/03/05  	G Huber  	Initial revision
//	2.0     	09/17/05  	h lefevre	name change to avoid conflict
//	        	          	         	  with other librarys
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_register_ce#(
 parameter size= 8)

(	
		clk : IN		STD_LOGIC;
		rst : IN		STD_LOGIC; 
		CE  : IN		STD_LOGIC; // clock enable
		D   : IN		STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q   : OUT		STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END gh_register_ce;

ARCHITECTURE a OF gh_register_ce


BEGIN

always(clk,rst)
BEGIN
	if (rst = '1') begin
		Q <= (others =>'0');
	end else if (posedge (clk)) begin
		if (CE = '1') begin
			Q <= D;
		end
	end
END

endmodule

