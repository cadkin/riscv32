////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_parity_gen_Serial.vhd
//
//	Description:
//		a Serial parity bit generator
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	10/15/05  	S A Dodd	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;

module gh_parity_gen_Serial
(	
		input logic clk      : IN STD_LOGIC;
		input logic rst      : IN STD_LOGIC; 
		input logic srst     : in STD_LOGIC;
		input logic SD       : in STD_LOGIC; // sample data pulse
		input logic D        : in STD_LOGIC; // data
		output logic Q        : out STD_LOGIC // parity 
		);


	logic parity;
	
	assign Q = parity;
	
always(clk,rst)
begin
	if (rst == 1'b1) begin 
		parity <= 1'b0;
	end else if (posedge(clk)) begin
		if (srst == 1'b1) begin // need to clear before start of data word
			parity <= 1'b0;
		end else if (SD == 1'b1) begin // sample data bit for parity generation
			parity <= (parity xor D);
		end
	end
end
		
endmodule

