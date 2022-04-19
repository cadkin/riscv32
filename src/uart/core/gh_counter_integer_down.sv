////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_counter_integer_down.vhd
//
//	Description:
//		an integer down counter
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	10/15/05  	G Huber 	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_counter_integer_down	#(
	parameter max_count= 8)
(	
		input logic clk;//      : IN STD_LOGIC;
		input logic rst;//      : IN STD_LOGIC; 
		input logic LOAD;//     : in STD_LOGIC; // load D
		input logic CE;//       : IN STD_LOGIC; // count enable
		output logic [max_count,0] D;//        : in integer RANGE 0 TO max_count;
		output logic [max_count,0] Q;//        : out integer RANGE 0 TO max_count
		);


	logic [max_count,0] iQ;// : integer RANGE 0 TO max_count;



	assign Q = iQ;
	
always(clk,rst)
begin 
	if (rst == 1'b1) begin
		iQ <= 0;
	end else if (posedge(clk))  begin 
		if (LOAD == 1'b1) begin
			iQ <= D;  
		end else if (CE == 1'b1) begin
			if (iQ == 0) begin
				iQ <= max_count;
			end else begin
				iQ <= iQ - 1;
			end
		end
	end
end
		
endmodule

