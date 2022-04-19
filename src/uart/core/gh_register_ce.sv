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
 parameter size= 8;)

(	
		input logic clk;// : IN		STD_LOGIC;
		input logic rst;// : IN		STD_LOGIC; 
		input logic CE;//  : IN		STD_LOGIC; // clock enable
		input logic [size-1,0] D;//   : IN		STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		output logic [size-1,0] Q;//  : OUT		STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);


always(clk,rst)
begin
	if (rst == 1'b1) begin
		Q <= {size{1'b0}};
	end else if (posedge (clk)) begin
		if (CE == 1'b1) begin
			Q <= D;
		end
	end
end

endmodule

