////////////////////////////////////////////////////////////////////-
//	Filename:	gh_fifo_async16_sr.vhd
//
//			
//	Description:
//		an Asynchronous FIFO 
//              
//	Copyright (c) 2006 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 								 
//
//	Revision	History:
//	Revision	Date      	Author   	Comment
//	////////	//////////	////////-	//////////-
//	1.0     	12/17/06  	h lefevre	Initial revision
//	
////////////////////////////////////////////////////////

//LIBRARY ieee;
//USE ieee.std_logic_1164.all;
//USE ieee.std_logic_unsigned.all;
//USE ieee.std_logic_arith.all;

module gh_fifo_async16_sr#(
	parameter data_width = 8;) // size of data bus
	(					
		input logic clk_WR;// : in STD_LOGIC; // write clock
		input logic clk_RD;// : in STD_LOGIC; // read clock
		input logic rst;//    : in STD_LOGIC; // resets counters
		input logic srst =1'b0;//   : in STD_LOGIC:=1'b0; // resets counters (sync with clk_WR)
		input logic WR;//     : in STD_LOGIC; // write control 
		input logic RD;//     : in STD_LOGIC; // read control
		input logic [data_width-1,0] D;//      : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		output logic [data_width-1,0] Q;//      : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		output logic empty;//  : out STD_LOGIC; 
		output logic full//   : out STD_LOGIC);
);

	type ram_mem_typearray (15 downto 0) 
	        of STD_LOGIC_VECTOR (data_width-1 downto 0);
	logic ram_mem : ram_mem_type; 
	logic iempty     ;
	logic ifull      ;
	logic add_WR_CE  ;
	logic [4,0] add_WR;//      : std_logic_vector(4 downto 0); // 4 bits are used to address MEM
	logic [4,0] add_WR_GC;//   : std_logic_vector(4 downto 0); // 5 bits are used to compare
	logic [4,0] n_add_WR;//    : std_logic_vector(4 downto 0); //   for empty, full flags
	logic [4,0] add_WR_RS;//   : std_logic_vector(4 downto 0); // synced to read clk
	logic add_RD_CE  ;
	logic [4,0] add_RD;//      : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_GC;//   : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_GCwc;// : std_logic_vector(4 downto 0);
	logic [4,0] n_add_RD;//    : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_WS;//   : std_logic_vector(4 downto 0); // synced to write clk
	logic srst_w     ;
	logic signalrst_w    ;
	logic srst_r     ;
	logic signalrst_r    ;

begin

////////////////////////////////////////////
//////- memory ////////////////////////////-
////////////////////////////////////////////

always(clk_WR)
begin			  
	if (posedge(clk_WR)) begin
		if ((WR == 1'b1) and (ifull == 1'b0)) begin
			ram_mem(CONV_INTEGER(add_WR(3 downto 0))) <= D;
		end if;
	end if;		
end

	assign Q = ram_mem(CONV_INTEGER(add_RD[3,0]));

////////////////////////////////////////-
////- Write address counter ////////////-
////////////////////////////////////////-
	assign add_WR_CE = (ifull) ? 1'b0 : (~WR)? 1'b0 :  1'b1;
	//assign add_WR_CE <= 1'b0 when (ifull == 1'b1) else
	//             1'b0 when (WR == 1'b0) else
	//             1'b1;

	assign n_add_WR = add_WR + 1'b'1;
				 
