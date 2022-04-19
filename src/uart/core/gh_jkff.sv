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
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;


module gh_jkff
(
		input logic clk;//  : IN STD_logic;
		input logic rst;// : IN STD_logic;
		input logic J,K;//  : IN STD_logic;
		output logic Q//    : OUT STD_LOGIC
	);



	logic iQ;// :  STD_LOGIC;
	

 
assign	Q = iQ;

always(clk,rst)
begin
	if (rst == 1'b1) begin 
		iQ <= 1'b0;
	end else if (posedge(clk)) begin 
		if ((J = 1'b1) and (K == 1'b1)) begin
			iQ <= (~ iQ);
		end else if (J == 1'b1) begin
			iQ <= 1'b1;
		end else if (K == 1'b1) begin
			iQ <= 1'b0;
		end
	end
end


endmodule

