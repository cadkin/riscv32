////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_edge_det_XCD.vhd
//
//	Description:
//		an edge detector, for crossing clock domains - 
//		   finds the rising edge and falling edge for a pulse crossing clock domains
//
//	Copyright (c) 2006, 2008 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions  
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	//////////	////////	//////////-
//	1.0        	09/16/06  	S A Dodd 	Initial revision
//	2.0     	04/12/08  	hlefevre	mod to double register between clocks
//	        	          	        	   output time remains the same
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_edge_det_XCD
(
		input logic iclk;// : in STD_LOGIC;  // clock for input data signal
		input logic oclk;// : in STD_LOGIC;  // clock for output data pulse
		input logic rst;//  : in STD_LOGIC;
		input logic D;//    : in STD_LOGIC;
		output logic re;//   : out STD_LOGIC; // rising edge 
		output logic fe//   : out STD_LOGIC  // falling edge 
		);




	logic iQ ;
	logic jkR, jkF;
	logic irQ0, rQ0, rQ1;
	logic ifQ0, fQ0, fQ1;

always(iclk,rst)
begin
	if (rst == 1'b1) begin 
		iQ <= 1'b0;
		jkR <= 1'b0;
		jkF <= 1'b0;
	end else if (posedge(iclk)) begin
		iQ <= D;
		if ((D == 1'b1) && (iQ == 1'b0)) begin
			jkR <= 1'b1;
		end else if (rQ1 == 1'b1) begin
			jkR <= 1'b0;
		end else begin
			jkR <= jkR;
		end
		if ((D == 1'b0) && (iQ == 1'b1)) begin
			jkF <= 1'b1;
		end else if (fQ1 == 1'b1) begin
			jkF <= 1'b0;
		end else begin
			jkF <= jkF;
		end
	end
end

	assign re = (~ rQ1) & rQ0;
	assign fe = (~ fQ1) & fQ0;

always(oclk,rst)
begin
	if (rst == 1'b1) begin 
		irQ0 <= 1'b0;
		rQ0 <= 1'b0; 
		rQ1 <= 1'b0;
		//////////////-
		ifQ0 <= 1'b0;
		fQ0 <= 1'b0;
		fQ1 <= 1'b0;
	end else if (posedge(oclk)) begin
		irQ0 <= jkR;
		rQ0 <= irQ0;
		rQ1 <= rQ0;
		//////////////-
		ifQ0 <= jkF;
		fQ0 <= ifQ0;
		fQ1 <= fQ0;
	end
end


endmodule