always(clk_WR,rst)
begin 
	if (rst == 1'b1) begin
		add_WR <= {5{1'b0}};//(others => 1'b0);
		add_RD_WS <= 5b'11000; 
		add_WR_GC <= {5{1'b0}};//(others => 1'b0);
	end else if (posedge(clk_WR)) begin
		add_RD_WS <= add_RD_GCwc;
		if (srst_w == 1'b1) begin
			add_WR <= {5{1'b0}};//(others => 1'b0);
			add_WR_GC <= {5{1'b0}}// (others => 1'b0);
		end else if (add_WR_CE == 1'b1) begin
			add_WR <= n_add_WR;
			add_WR_GC[0] <= n_add_WR(0) xor n_add_WR[1];
			add_WR_GC[1] <= n_add_WR[1] xor n_add_WR[2];
			add_WR_GC[2] <= n_add_WR[2] xor n_add_WR[3];
			add_WR_GC[3] <= n_add_WR[3] xor n_add_WR[4];
			add_WR_GC[4] <= n_add_WR[4];
		end else begin
			add_WR <= add_WR;
			add_WR_GC <= add_WR_GC;
		end if;
	end if;
end
				 
	assign full = ifull;
	assign ifull = (iempty) ? 1'b0 : // just in case add_RD_WSreset to "00000"
			(add_RD_WS != add_WR_G)? 1'b0 :  1'b1;  //// instend of "11000"
			 
////////////////////////////////////////-
////- Read address counter //////////////
////////////////////////////////////////-

	assign add_RD_CE = (iempty) ? 1'b0 : (~RD)? 1'b0 :  1'b1;
	//add_RD_CE <= 1'b0 when (iempty == 1'b1) else
	//             1'b0 when (RD == 1'b0) else
	//             1'b1;
				 
	assign n_add_RD = add_RD + 1'b'1;
				 
always(clk_RD,rst)
begin 
	if (rst == 1'b1) begin
		add_RD <= {5{1'b0}};//(others => 1'b0);	
		add_WR_RS <= {5{1'b0}};//(others => 1'b0);
		add_RD_GC <= {5{1'b0}};//(others => 1'b0);
		add_RD_GCwc <= 5b'11000;
	end else if (posedge(clk_RD)) begin
		add_WR_RS <= add_WR_GC;
		if (srst_r == 1'b1) begin
			add_RD <= {5{1'b0}};//(others => 1'b0);
			add_RD_GC <= {5{1'b0}};//(others => 1'b0);
			add_RD_GCwc <= 5b'11000;
		end else if (add_RD_CE == 1'b1) begin
			add_RD <= n_add_RD;
			add_RD_GC[0] <= n_add_RD(0) xor n_add_RD[1];
			add_RD_GC[1] <= n_add_RD[1] xor n_add_RD[2];
			add_RD_GC[2] <= n_add_RD[2] xor n_add_RD[3];
			add_RD_GC[3] <= n_add_RD[3] xor n_add_RD[4];
			add_RD_GC[4] <= n_add_RD[4];
			add_RD_GCwc[0] <= n_add_RD(0) xor n_add_RD[1];
			add_RD_GCwc[1] <= n_add_RD[1] xor n_add_RD[2];
			add_RD_GCwc[2] <= n_add_RD[2] xor n_add_RD[3];
			add_RD_GCwc[3] <= n_add_RD[3] xor n_add_RD[4];
			add_RD_GCwc[4] <= (not n_add_RD[4]);
		end else begin
			add_RD <= add_RD; 
			add_RD_GC <= add_RD_GC;
			add_RD_GCwc <= add_RD_GCwc;
		end if;
	end if;
end

	assign empty = iempty;
 
	assign iempty =  (add_WR_RS == add_RD_GC) ? 1'b1 : 1'b0;
 
//////////////////////////////////
//-	sync rest stuff //////////////
//- srstsync with clk_WR ////-
//- srst_rsync with clk_RD //-
//////////////////////////////////

always(clk_WR,rst)
begin 
	if (rst == 1'b1) begin
		srst_w <= 1'b0;	
		isrst_r <= 1'b0;	
	end else if (posedge(clk_WR)) begin
		isrst_r <= srst_r;
		if (srst == 1'b1) begin
			srst_w <= 1'b1;
		end else if (isrst_r == 1'b1) begin
			srst_w <= 1'b0;
		end if;
	end if;
end

always(clk_RD,rst)
begin 
	if (rst == 1'b1) begin
		srst_r <= 1'b0;	
		isrst_w <= 1'b0;	
	end else if (posedge(clk_RD)) begin
		isrst_w <= srst_w;
		if (isrst_w == 1'b1) begin
			srst_r <= 1'b1;
		end else begin
			srst_r <= 1'b0;
		end if;
	end if;
end

endmodule
