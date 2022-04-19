////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_uart_Rx_8bit.vhd
//
//	Description:
//		an 8 bit UART Rx Module
//
//	Copyright (c) 2006 by H LeFevre 
//		A VHDL 16550 UART core
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	02/18/06  	H LeFevre  	Initial revision
//	1.1      	02/25/06  	H LeFevre  	mod to SM, goes to idle faster
//	        	          	         	   if no break error  
//	2.0     	06/18/07  	P.Azkarate  Define "range" in R_WCOUNT and R_brdCOUNT signals
////////////////////////////////////////////////////////////////////////////-
//library ieee ;
//use ieee.std_logic_1164.all ;

module gh_uart_Rx_8bit
(
		clk       : in std_logic; // clock
		rst       : in std_logic;
		BRCx16    : in std_logic; // 16x clock enable
		sRX       : in std_logic; 
		num_bits  : in integer RANGE 0 to 8;
		Parity_EN : in std_logic;
		Parity_EV : in std_logic;
		Parity_ER : out std_logic;
		Frame_ER  : out std_logic;
		Break_ITR : out std_logic;
		D_RDY     : out std_logic;
		D         : out std_logic_vector(7 downto 0)
		);
endmodule
	
architecture a of gh_uart_Rx_8bit

COMPONENT gh_shift_reg_se_sl
	GENERIC (size: INTEGER := 16); 
(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		srst     : IN STD_logic:=1'b0;
		SE       : IN STD_logic; // shift enable
		D        : IN STD_LOGIC;
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

COMPONENT gh_jkff
(	
		clk  : IN STD_logic;
		rst  : IN STD_logic;
		J,K  : IN STD_logic;
		Q    : OUT STD_LOGIC
		);
end COMPONENT;

	type R_StateType(idle,R_start_bit,shift_data,R_parity,
	                     R_stop_bit,break_err);
	logic R_state, R_nstate : R_StateType; 

	logic parity     ;
	logic parity_Grst;
	logic RWC_LD     ;
	logic R_WCOUNT : integer range 0 to 15;
	logic s_DATA_LD;
	logic chk_par;
	logic chk_frm;
	logic clr_brk;
	logic clr_D;
	logic s_chk_par;
	logic s_chk_frm;
	logic R_shift_reg : std_logic_vector(7 downto 0);
	logic iRX;
	logic BRC;
	logic dCLK_LD;
	logic R_brdCOUNT : integer range 0 to 15;
	logic iParity_ER;
	logic iFrame_ER;
	logic iBreak_ITR;
	logic iD_RDY;
	
begin

//////////////////////////////////////////////
//// outputs//////////////////////////////////
//////////////////////////////////////////////
always(CLK,rst)
begin
	if (rst == 1'b1) begin	
		Parity_ER <= 1'b0;
		Frame_ER <= 1'b0;
		Break_ITR <= 1'b0;
		D_RDY <= 1'b0;
	end else if (posedge(CLK)) begin
		if (BRCx16 == 1'b1) begin
			D_RDY <= iD_RDY;
			if (iD_RDY == 1'b1) begin
				Parity_ER <= iParity_ER;
				Frame_ER <= iFrame_ER;
				Break_ITR <= iBreak_ITR;
			end
		end
	end
end

	D <= R_shift_reg when (num_bits == 8) else
	    (1'b0 & R_shift_reg(7 downto 1)) when (num_bits == 7) else
	    ("00" & R_shift_reg(7 downto 2)) when (num_bits == 6) else
	    ("000" & R_shift_reg(7 downto 3)); // when (bits_word == 5) else


//////////////////////////////////////////////

	dCLK_LD <= 1'b1 when (R_state == idle) else
	           1'b0;
			   
	BRC <= 1'b0 when (BRCx16 == 1'b0) else
	       1'b1 when (R_brdCOUNT == 0) else
	       1'b0;
		   
u1 : gh_counter_integer_down // baud rate divider
	generic map (15)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => dCLK_LD,
		CE => BRCx16,
		D => 14,
		Q => R_brdCOUNT);
		
//////////////////////////////////////////////////////////

U2 : gh_shift_reg_se_sl 
	Generic Map(8)
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => clr_D,
		SE => s_DATA_LD,
		D => sRX,
		Q => R_shift_reg);

//////////////////////////////////////////////////////////-

	chk_par <= s_chk_par and (((parity xor iRX) and Parity_EV) 
	                 or (((not parity) xor iRX) and (not Parity_EV)));

U2c : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => chk_par,
		k => dCLK_LD,
		Q => iParity_ER);

	chk_frm <= s_chk_frm and (not iRX);
		
U2d : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => chk_frm,
		k => dCLK_LD,
		Q => iFrame_ER);

U2e : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => clr_d,
		k => clr_brk,
		Q => iBreak_ITR);
		
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////


