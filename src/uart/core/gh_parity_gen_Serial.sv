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
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		srst     : in STD_LOGIC;
		SD       : in STD_LOGIC; // sample data pulse
		D        : in STD_LOGIC; // data
		Q        : out STD_LOGIC // parity 
		);


	wire parity;

BEGIN

	Q <= parity;
	
always(clk,rst)
begin
	if (rst = '1') begin 
		parity <= '0';
	end else if (posedge(clk)) begin
		if (srst = '1') begin // need to clear before start of data word
			parity <= '0';
		end else if (SD = '1') begin // sample data bit for parity generation
			parity <= (parity xor D);
		end
	end
end
		
endmodule

