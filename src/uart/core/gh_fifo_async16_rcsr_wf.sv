////////////////////////////////////////////////////////////////////-
//	Filename:	gh_fifo_async16_rcsr_wf.vhd
//
//
//	Description:
//		a simple Asynchronous FIFO - uses FASM style Memory
//		16 word depth with UART level read flags
//		has "Style #2" gray code address compare
//              
//	Copyright (c) 2007 by Howard LeFevre 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 								 
//
//	Revision	History:
//	Revision	Date      	Author   	Comment
//	////////	//////////	////////-	//////////-
//	1.0     	01/20/07  	h lefevre	Initial revision
//	
////////////////////////////////////////////////////////

//LIBRARY ieee;
//USE ieee.std_logic_1164.all;
//USE ieee.std_logic_unsigned.all;
//USE ieee.std_logic_arith.all;

module gh_fifo_async16_rcsr_wf#(
	parameter data_width = 8;) // size of data bus
	(					
		input logic clk_WR;// : in STD_LOGIC; // write clock
		input logic clk_RD;// : in STD_LOGIC; // read clock
		input logic rst;//    : in STD_LOGIC; // resets counters
		input logic rc_srst =1'b0;//   : in STD_LOGIC:=1'b0; // resets counters (sync with clk_RD!!!)
		input logic WR;//     : in STD_LOGIC; // write control 
		input logic RD;//     : in STD_LOGIC; // read control
		input logic [data_width-1,0] D;//      : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		output logic [data_width-1,0] Q;//      : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		output logic empty;//  : out STD_LOGIC; // sync with clk_RD!!!
		output logic q_full;//  : out STD_LOGIC; // sync with clk_RD!!!
		output logic h_full;//  : out STD_LOGIC; // sync with clk_RD!!!
		output logic a_full;//  : out STD_LOGIC; // sync with clk_RD!!!
		output logic full//   : out STD_LOGIC);
);



component gh_binary2gray
	GENERIC (size: INTEGER := 8);
(	
		B   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		G   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
end component;

component gh_gray2binary
	GENERIC (size: INTEGER := 8);
(	
		G   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);	// gray code in
		B   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0) // binary value out
		);
end component;

	type ram_mem_typearray (15 downto 0) 
	        of STD_LOGIC_VECTOR (data_width-1 downto 0);
	logic ram_mem : ram_mem_type; 
	logic iempty       ;
	logic diempty      ;
	logic ifull        ;
	logic add_WR_CE    ;
	logic [4,0] add_WR;//        : std_logic_vector(4 downto 0); // add_width -1 bits are used to address MEM
	logic [4,0] add_WR_GC;//     : std_logic_vector(4 downto 0); // add_width bits are used to compare
	logic [4,0] iadd_WR_GC;//    : std_logic_vector(4 downto 0);
	logic [4,0] n_add_WR;//      : std_logic_vector(4 downto 0); //   for empty, full flags
	logic [4,0] add_WR_RS;//     : std_logic_vector(4 downto 0); // synced to read clk
	logic add_RD_CE    ;
	logic [4,0] add_RD;//        : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_GC;//     : std_logic_vector(4 downto 0);
	logic [4,0] iadd_RD_GC;//    : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_GCwc;//   : std_logic_vector(4 downto 0);
	logic [4,0] iadd_RD_GCwc;//  : std_logic_vector(4 downto 0);
	logic [4,0] iiadd_RD_GCwc;// : std_logic_vector(4 downto 0);
	logic [4,0] n_add_RD;//      : std_logic_vector(4 downto 0);
	logic [4,0] add_RD_WS;//     : std_logic_vector(4 downto 0); // synced to write clk
	logic srst_w       ;
	logic rst_w      ;
	logic srst_r       ;
	logic rst_r      ;
	logic [4,0] c_add_RD;//      : std_logic_vector(4 downto 0);
	logic [4,0] c_add_WR;//      : std_logic_vector(4 downto 0);
	logic [4,0] c_add;//         : std_logic_vector(4 downto 0);

begin

////////////////////////////////////////////
//////- memory ////////////////////////////-
////////////////////////////////////////////


always(clk_WR)
begin			  
	if (posedge(clk_WR)) begin
		if ((WR == 1'b1) and (ifull == 1'b0)) begin
			ram_mem(CONV_INTEGER(add_WR(3 downto 0))) <= D;
		end
	end		
end

	assign Q = ram_mem(CONV_INTEGER(add_RD(3 downto 0)));

////////////////////////////////////////-
////- Write address counter ////////////-
////////////////////////////////////////-
	assign add_RD_CE = (ifull) ? 1'b0 : (~WR)? 1'b0 :  1'b1;
	//assign add_WR_CE <= 1'b0 when (ifull == 1'b1) else
	//             1'b0 when (WR == 1'b0) else
	//             1'b1;

	assign n_add_WR = add_WR + 2'b01; //maybe bug

U1 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => n_add_WR,
		G => iadd_WR_GC
		);
	
