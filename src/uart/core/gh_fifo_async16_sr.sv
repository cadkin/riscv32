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

module gh_fifo_async16_sr
	GENERIC (data_width: INTEGER :=8 ); // size of data bus
	port (					
		clk_WR : in STD_LOGIC; // write clock
		clk_RD : in STD_LOGIC; // read clock
		rst    : in STD_LOGIC; // resets counters
		srst   : in STD_LOGIC:='0'; // resets counters (sync with clk_WR)
		WR     : in STD_LOGIC; // write control 
		RD     : in STD_LOGIC; // read control
		D      : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Q      : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		empty  : out STD_LOGIC; 
		full   : out STD_LOGIC);
endmodule

architecture a of gh_fifo_async16_sr

	type ram_mem_typearray (15 downto 0) 
	        of STD_LOGIC_VECTOR (data_width-1 downto 0);
	wire ram_mem : ram_mem_type; 
	wire iempty     ;
	wire ifull      ;
	wire add_WR_CE  ;
	wire add_WR      : std_logic_vector(4 downto 0); // 4 bits are used to address MEM
	wire add_WR_GC   : std_logic_vector(4 downto 0); // 5 bits are used to compare
	wire n_add_WR    : std_logic_vector(4 downto 0); //   for empty, full flags
	wire add_WR_RS   : std_logic_vector(4 downto 0); // synced to read clk
	wire add_RD_CE  ;
	wire add_RD      : std_logic_vector(4 downto 0);
	wire add_RD_GC   : std_logic_vector(4 downto 0);
	wire add_RD_GCwc : std_logic_vector(4 downto 0);
	wire n_add_RD    : std_logic_vector(4 downto 0);
	wire add_RD_WS   : std_logic_vector(4 downto 0); // synced to write clk
	wire srst_w     ;
	signalrst_w    ;
	wire srst_r     ;
	signalrst_r    ;

begin

////////////////////////////////////////////
//////- memory ////////////////////////////-
////////////////////////////////////////////

always(clk_WR)
begin			  
	if (posedge(clk_WR)) begin
		if ((WR = '1') and (ifull = '0')) begin
			ram_mem(CONV_INTEGER(add_WR(3 downto 0))) <= D;
		end if;
	end if;		
end

	Q <= ram_mem(CONV_INTEGER(add_RD(3 downto 0)));

////////////////////////////////////////-
////- Write address counter ////////////-
////////////////////////////////////////-

	add_WR_CE <= '0' when (ifull = '1') else
	             '0' when (WR = '0') else
	             '1';

	n_add_WR <= add_WR + x"1";
				 
always(clk_WR,rst)
begin 
	if (rst = '1') begin
		add_WR <= (others => '0');
		add_RD_WS <= "11000"; 
		add_WR_GC <= (others => '0');
	end else if (posedge(clk_WR)) begin
		add_RD_WS <= add_RD_GCwc;
		if (srst_w = '1') begin
			add_WR <= (others => '0');
			add_WR_GC <= (others => '0');
		end else if (add_WR_CE = '1') begin
			add_WR <= n_add_WR;
			add_WR_GC(0) <= n_add_WR(0) xor n_add_WR(1);
			add_WR_GC(1) <= n_add_WR(1) xor n_add_WR(2);
			add_WR_GC(2) <= n_add_WR(2) xor n_add_WR(3);
			add_WR_GC(3) <= n_add_WR(3) xor n_add_WR(4);
			add_WR_GC(4) <= n_add_WR(4);
		else
			add_WR <= add_WR;
			add_WR_GC <= add_WR_GC;
		end if;
	end if;
end
				 
	full <= ifull;

	ifull <= '0' when (iempty = '1') else // just in case add_RD_WSreset to "00000"
	         '0' when (add_RD_WS /= add_WR_GC) else //// instend of "11000"
	         '1';
			 
////////////////////////////////////////-
////- Read address counter //////////////
////////////////////////////////////////-


	add_RD_CE <= '0' when (iempty = '1') else
	             '0' when (RD = '0') else
	             '1';
				 
	n_add_RD <= add_RD + x"1";
				 
always(clk_RD,rst)
begin 
	if (rst = '1') begin
		add_RD <= (others => '0');	
		add_WR_RS <= (others => '0');
		add_RD_GC <= (others => '0');
		add_RD_GCwc <= "11000";
	end else if (posedge(clk_RD)) begin
		add_WR_RS <= add_WR_GC;
		if (srst_r = '1') begin
			add_RD <= (others => '0');
			add_RD_GC <= (others => '0');
			add_RD_GCwc <= "11000";
		end else if (add_RD_CE = '1') begin
			add_RD <= n_add_RD;
			add_RD_GC(0) <= n_add_RD(0) xor n_add_RD(1);
			add_RD_GC(1) <= n_add_RD(1) xor n_add_RD(2);
			add_RD_GC(2) <= n_add_RD(2) xor n_add_RD(3);
			add_RD_GC(3) <= n_add_RD(3) xor n_add_RD(4);
			add_RD_GC(4) <= n_add_RD(4);
			add_RD_GCwc(0) <= n_add_RD(0) xor n_add_RD(1);
			add_RD_GCwc(1) <= n_add_RD(1) xor n_add_RD(2);
			add_RD_GCwc(2) <= n_add_RD(2) xor n_add_RD(3);
			add_RD_GCwc(3) <= n_add_RD(3) xor (not n_add_RD(4));
			add_RD_GCwc(4) <= (not n_add_RD(4));
		else
			add_RD <= add_RD; 
			add_RD_GC <= add_RD_GC;
			add_RD_GCwc <= add_RD_GCwc;
		end if;
	end if;
end

	empty <= iempty;
 
	iempty <= '1' when (add_WR_RS = add_RD_GC) else
	          '0';
 
//////////////////////////////////
//-	sync rest stuff //////////////
//- srstsync with clk_WR ////-
//- srst_rsync with clk_RD //-
//////////////////////////////////

always(clk_WR,rst)
begin 
	if (rst = '1') begin
		srst_w <= '0';	
		isrst_r <= '0';	
	end else if (posedge(clk_WR)) begin
		isrst_r <= srst_r;
		if (srst = '1') begin
			srst_w <= '1';
		end else if (isrst_r = '1') begin
			srst_w <= '0';
		end if;
	end if;
end

always(clk_RD,rst)
begin 
	if (rst = '1') begin
		srst_r <= '0';	
		isrst_w <= '0';	
	end else if (posedge(clk_RD)) begin
		isrst_w <= srst_w;
		if (isrst_w = '1') begin
			srst_r <= '1';
		else
			srst_r <= '0';
		end if;
	end if;
end

endmodule
