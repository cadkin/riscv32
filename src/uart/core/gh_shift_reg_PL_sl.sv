////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_shift_reg_PL_sl.vhd
//
//	Description:
//		a shift register with Parallel Load	
//		   will shift left (MSB to LSB)
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


module gh_shift_reg_PL_sl#(
	parameter size= 16;)
(
		input logic clk;//      : IN STD_logic;
		input logic rst;//      : IN STD_logic;
		input logic LOAD;//     : IN STD_LOGIC;  // load data
		input logic SE;//       : IN STD_LOGIC;  // shift enable
		input logic [size-1,0] D; //       : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		output logic [size-1,0] Q//        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);



	logic [size-1,0] iQ;// :  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	

 
assign	Q = iQ;
	

always(clk,rst)
begin
	if (rst == 1'b1) begin 
		iQ <= {size{1'b0}};
	end else if (posedge(clk)) begin
		if (LOAD == 1'b1) begin 
			iQ <= D;
		end else if (SE == 1'b1) begin // shift left
			iQ[size-1,0] <=  {1'b0,iQ[size-1,1]};
		end else begin
			iQ <= iQ;
		end
	end
end


endmodule

