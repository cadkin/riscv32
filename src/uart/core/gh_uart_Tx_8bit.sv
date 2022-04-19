////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_uart_Tx_8bit.vhd
//
//	Description:
//		an 8 bit UART Tx Module
//
//	Copyright (c) 2006, 2007 by H LeFevre
//		A VHDL 16550 UART core
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	02/18/06  	H LeFevre	Initial revision
//	1.1      	02/25/06  	H LeFevre	add BUSYn output
//	2.0     	06/18/07  	P.Azkarate  Define "range" in T_WCOUNT and x_dCOUNT signals
//	2.1     	07/12/07  	H LeFevre	fix a problem with 5 bit data and 1.5 stop bits
//       		          	         	   as pointed out by Matthias Klemm
//	2.2     	08/17/07  	H LeFevre	add stopB to sensitivity list line 164
//       		          	         	   as suggested by Guillaume Zin 
////////////////////////////////////////////////////////////////////////////-
//library ieee ;
//use ieee.std_logic_1164.all ;

module gh_uart_Tx_8bit (
		clk       : in std_logic; //  clock
		rst       : in std_logic;
		xBRC      : in std_logic; // x clock enable
		D_RYn     : in std_logic; // data ready 
		D         : in std_logic_vector(7 downto 0);
		num_bits  : in integer RANGE 0 to 8 := 8; // number of bits in transfer
		Break_CB  : in std_logic;
		stopB     : in std_logic;
		Parity_EN : in std_logic;
		Parity_EV : in std_logic;
		sTX       : out std_logic;
		BUSYn     : out std_logic;
		read      : out std_logic // data read
		);

	
architecture a of gh_uart_Tx_8bit

COMPONENT gh_shift_reg_PL_sl
	GENERIC (size: INTEGER := 16);
(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		LOAD     : IN STD_LOGIC;  // load data
		SE       : IN STD_LOGIC;  // shift enable
		D        : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
end COMPONENT;

COMPONENT gh_parity_gen_Serial
(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		srst     : in STD_LOGIC;
		SD       : in STD_LOGIC; // sample data pulse
		D        : in STD_LOGIC; // data
		Q        : out STD_LOGIC
		);
end COMPONENT;

COMPONENT gh_counter_integer_down	
	generic(max_count : integer := 8);
(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		LOAD     : in STD_LOGIC; // load D
		CE       : IN STD_LOGIC; // count enable
		D        : in integer RANGE 0 TO max_count;
		Q        : out integer RANGE 0 TO max_count
		);
end COMPONENT;

	type T_StateType(idle,s_start_bit,shift_data,s_parity,
	                     s_stop_bit,s_stop_bit2);
	logic T_state, T_nstate : T_StateType; 

	logic parity     ;
	logic parity_Grst;
	logic TWC_LD     ;
	logic TWC_CE     ;
	logic T_WCOUNT : integer range 0 to 15;
	logic D_LD_v : integer range 1 to 15;
	logic D_LD;
	logic Trans_sr_SE;
	logic Trans_shift_reg : std_logic_vector(7 downto 0);
	logic iTX;
	logic BRC;
	logic dCLK_LD;
	logic x_dCOUNT : integer range 0 to 15;
	
begin

//////////////////////////////////////////////
//// outputs//////////////////////////////////
//////////////////////////////////////////////

	BUSYn <= 1'b1 when (T_state == idle) else
	         1'b0;

	read <= D_LD; // read a data word

//////////////////////////////////////////////

	dCLK_LD <= 1'b1 when ((num_bits == 5) and (stopB == 1'b1) 
	               and (T_state == s_stop_bit2) and (x_dCOUNT == 7)) else
	           1'b0 when (D_RYn == 1'b0) else
	           1'b0 when (T_state /= idle) else
	           1'b1;

	D_LD_v <= 15 when (T_state == s_stop_bit2) else
	           1;
			   
	BRC <= 1'b0 when (xBRC == 1'b0) else
	       1'b1 when (x_dCOUNT == 0) else
	       1'b0;

   
u1 : gh_counter_integer_down // baud rate divider
	generic map (15)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => dCLK_LD,
		CE => xBRC,
		D => D_LD_v,
		Q => x_dCOUNT);

