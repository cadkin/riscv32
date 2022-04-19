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
	parameter size= 16;)
(
		input logic clk;//      : IN STD_logic;
		input logic rst;//      : IN STD_logic;
		input logic srst=1'b0;//     : IN STD_logic:=1'b0;
		input logic SE;//      : IN STD_logic; // shift enable
		input logic  D ;//       : IN STD_LOGIC;
		output logic [size-1,0] Q;//        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);

	logic [size-1,0] iQ; //:  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	


assign	Q = iQ;

always(clk,rst)
begin
	if (rst == 1'b1) begin 
		iQ <= {size{1'b0}};
	end else if (posedge(clk)) begin 
		if (srst == 1'b1) begin
			iQ <= {size{1'b0}};
		end else if (SE == 1'b1) begin
			iQ[size-1,0] <=  {D,iQ[size-1,1]};
		end
	end
end


endmodule