always(R_state,BRCx16,BRC,iRX,R_WCOUNT,Parity_EN,R_brdCOUNT,iBreak_ITR)
begin
	case R_state
		when idle => // idle  
			iD_RDY <= 1'b0; s_DATA_LD <= 1'b0; RWC_LD <= 1'b1; 
			s_chk_par <= 1'b0; s_chk_frm <= 1'b0; clr_brk <= 1'b0;
			clr_D <= 1'b0;
			if (iRX == 1'b0) begin	
				R_nstate <= R_start_bit;
			else 
				R_nstate <= idle;
			end
		when R_start_bit => // 
			iD_RDY <= 1'b0; s_DATA_LD <= 1'b0; RWC_LD <= 1'b1; 
			s_chk_par <= 1'b0; s_chk_frm <= 1'b0; clr_brk <= 1'b0;
			if (BRC == 1'b1) begin
				clr_D <= 1'b1;
				R_nstate <= shift_data;
			end else if ((R_brdCOUNT == 8) and (iRX == 1'b1)) begin // false start bit detection
				clr_D <= 1'b0;
				R_nstate <= idle;
			else
				clr_D <= 1'b0;
				R_nstate <= R_start_bit;
			end
		when shift_data => // send data bit	
			iD_RDY <= 1'b0; RWC_LD <= 1'b0;
			s_chk_par <= 1'b0; s_chk_frm <= 1'b0;
			clr_D <= 1'b0;
			if (BRCx16 == 1'b0) begin
				s_DATA_LD <= 1'b0; clr_brk <= 1'b0;
				R_nstate <= shift_data;	
			end else if (R_brdCOUNT == 8) begin
				s_DATA_LD <= 1'b1; clr_brk <= iRX; 
				R_nstate <= shift_data;	
			end else if ((R_WCOUNT == 1) and (R_brdCOUNT == 0) and (Parity_EN == 1'b1)) begin
				s_DATA_LD <= 1'b0; clr_brk <= 1'b0;
				R_nstate <= R_parity;	
			end else if ((R_WCOUNT == 1) and (R_brdCOUNT == 0)) begin
				s_DATA_LD <= 1'b0; clr_brk <= 1'b0;
				R_nstate <= R_stop_bit;
			else
				s_DATA_LD <= 1'b0; clr_brk <= 1'b0; 
				R_nstate <= shift_data;
			end
		when R_parity => // check parity bit
			iD_RDY <= 1'b0; s_DATA_LD <= 1'b0; 
			RWC_LD <= 1'b0; s_chk_frm <= 1'b0;
			clr_D <= 1'b0;
			if (BRCx16 == 1'b0) begin
				s_chk_par <= 1'b0;  clr_brk <= 1'b0;
				R_nstate <= R_parity;
			end else if (R_brdCOUNT == 8) begin
				s_chk_par <= 1'b1; clr_brk <= iRX; 
				R_nstate <= R_parity;
			end else if (BRC == 1'b1) begin
				s_chk_par <= 1'b0; clr_brk <= 1'b0;
				R_nstate <= R_stop_bit;
			else 
				s_chk_par <= 1'b0; clr_brk <= 1'b0;
				R_nstate <= R_parity;
			end	 
		when R_stop_bit => // check stop bit
			s_DATA_LD <= 1'b0; RWC_LD <= 1'b0; 
			s_chk_par <= 1'b0; clr_brk <= iRX;
			clr_D <= 1'b0;
			if ((BRC == 1'b1) and (iBreak_ITR == 1'b1)) begin
				iD_RDY <= 1'b1; s_chk_frm <= 1'b0;
				R_nstate <= break_err; 
			end else if (BRC == 1'b1) begin
				iD_RDY <= 1'b1; s_chk_frm <= 1'b0;
				R_nstate <=	idle;
			end else if (R_brdCOUNT == 8) begin
				iD_RDY <= 1'b0; s_chk_frm <= 1'b1;
				R_nstate <= R_stop_bit;	
			end else if ((R_brdCOUNT == 7) and (iBreak_ITR == 1'b0)) begin // added 02/20/06
				iD_RDY <= 1'b1; s_chk_frm <= 1'b0;
				R_nstate <=	idle;
			else 
				iD_RDY <= 1'b0; s_chk_frm <= 1'b0;
				R_nstate <= R_stop_bit;
			end	
		when break_err => 
			iD_RDY <= 1'b0; s_DATA_LD <= 1'b0; RWC_LD <= 1'b0; 
			s_chk_par <= 1'b0; s_chk_frm <= 1'b0; clr_brk <= 1'b0;
			clr_D <= 1'b0;
			if (iRX == 1'b1) begin
				R_nstate <= idle;
			else
				R_nstate <= break_err;
			end
		when others => 
			iD_RDY <= 1'b0; s_DATA_LD <= 1'b0; RWC_LD <= 1'b0; 
			s_chk_par <= 1'b0; s_chk_frm <= 1'b0; clr_brk <= 1'b0;
			clr_D <= 1'b0;
			R_nstate <= idle;
	end case;
end

//
// registers for SM
always(CLK,rst)
begin
	if (rst == 1'b1) begin	
		iRX <= 1'b1;
		R_state <= idle;
	end else if (posedge(CLK)) begin
		if (BRCx16 == 1'b1) begin
			iRX <= sRX;
			R_state <= R_nstate;
		else 
			iRX <= iRX;
			R_state <= R_state;
		end
	end
end

u3 : gh_counter_integer_down // word counter
	generic map (8)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => RWC_LD,
		CE => BRC,
		D => num_bits,
		Q => R_WCOUNT
		);

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
			   
	parity_Grst <= 1'b1 when (R_state == R_start_bit) else
	               1'b0;
	
U4 : gh_parity_gen_Serial 
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => parity_Grst,
		SD => BRC,
		D => R_shift_reg(7),
		Q => parity);

		
endmodule