U2 : gh_shift_reg_PL_sl 
	Generic Map(8)
	PORT MAP (
		clk => clk,
		rst => rst,
		LOAD => D_LD,
		SE => Trans_sr_SE,
		D => D,
		Q => Trans_shift_reg);
		
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
	
always(clk,rst)
begin
	if (rst == 1'b1) begin
		sTX <= 1'b1;
	end else if (posedge(clk)) begin
		sTX <= iTX and (not Break_CB);
	end
end process ;

	iTX <= 1'b0 when (T_state == s_start_bit) else // send start bit
	        Trans_shift_reg(0) when (T_state == shift_data) else // send data
	        parity when ((Parity_EV == 1'b1) and (T_state == s_parity)) else
	        (not parity) when (T_state == s_parity) else
	        1'b1; // idle, stop bit

always(T_state,D_RYn,BRC,T_WCOUNT,Parity_EN,num_bits,x_dCOUNT,stopB)
begin
	case T_state
		when idle => // idle  
			TWC_CE <= 1'b0;
			if ((D_RYn == 1'b0) and (BRC == 1'b1)) begin
				D_LD <= 1'b1; Trans_sr_SE <= 1'b0; 
				TWC_LD <= 1'b0; 
				T_nstate <= s_start_bit;
			else 
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= idle;
			end
		when s_start_bit => // fiforead, send start bit
			TWC_CE <= 1'b0;
			if (BRC == 1'b1) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b1;
				T_nstate <= shift_data;
			else
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_start_bit;
			end
		when shift_data => // send data bit
			if (BRC == 1'b0) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; 
				TWC_LD <= 1'b0; TWC_CE <= 1'b0;
				T_nstate <= shift_data;
			end else if ((T_WCOUNT == 1) and (Parity_EN == 1'b1)) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; 
				TWC_LD <= 1'b0; TWC_CE <= 1'b1;
				T_nstate <= s_parity;
			end else if (T_WCOUNT == 1) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; 
				TWC_LD <= 1'b0; TWC_CE <= 1'b1;
				T_nstate <= s_stop_bit;
			else
				D_LD <= 1'b0; Trans_sr_SE <= 1'b1; 
				TWC_LD <= 1'b0; TWC_CE <= 1'b1;
				T_nstate <= shift_data;
			end
		when s_parity => // send parity bit
			TWC_CE <= 1'b0;
			if (BRC == 1'b1) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_stop_bit;
			else 
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_parity;
			end	 
		when s_stop_bit => // send stop bit
			TWC_CE <= 1'b0;
			if (BRC == 1'b0) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_stop_bit;
			end else if (stopB == 1'b1) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_stop_bit2;
			end else if (D_RYn == 1'b0) begin
				D_LD <= 1'b1; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_start_bit;
			else 
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= idle;
			end
		when s_stop_bit2 => // send stop bit 
			TWC_CE <= 1'b0;
			if ((D_RYn == 1'b0) and (BRC == 1'b1)) begin
				D_LD <= 1'b1; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_start_bit; 
			end else if (BRC == 1'b1) begin
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= idle;
			end else if ((num_bits == 5) and (x_dCOUNT == 7) and (D_RYn == 1'b0)) begin
				D_LD <= 1'b1; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_start_bit;
			end else if ((num_bits == 5) and (x_dCOUNT == 7)) begin
				D_LD <= 1'b1; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= idle;
			else 
				D_LD <= 1'b0; Trans_sr_SE <= 1'b0; TWC_LD <= 1'b0;
				T_nstate <= s_stop_bit2;
			end
		when others => 
			D_LD <= 1'b0; Trans_sr_SE <= 1'b0; 
			TWC_LD <= 1'b0; TWC_CE <= 1'b0;
			T_nstate <= idle;
	end case;
end

//
// registers for SM
always(CLK,rst)
begin
	if (rst == 1'b1) begin
		T_state <= idle;
	end else if (posedge(CLK)) begin
		T_state <= T_nstate;
	end
end

u3 : gh_counter_integer_down // word counter
	generic map (8)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => TWC_LD,
		CE => TWC_CE,
		D => num_bits,
		Q => T_WCOUNT
		);

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

	parity_Grst <= 1'b1 when (T_state == s_start_bit) else
	               1'b0;
	
U4 : gh_parity_gen_Serial 
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => parity_Grst,
		SD => BRC,
		D => Trans_shift_reg(0),
		Q => parity);

		
endmodule
endmodule
