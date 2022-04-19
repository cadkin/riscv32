////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_shift_reg_se_sl.vhd
//
//	Description:
//		a shift register with async reset and count enable
//
//	Copyright (c) 2006 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	02/11/06  	G Huber 	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
//LIBRARY ieee;
//USE ieee.std_logic_1164.all;


module gh_shift_reg_se_sl #(
	parameter size= 16)
(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		srst     : IN STD_logic:='0';
		SE       : IN STD_logic; // shift enable
		D        : IN STD_LOGIC;
		Q        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);

	wire [size-1,0] iQ; //:  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	
begin

	Q <= iQ;

always(clk,rst)
begin
	if (rst = '1') begin 
		iQ <= (others => '0');
	end else if (posedge(clk)) begin 
		if (srst = '1') begin
			iQ <= (others => '0');
		end else if (SE = '1') begin
			iQ(size-1) <= D;
			iQ(size-2 downto 0) <= iQ(size-1 downto 1);
		end
	end
end


endmodule
