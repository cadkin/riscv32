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

module gh_counter_down_ce_ld_tc#(
	parameter size= 8)
(
		input logic CLK;//      : IN STD_LOGIC;
		input logic rst;//      : IN STD_LOGIC; 
		input logic LOAD;//     : in STD_LOGIC; // load D
		input logic CE;//       : IN STD_LOGIC; // count enable
		output logic [size-1,0] D;// : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0); in integer RANGE 0 TO size-1;
		output logic [size-1,0] Q//: OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0) out integer RANGE 0 TO size-1
		output logic TC //: OUT STD_LOGIC
		);



	logic [size-1,0] iQ;//  : STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	logic iTC;
	
begin

//
// outputs

	assign TC = (iTC and CE);
	      
	assign Q = iQ;

//////////////////////////////////
//////////////////////////////////

always(CLK,rst)
begin
	if (rst == 1'b1) begin 
		iTC <= 1'b0;
	end else if (posedge(CLK)) begin
		if (LOAD == 1'b1) begin
			if (D == 8'h0) begin
				iTC <= 1'b1;
			end else begin
				iTC <= 1'b0;
			end
		end else if (CE == 1'b0) begin  // LOAD == 1'b0
				if (iQ == 8'h0) begin
					iTC <= 1'b1;
				end else begin
					iTC <= 1'b0;
				end
		else begin// (CE == 1'b1)	
			if (iQ == 8'h1) begin
				iTC <= 1'b1;
			end else begin
				iTC <= 1'b0;
			end
		end			
	end
end


always(CLK,rst)
begin
	if (rst == 1'b1) begin 
		iQ <= {size{1'b0}}; //(others => 1'b0);
	end else if (posedge(CLK)) begin
		if (LOAD == 1'b1) begin 
			iQ <= D;
		end else if (CE == 1'b1) begin
			iQ <= (iQ - 2'b01);
		end			
	end
end

endmodule
