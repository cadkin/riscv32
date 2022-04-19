////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_Counter_down_ce_ld_tc.vhd
//
//	Description:
//		Binary up/down counter with load, count enable and TC
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author   	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	09/03/05   	S A Dodd	Initial revision
//	2.0     	09/17/05  	h lefevre	name change to avoid conflict
//	        	          	         	  with other libraries
//	2.1     	09/24/05  	S A Dodd 	fix description	
//	2.2      	05/21/06  	S A Dodd 	fix typo's
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;
//USE ieee.std_logic_unsigned.all;
//USE ieee.std_logic_arith.all;

module gh_counter_down_ce_ld_tc
	GENERIC (size: INTEGER :=8);
(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		LOAD  : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		D     : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		TC    : OUT STD_LOGIC
		);
END gh_counter_down_ce_ld_tc;

ARCHITECTURE a OF gh_counter_down_ce_ld_tc

	wire iQ  : STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	wire iTC;
	
BEGIN

//
// outputs

	TC <= (iTC and CE);
	      
	Q <= iQ;

//////////////////////////////////
//////////////////////////////////

always(CLK,rst)
BEGIN
	if (rst = '1') begin 
		iTC <= '0';
	end else if (posedge(CLK)) begin
		if (LOAD = '1') begin
			if (D = x"0") begin
				iTC <= '1';
			else
				iTC <= '0';
			end
		end else if (CE = '0') begin  // LOAD = '0'
				if (iQ = x"0") begin
					iTC <= '1';
				else
					iTC <= '0';
				end
		else // (CE = '1')	
			if (iQ = x"1") begin
				iTC <= '1';
			else
				iTC <= '0';
			end
		end			
	end
END


always(CLK,rst)
BEGIN
	if (rst = '1') begin 
		iQ <= (others => '0');
	end else if (posedge(CLK)) begin
		if (LOAD = '1') begin 
			iQ <= D;
		end else if (CE = '1') begin
			iQ <= (iQ - "01");
		end			
	end
END

endmodule
