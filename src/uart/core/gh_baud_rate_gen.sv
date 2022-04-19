////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_baud_rate_gen.vhd
//
//	Description:
//		a 16 bit baud rate generator
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	01/28/06  	H LeFevre	Initial revision
//	2.0      	02/04/06  	H LeFevre	reload counter with register load
//	2.1      	04/10/06  	H LeFevre	Fix error in rCLK
//
////////////////////////////////////////////////////////////////////////////-
//library ieee ;
//use ieee.std_logic_1164.all ;
//use ieee.std_logic_arith.all ;
//use ieee.std_logic_unsigned.all ;

module gh_baud_rate_gen
(
		input logic clk ;	
		input logic BR_clk;
		input logic rst;
		input logic WR;
		input logic [1,0]  BE; // byte enable
		input logic [15,0] D;
		output logic [15,0] RD;
		output logic rCE;
		output logic rCLK   
		);
endmodule

architecture a of gh_baud_rate_gen

COMPONENT gh_register_ce
	GENERIC (size: INTEGER := 8);
(	
		clk : IN		STD_LOGIC;
		rst : IN		STD_LOGIC; 
		CE  : IN		STD_LOGIC; // clock enable
		D   : IN		STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q   : OUT		STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
end COMPONENT;

COMPONENT gh_counter_down_ce_ld
	GENERIC (size: INTEGER :=8);
(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		LOAD  : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		D     : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
	);
end COMPONENT;

	logic UB_LD  ;
	logic LB_LD  ;
	logic rate    : std_logic_vector(15 downto 0);
	logic C_LD   ;
	logic C_CE   ;
	logic irLD   ;	// added 02/04/06
	logic rLD    ; // added 02/04/06
	logic count   : std_logic_vector(15 downto 0);
	
begin
 
	rCE <= 1'b1 when (count == x"01") else
	       1'b0;
		
always(BR_clk,rst)
begin
	if (rst == 1'b1) begin
		rCLK <= 1'b0;
		rLD <= 1'b0;
	end else if (posedge(BR_CLK)) begin 
		rLD <= irLD;
		if (count > (1'b0 & (rate(15 downto 1)))) begin // fixed 04/10/06
			rCLK <= 1'b1;
		else
			rCLK <= 1'b0;
		end
	end
end

	RD <= rate;
	
//////////////////////////////////////////////
//////////////////////////////////////////////	

	UB_LD <= 1'b0 when (WR == 1'b0) else
	         1'b0 when (BE(1) == 1'b0) else	
	         1'b1;
				 
u1 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => UB_LD,
		D => d(15 downto 8),
		Q => rate(15 downto 8)
		);

	LB_LD <= 1'b0 when (WR == 1'b0) else
	         1'b0 when (BE(0) == 1'b0) else	
	         1'b1;
				 
u2 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => LB_LD,
		D => d(7 downto 0),
		Q => rate(7 downto 0)
		);

////////////////////////////////////////////////////////////
//////////// baud rate counter ////////////////////////////-
////////////////////////////////////////////////////////////

always(clk,rst)
begin
	if (rst == 1'b1) begin
		irLD <= 1'b0;
	end else if (posedge(CLK)) begin 
		if ((UB_LD or LB_LD) == 1'b1) begin
			irLD <= 1'b1;
		end else if (rLD == 1'b1) begin
			irLD <= 1'b0;
		end
	end
end

	C_LD <= 1'b1 when (count == x"01") else
	        1'b1 when (rLD == 1'b1) else
	        1'b0;
	
	C_CE <= 1'b1 when (rate > x"01") else
	        1'b0;

U3 : gh_counter_down_ce_ld
	Generic Map (size => 16)
	PORT MAP (
		clk => BR_clk,
		rst => rst,
		LOAD => C_LD,
		CE => C_CE,
		D => rate,
		Q => count);
		
endmodule

