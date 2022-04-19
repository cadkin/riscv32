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
		iclk : in STD_LOGIC;  // clock for input data signal
		oclk : in STD_LOGIC;  // clock for output data pulse
		rst  : in STD_LOGIC;
		D    : in STD_LOGIC;
		re   : out STD_LOGIC; // rising edge 
		fe   : out STD_LOGIC  // falling edge 
		);
endmodule


architecture a of gh_edge_det_XCD

	wire iQ ;
	wire jkR, jkF;
	wire irQ0, rQ0, rQ1;
	wire ifQ0, fQ0, fQ1;

begin

always(iclk,rst)
begin
	if (rst = '1') begin 
		iQ <= '0';
		jkR <= '0';
		jkF <= '0';
	end else if (posedge(iclk)) begin
		iQ <= D;
		if ((D = '1') and (iQ = '0')) begin
			jkR <= '1';
		end else if (rQ1 = '1') begin
			jkR <= '0';
		else
			jkR <= jkR;
		end
		if ((D = '0') and (iQ = '1')) begin
			jkF <= '1';
		end else if (fQ1 = '1') begin
			jkF <= '0';
		else
			jkF <= jkF;
		end
	end
end

	re <= (not rQ1) and rQ0;
	fe <= (not fQ1) and fQ0;

always(oclk,rst)
begin
	if (rst = '1') begin 
		irQ0 <= '0';
		rQ0 <= '0'; 
		rQ1 <= '0';
		//////////////-
		ifQ0 <= '0';
		fQ0 <= '0';
		fQ1 <= '0';
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