always(clk_WR,rst)
begin 
	if (rst == 1'b1) begin
		add_WR <= (others => 1'b0);
		add_RD_WS(4 downto 3) <= 2'b11; 
		add_RD_WS(2 downto 0) <= (others => 1'b0);
		add_WR_GC <= (others => 1'b0);
	end else if (posedge(clk_WR)) begin
		add_RD_WS <= add_RD_GCwc;
		if (srst_w == 1'b1) begin
			add_WR <= (others => 1'b0);
			add_WR_GC <= (others => 1'b0);
		end else if (add_WR_CE == 1'b1) begin
			add_WR <= n_add_WR;
			add_WR_GC <= iadd_WR_GC;
		else
			add_WR <= add_WR;
			add_WR_GC <= add_WR_GC;
		end
	end
end
				 
	assign full = ifull;
	assign ifull = (iempty) ? 1'b0 : (add_RD_WS != add_WR_GC)? 1'b0 :  1'b1;
	//assign ifull = 1'b0 when (iempty == 1'b1) else // just in case add_RD_WSreset to all zero's
	//       1'b0 when (add_RD_WS != add_WR_GC) else //// instend of "11 zero's" 
	//       1'b1;

		
////////////////////////////////////////-
////- Read address counter //////////////
////////////////////////////////////////-

	assign add_RD_CE = (iempty) ? 1'b0 : (~RD)? 1'b0 :  1'b1;
	//add_RD_CE <= 1'b0 when (iempty == 1'b1) else
	//             1'b0 when (RD == 1'b0) else
	//            1'b1;
				 
	assign n_add_RD = add_RD + 2'b01; //maybe bug

U2 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => n_add_RD,
		G => iadd_RD_GC // to be used for empty flag
		);

	iiadd_RD_GCwc <= (not n_add_RD(4)) & n_add_RD(3 downto 0);
		
U3 : gh_binary2gray
	generic map (size => 5)
	port map(
		B => iiadd_RD_GCwc,
		G => iadd_RD_GCwc // to be used for full flag
		);
		
always(clk_RD,rst)
begin 
	if (rst == 1'b1) begin
		add_RD <= (others => 1'b0);	
		add_WR_RS <= (others => 1'b0);
		add_RD_GC <= (others => 1'b0);
		add_RD_GCwc(4 downto 3) <= 2'b11;
		add_RD_GCwc(2 downto 0) <= (others => 1'b0);
		diempty <= 1'b1;
	end else if (posedge(clk_RD)) begin
		add_WR_RS <= add_WR_GC;
		diempty <= iempty;
		if (srst_r == 1'b1) begin
			add_RD <= (others => 1'b0);
			add_RD_GC <= (others => 1'b0);
			add_RD_GCwc(4 downto 3) <=  2'b11;
			add_RD_GCwc(2 downto 0) <= (others => 1'b0);
		end else if (add_RD_CE == 1'b1) begin
			add_RD <= n_add_RD;
			add_RD_GC <= iadd_RD_GC;
			add_RD_GCwc <= iadd_RD_GCwc;
		else
			add_RD <= add_RD; 
			add_RD_GC <= add_RD_GC;
			add_RD_GCwc <= add_RD_GCwc;
		end
	end
end

	assign empty = diempty;
	assign iempty = (add_WR_RS == add_RD_GC) ? 1'b1 :   1'b0;
	//assign iempty <= 1'b1 when (add_WR_RS == add_RD_GC) else
	//          1'b0;
 
U4 : gh_gray2binary
	generic map (size => 5)
	port map(
		G => add_RD_GC,
		B => c_add_RD 
		);

U5 : gh_gray2binary
	generic map (size => 5)
	port map(
		G => add_WR_RS,
		B => c_add_WR 
		); 
		
	assign c_add = (c_add_WR - c_add_RD);
	assign q_full = (iempty) ? 1'b0 : (c_add(4 downto 2) == 3b'000)? 1'b0 :  1'b1;
	//q_full <= 1'b0 when (iempty == 1'b1) else
	//          1'b0 when (c_add(4 downto 2) == "000") else
	//          1'b1;
	assign h_full = (iempty) ? 1'b0 : (c_add(4 downto 3) == 2b'00)? 1'b0 :  1'b1;
	//h_full <= 1'b0 when (iempty == 1'b1) else
	//          1'b0 when (c_add(4 downto 3) == "00") else
	//          1'b1; 
	assign a_full = (iempty) ? 1'b0 : (c_add(4 downto 1) == 4b'0111)? 1'b0 :  1'b1;
	//a_full <= 1'b0 when (iempty == 1'b1) else
	//          1'b0 when (c_add(4 downto 1) < "0111") else
	//          1'b1; 
			  
//////////////////////////////////
//- sync rest stuff //////////////
//- rc_srstsync with clk_RD //
//- srst_wsync with clk_WR //-
//////////////////////////////////

always(clk_WR,rst)
begin 
	if (rst == 1'b1) begin
		srst_w <= 1'b0;	
		isrst_r <= 1'b0;	
	end else if (posedge(clk_WR)) begin
		srst_w <=rst_w;
		if (srst_w == 1'b1) begin
			isrst_r <= 1'b1;
		end else if (srst_w == 1'b0) begin
			isrst_r <= 1'b0;
		end
	end
end

always(clk_RD,rst)
begin 
	if (rst == 1'b1) begin
		srst_r <= 1'b0;	
		isrst_w <= 1'b0;
	end else if (posedge(clk_RD)) begin
		srst_r <= rc_srst;
		if (rc_srst == 1'b1) begin
			isrst_w <= 1'b1;
		end else if (isrst_r == 1'b1) begin
			isrst_w <= 1'b0;
		end
	end
end

endmodule
