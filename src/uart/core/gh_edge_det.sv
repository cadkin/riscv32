////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_edge_det.vhd
//
//	Description:
//		an edge detector - 
//		   finds the rising edge and falling edge
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions  
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	//////////	////////	//////////-
//	1.0      	09/10/05  	G Huber 	Initial revision
//	2.0     	09/17/05  	h lefevre	name change to avoid conflict
//	        	          	         	  with other libraries
//	2.1      	05/21/06  	S A Dodd 	fix typo's
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_edge_det
(
	input logic	clk;// : in STD_LOGIC;
	input logic	rst;// : in STD_LOGIC;
	input logic	D;//   : in STD_LOGIC;
	output logic	re;//  : out STD_LOGIC; // rising edge (need sync source at D)
	output logic	fe;//  : out STD_LOGIC; // falling edge (need sync source at D)
	output logic	sre;// : out STD_LOGIC; // sync'd rising edge
	output logic	sfe;// : out STD_LOGIC  // sync'd falling edge
		);



	logic Q0, Q1;// : std_logic;



	assign re = D & (~ Q0);
	assign fe = (~ D) & Q0;
	assign sre = Q0 & (~ Q1);
	assign sfe = (~ Q0) & Q1;
	
always(clk,rst)
begin
	if (rst == 1'b1) begin 
		Q0 <= 1'b0;
		Q1 <= 1'b0;
	end else if (posedge(clk)) begin
		Q0 <= D;
		Q1 <= Q0;
	end
end

endmodule
