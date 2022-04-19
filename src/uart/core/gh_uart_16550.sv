////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_uart_16550.vhd
//
//	Description:
//		designed to be a 16550 compatible UART 
//
//	Copyright (c) 2006, 2007, 2008 by H LeFevre 
//		A VHDL 16550 UART core
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:signal
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	02/25/06  	H LeFevre	Initial revision 
//	1.1     	03/18/06  	H LeFevre	mod to clear THREmpty interrupt 
//	        	          	         	    with IIR read 
//	1.2     	04/08/06  	H LeFevre	add time out interrupt
//	1.3     	04/19/06  	H LeFevre	fix read fifo signal, so fifo 
//	        	          	         	   will not lose data when baud rate 
//	        	          	         	   generatorread
//	2.0     	12/13/06  	H LeFevre	Fixed THRE interrupt, as recommended
//	       		          	         	   by Walter Hogan 12/12/06 
//	2.1     	12/23/06  	H LeFevre	replace fifo's
//	2.2    		01/20/07  	H LeFevre	replace read fifo 
//	2.3     	02/22/07  	B Chini  	Modified TOI Function To Work as Specified in 16550D manual
//	2.4    		07/12/07  	H LeFevre	fix 6, 7 bits transfers (LCR bits 1,0 were swapped
//       		          	         	   as pointed out by Matthias Klemm
//	2.5     	08/03/07  	H LeFevre	Mod TOI to fixsues missed in 2.3 (enabled with receiveIRQ, 
//       		          	         	   time reset with receive word- as Specified in 16550D manual)
//	2.6     	08/04/07  	H LeFevre	load TOI when receive IRQ disabled
//	2.7     	10/12/07  	H LeFevre	fix LSR Interrupt, as suggested by Matthias Klemm
//	   	    	          	         	+  mod to THRE Interrupt now, will be generated
//	   	    	          	         	   when enabled while trans FIFOempty
//	   	    	          	         	   (opencore bug report)
//	2.7     	10/13/07  	H LeFevre	mod LSR Interrupt so that it will retrigger with
//	   	    	          	         	   back to back errors
//	2.8     	07/21/08  	H LeFevre	mod equ for iBreak_ITR [add (and (not RF_EMPTY))]
//	        	        	         	   as suggested by Nathan Z.
//
////////////////////////////////////////////////////////////////////////////-
//library ieee ;
//use ieee.std_logic_1164.all ;

module gh_uart_16550 (
		clk     : in std_logic;
		BR_clk  : in std_logic;
		rst     : in std_logic;
		CS      : in std_logic;
		WR      : in std_logic;
		ADD     : in std_logic_vector(2 downto 0);
		D       : in std_logic_vector(7 downto 0);
		
		sRX	    : in std_logic;
		
		sTX     : out std_logic;
		DTRn    : out std_logic;
		RTSn    : out std_logic;
		OUT1n   : out std_logic;
		OUT2n   : out std_logic;
		TXRDYn  : out std_logic;
		RXRDYn  : out std_logic;
		
		IRQ     : out std_logic;
		B_CLK   : out std_logic;
		RD      : out std_logic_vector(7 downto 0)
		);
endmodule

architecture a of gh_uart_16550

COMPONENT gh_edge_det
(	
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		D   : in STD_LOGIC;
		re  : out STD_LOGIC; // rising edge (need sync source at D)
		fe  : out STD_LOGIC; // falling edge (need sync source at D)
		sre : out STD_LOGIC; // sync'd rising edge
		sfe : out STD_LOGIC  // sync'd falling edge
		);
end COMPONENT;

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

COMPONENT gh_DECODE_3to8
(
		A   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); // address
		G1  : IN  STD_LOGIC; // enable positive
		G2n : IN  STD_LOGIC; // enable negitive
		G3n : IN  STD_LOGIC; // enable negitive
		Y   : out STD_LOGIC_VECTOR(7 downto 0)
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

COMPONENT gh_uart_Tx_8bit	
(
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
end COMPONENT;

COMPONENT gh_uart_Rx_8bit	
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
end COMPONENT;

COMPONENT gh_fifo_async16_sr
	GENERIC (data_width: INTEGER :=8 ); // size of data bus
	port (					
		clk_WR : in STD_LOGIC; // write clock
		clk_RD : in STD_LOGIC; // read clock
		rst    : in STD_LOGIC; // resets counters
		srst   : in STD_LOGIC; // resets counters
		WR     : in STD_LOGIC; // write control 
		RD     : in STD_LOGIC; // read control
		D      : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Q      : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		empty  : out STD_LOGIC; 
		full   : out STD_LOGIC);
end COMPONENT;

COMPONENT gh_baud_rate_gen
(
		clk     : in std_logic;
		rst     : in std_logic;
		BR_clk  : in std_logic;
		WR      : in std_logic;
		BE      : in std_logic_vector (1 downto 0); // byte enable
		D       : in std_logic_vector (15 downto 0);
		RD      : out std_logic_vector (15 downto 0);
		rCE     : out std_logic;
		rCLK    : out std_logic
		);
end COMPONENT;

COMPONENT gh_fifo_async16_rcsr_wf
	GENERIC (data_width: INTEGER :=8 ); // size of data bus
	port (					
		clk_WR  : in STD_LOGIC; // write clock
		clk_RD  : in STD_LOGIC; // read clock
		rst     : in STD_LOGIC; // resets counters
		rc_srst : in STD_LOGIC:=1'b0; // resets counters (sync with clk_RD!!!)
		WR      : in STD_LOGIC; // write control 
		RD      : in STD_LOGIC; // read control
		D       : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Q       : out STD_LOGIC_VECTOR (data_width-1 downto 0);
		empty   : out STD_LOGIC; // sync with clk_RD!!!
		q_full  : out STD_LOGIC; // sync with clk_RD!!!
		h_full  : out STD_LOGIC; // sync with clk_RD!!!
		a_full  : out STD_LOGIC; // sync with clk_RD!!!
		full    : out STD_LOGIC);
end COMPONENT;

COMPONENT  gh_counter_down_ce_ld_tc
	GENERIC (size: INTEGER :=8);
(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		LOAD  : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		D     : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		TC    : OUT STD_LOGIC
		);
end COMPONENT;

COMPONENT  gh_edge_det_XCD// added 2 aug 2007
(
		iclk : in STD_LOGIC;  // clock for input data signal
		oclk : in STD_LOGIC;  // clock for output data pulse
		rst  : in STD_LOGIC;
		D    : in STD_LOGIC;
		re   : out STD_LOGIC; // rising edge 
		fe   : out STD_LOGIC  // falling edge 
		);
end COMPONENT;

	logic IER    : std_logic_vector(3 downto 0); // Interrupt Enable Register
	logic IIR    : std_logic_vector(7 downto 0); // Interrupt ID Register
	logic iIIR   : std_logic_vector(3 downto 0); // 12/23/06
	logic FCR    : std_logic_vector(7 downto 0); // FIFO Control register
	logic LCR    : std_logic_vector(7 downto 0); // Line Control Register
	logic MCR    : std_logic_vector(4 downto 0); // Modem Control Register
	logic LSR    : std_logic_vector(7 downto 0); // Line Status Register
	logic MSR    : std_logic_vector(7 downto 0); // Modem Status Register
	logic SCR    : std_logic_vector(7 downto 0); // Line Control Register
	logic RDD    : std_logic_vector(15 downto 0); // Divisor Latch 
	logic iMSR   : std_logic_vector(7 downto 4); // Modem Status Register
	logic RD_IIR;
	
	logic iRD    : std_logic_vector(7 downto 0);
	logic CSn   ;
	logic WR_B   : std_logic_vector(7 downto 0);
	logic WR_F  ;
	logic WR_IER;
	logic WR_D  ;
	logic WR_DML : std_logic_vector(1 downto 0);
	logic D16    : std_logic_vector(15 downto 0);
	logic BRC16x; // baud rate clock 
	
	logic ITR0  ;
	signalITR1;
	logic sITR1 ;
	logic cITR1 ;
	logic cITR1a;
	logic ITR1  ;
	logic ITR2  ;
	logic ITR3  ;
	
	logic DCTS    ;
	logic iLOOP   ;
	
	logic DDSR    ;

	logic TERI   ;
		
	logic DDCD    ;

	logic RD_MSR  ;
	logic MSR_CLR ;

	logic RD_LSR  ;
	logic LSR_CLR ;
	
	logic num_bits  : integer RANGE 0 to 8 :=0;
	logic stopB    ;
	logic Parity_EN;
	logic Parity_OD;
	logic Parity_EV;
//	logic Parity_sticky;
	logic Break_CB;
	
	logic TF_RD   ;
	logic TF_CLR  ;
	logic TF_CLRS ;
	logic TF_DO    : std_logic_vector(7 downto 0);
	logic TF_empty	: std_logic;
	logic TF_full ;

	logic RF_WR    ;
	logic RF_RD    ;
	logic RF_RD_brs; // added 3 aug 2007
	logic RF_CLR   ;
	logic RF_CLRS  ;
	logic RF_DI     : std_logic_vector(10 downto 0); // Read FIFO data input
	logic RF_DO     : std_logic_vector(10 downto 0); // Read FIFO data output
	logic RF_empty ;
	logic RF_full  ;
	logic RD_RDY   ;
	
	logic iParity_ER; // added 13 oct 2007
	logic iFRAME_ER ; // added 13 oct 2007
	logic iBreak_ITR; // added 13 oct 2007
	logic Parity_ER ;
	logic FRAME_ER  ;
	logic Break_ITR ;
	logic TSR_EMPTY ;
	logic OVR_ER    ;
	signalTX      ;
	signalRX      ;
	
	logic q_full  ;
	logic h_full  ;
	logic a_full  ;
	
	logic RF_ER  ;
	logic TX_RDY ;
	logic TX_RDYS;
	logic TX_RDYC;
	logic RX_RDY ;
	logic RX_RDYS;
	logic RX_RDYC;

	logic TOI     ; // time out interrupt 
	logic TOI_enc ; // time out interrupt counter inable
	logic iTOI_enc;
	logic TOI_set ;
	logic iTOI_set; // added 3 aug 2007
	logic TOI_clr ;
	logic TOI_c_ld;
	logic TOI_c_d  : std_logic_vector(11 downto 0);
	
begin

//////////////////////////////////////////////
//// resd   //////////////////////////////////
//////////////////////////////////////////////

	RD <= RF_DO(7 downto 0) when ((ADD == o"0") and (LCR(7) == 1'b0)) else
	      (x"0" & IER) when ((ADD == o"1") and (LCR(7) == 1'b0)) else
	      IIR when (ADD == o"2") else
	      LCR when (ADD == o"3") else
	      ("000" & MCR) when (ADD == o"4") else
	      LSR when (ADD == o"5") else
	      MSR when (ADD == o"6") else
	      SCR when (ADD == o"7") else
	      RDD(7 downto 0) when (ADD == o"0") else
	      RDD(15 downto 8);

//////////////////////////////////////////////

U1 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => TX_RDYS,
		k => TX_RDYC,
		Q => TX_RDY);	  
	
	TXRDYn <= (not TX_RDY);
		
	TX_RDYS <= 1'b1 when ((FCR(3) == 1'b0) and (TF_empty == 1'b1) and (TSR_EMPTY == 1'b1)) else
	           1'b1 when ((FCR(3) == 1'b1) and (TF_empty == 1'b1)) else
	           1'b0;
	
	TX_RDYC <= 1'b1 when ((FCR(3) == 1'b0) and (TF_empty == 1'b0)) else
	           1'b1 when ((FCR(3) == 1'b1) and (TF_full == 1'b1)) else
	           1'b0;
	
U2 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => RX_RDYS,
		k => RX_RDYC,
		Q => RX_RDY);	
		
	RXRDYn <= (not RX_RDY);
		
	RX_RDYS <= 1'b1 when ((FCR(3) == 1'b0) and (RF_empty == 1'b0)) else	// mod 01/20/07
	           1'b1 when ((FCR(3) == 1'b1) and (FCR(7 downto 6) == "11") and (a_full == 1'b1)) else
	           1'b1 when ((FCR(3) == 1'b1) and (FCR(7 downto 6) == "10") and (h_full == 1'b1)) else
	           1'b1 when ((FCR(3) == 1'b1) and (FCR(7 downto 6) == "01") and (q_full == 1'b1)) else
	           1'b1 when ((FCR(3) == 1'b1) and (FCR(7 downto 6) == "00") and (RF_empty == 1'b0)) else
	           1'b0;
		
		
	RX_RDYC <= 1'b1 when (RF_empty == 1'b1) else
	           1'b0;
		
		
//////////////////////////////////////////////
//// Modem Status Register Bits //////////////
//////////////////////////////////////////////

U4 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => 1'b0, // TODO Optimize out 1'b0 inputs (becomes D-ff w/ K as enable)
		k => MSR_CLR,
		Q => DCTS);
	
	MSR(0) <= DCTS;

U6 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => 1'b0,
		k => MSR_CLR,
		Q => DDSR);
	
	MSR(1) <= DDSR;
		
U8 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => 1'b0,
		k => MSR_CLR,
		Q => TERI);
	
	MSR(2) <= TERI;

U10 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => 1'b0,
		k => MSR_CLR,
		Q => DDCD);
	
	MSR(3) <= DDCD;
	
	iMSR(4) <= 1'b0 when (iLOOP == 1'b0) else
	            MCR(1);
	
	iMSR(5) <= 1'b0 when (iLOOP == 1'b0) else
	            MCR(0);
	
	iMSR(6) <= 1'b0 when (iLOOP == 1'b0) else
	            MCR(2);
	
	iMSR(7) <= 1'b0 when (iLOOP == 1'b0) else
	            MCR(3);
  
	RD_MSR <= 1'b0 when ((CS == 1'b0) or (WR == 1'b1)) else
	          1'b0 when (ADD /= o"6") else
	          1'b1;


	ITR0 <= 1'b0 when (IER(3) == 1'b0) else
	        1'b1 when (MSR(3 downto 0) > x"0") else
	        1'b0;
			  
U11 : gh_edge_det 
	PORT MAP (
		clk => clk,
		rst => rst,
		d => RD_MSR,
		sfe => MSR_CLR);

u12 : gh_register_ce 
	generic map (4)
	port map(
		clk => clk,
		rst => rst,
		ce => 1'b1,
		D => iMSR,
		Q => MSR(7 downto 4)
		);
		
//////////////////////////////////////////////////-
//////// LSR //////////////////////////////////////
//////////////////////////////////////////////////-

	LSR(0) <= (not RF_empty);

U13 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => OVR_ER,
		k => LSR_CLR,
		Q => LSR(1));

	OVR_ER <= 1'b1 when ((RF_full == 1'b1) and (RF_WR == 1'b1)) else
	          1'b0;
		
U14 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => PARITY_ER,
		k => LSR_CLR,
		Q => LSR(2));

U15 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => FRAME_ER,
		k => LSR_CLR,
		Q => LSR(3));

U16 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => Break_ITR,
		k => LSR_CLR,
		Q => LSR(4));

	LSR(5) <= TF_EMPTY;
	LSR(6) <= TF_EMPTY and TSR_EMPTY;

U17 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => RF_ER,
		k => LSR_CLR,
		Q => LSR(7));

	RF_ER <= 1'b1 when (RF_DI(10 downto 8) > "000") else
	         1'b0;
	
	RD_LSR <= 1'b0 when ((CS == 1'b0) or (WR == 1'b1)) else
	          1'b0 when (ADD /= o"5") else
	          1'b1;
	
U18 : gh_edge_det 
	PORT MAP (
		clk => clk,
		rst => rst,
		d => RD_LSR,
		sfe => LSR_CLR);
		
//////////////////////////////////////////////
//////  registers //////-
//////////////////////////////////////////////

	CSn <= (not CS);
	
	
u19 : gh_DECODE_3to8 
	port map(
		A => ADD,
		G1 => WR,
		G2n => CSn,
		G3n => 1'b0,
		Y => WR_B
		);

	WR_F <= WR_B(0) and (not LCR(7));
	WR_IER <= WR_B(1) and (not LCR(7));
	WR_D <= LCR(7) and (WR_B(0) or WR_B(1));
	WR_DML <= (WR_B(1) and LCR(7)) & (WR_B(0) and LCR(7));
		
u20 : gh_register_ce 
	generic map (4)
	port map(
		clk => clk,
		rst => rst,
		ce => WR_IER,
		D => D(3 downto 0),
		Q => IER
		);
		
u21 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => WR_B(2),
		D => D,
		Q => FCR
		);
		
U22 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => RF_CLRS,
		k => RF_EMPTY,
		Q => RF_CLR);
		
	RF_CLRS <= D(1) AND WR_B(2);
		
U23 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => TF_CLRS,
		k => TF_EMPTY,
		Q => TF_CLR);
		
	TF_CLRS <= D(2) AND WR_B(2);
		
u24 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => WR_B(3),
		D => D,
		Q => LCR
		);		
	
	num_bits <= 5 when ((LCR(0) == 1'b0) and (LCR(1) == 1'b0)) else
	            6 when ((LCR(0) == 1'b1) and (LCR(1) == 1'b0)) else	 // 07/12/07
	            7 when ((LCR(0) == 1'b0) and (LCR(1) == 1'b1)) else	 // 07/12/07
	            8;				   

	stopB <= LCR(2);
	
	Parity_EN <= LCR(3);
	Parity_OD <= LCR(3) and (not LCR(4)) and (not LCR(5));
	Parity_EV <= LCR(3) and LCR(4) and (not LCR(5)); 
//	Parity_sticky <= LCR(3) and LCR(5);
	Break_CB <= LCR(6);
		
u25 : gh_register_ce 
	generic map (5)
	port map(
		clk => clk,
		rst => rst,
		ce => WR_B(4),
		D => D(4 downto 0),
		Q => MCR
		);		

	DTRn <= (not MCR(0)) or iLOOP;
	RTSn <= (not MCR(1)) or iLOOP;
	OUT1n <= (not MCR(2)) or iLOOP;
	OUT2n <= (not MCR(3)) or iLOOP;
  	iLOOP <= MCR(4);   
	  
u26 : gh_register_ce 
	generic map (8)
	port map(
		clk => clk,
		rst => rst,
		ce => WR_B(7),
		D => D,
		Q => SCR
		);		

//////////////////////////////////////////////////////////
		
	D16 <= D & D;
		
u27 : gh_baud_rate_gen
	port map(
		clk => clk,  
		BR_clk => BR_clk, 
		rst  => rst, 
		WR => WR_D,
		BE => WR_DML,
		D => D16,
		RD => RDD,
		rCE => BRC16x,
		rCLK => B_clk
		);		
	
//////////////////////////////////////////////////
//// trans FIFO   12/23/06 //////////////////////-
//////////////////////////////////////////////////

U28 : gh_fifo_async16_sr
	Generic Map(data_width => 8)
	PORT MAP (
		clk_WR => clk,
		clk_RD => BR_clk,
		rst => rst,
		srst => TF_CLR,
		WR => WR_F,
		RD => TF_RD,
		D => D,
		Q => TF_DO,
		empty => TF_empty,
		full => TF_full);

////////////////////////////////////////////////////////////////
//////////- added 03/18/06 ////////////////////////////////////-
//////////-  mod 10/12/07 //////////////////////////////////////

U28a : gh_edge_det  
	PORT MAP (
		clk => clk,
		rst => rst,
		d =>ITR1,
		sre => sITR1);
		
	isITR1 <= TF_empty and IER(1);
	
////////// end mod 10/12/07 ////////////////-
	
	RD_IIR <= 1'b0 when (ADD /= o"2") else
	          1'b0 when (WR == 1'b1) else
	          1'b0 when (CS == 1'b0) else
	          1'b0 when (IIR(3 downto 1) /= "001") else // walter hogan 12/12/2006
	          1'b1;

U28b : gh_edge_det  
	PORT MAP (
		clk => clk,
		rst => rst,
		d => RD_IIR,
		sfe => cITR1a);
		
	cITR1 <= cITR1a or (not TF_empty);
		
U28c : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => sITR1,
		k => cITR1,
		Q => ITR1);
		
//////////- added 03/18/06 //////////////////////////////////////////
////////////////////////////////////////////////////////////////////-

U29 : gh_UART_Tx_8bit 
	PORT MAP (
		clk => BR_clk,
		rst => rst,
		xBRC => BRC16x,
		D_RYn => TF_empty,
		D => TF_DO,
		num_bits => num_bits,
		Break_CB => Break_CB,
		StopB => stopB,
		Parity_EN => Parity_EN,
		Parity_EV => Parity_EV,
		sTX =>TX,
		BUSYn => TSR_EMPTY,
		read => TF_RD);

	sTX <=TX;

		
//////////////////////////////////////////////////
//// Receive FIFO //////////////////////////////////
//////////////////////////////////////////////////

U30 : gh_edge_det 
	PORT MAP (
		clk => BR_clk,
		rst => rst,
		d => RD_RDY,
		re => RF_WR);
		
	RF_RD <= 1'b0 when (LCR(7) == 1'b1) else // added 04/19/06
	         1'b1 when ((ADD == "000") and (CS == 1'b1) and (WR == 1'b0)) else
	         1'b0;
		
U31 : gh_fifo_async16_rcsr_wf // 01/20/07
	Generic Map(data_width => 11)
	PORT MAP (
		clk_WR => BR_clk,
		clk_RD => clk,
		rst => rst,
		rc_srst => RF_CLR,
		WR => RF_WR,
		RD => RF_RD,
		D => RF_DI,
		Q => RF_DO,
		empty => RF_empty,
		q_full => q_full,
		h_full => h_full,
		a_full => a_full,
		full => RF_full);

//////////// 10/12/07 //////////////////////////////////////
////- as suggested  Matthias Klemm ////////////////////////-
////- mod 10/13/07 ////////////////////////////////////////-

	iParity_ER <= RF_DO(8) and (not RF_RD);

U32a : gh_edge_det 
	PORT MAP (
		clk => clk,
		rst => rst,
		d => iParity_ER,
		sre => Parity_ER);
		
	iFRAME_ER <= RF_DO(9) and (not RF_RD);
		
U32b : gh_edge_det 
	PORT MAP (
		clk => clk,
		rst => rst,
		d => iFRAME_ER,
		sre => FRAME_ER);
		
	iBreak_ITR <= RF_DO(10) and (not RF_RD) and (not RF_EMPTY);	// 07/21/08
		
U32c : gh_edge_det 
	PORT MAP (
		clk => clk,
		rst => rst,
		d => iBreak_ITR,
		sre => Break_ITR);
	
	ITR3 <= 1'b0 when (IER(2) == 1'b0) else
	        1'b1 when (LSR(1) == 1'b1) else
	        1'b1 when (LSR(4 downto 2) > "000") else
	        1'b0;

//////////////////////////////////////////////////////////////////////-

			
	isRX <= sRX when (iLOOP == 1'b0) else
	       TX;


	ITR2 <= 1'b0 when (IER(0) == 1'b0) else  // mod 01/20/07
	        1'b1 when ((FCR(7 downto 6) == "11") and (a_full == 1'b1)) else
	        1'b1 when ((FCR(7 downto 6) == "10") and (h_full == 1'b1)) else
	        1'b1 when ((FCR(7 downto 6) == "01") and (q_full == 1'b1)) else
	        1'b1 when ((FCR(7 downto 6) == "00") and(RF_empty == 1'b0)) else
	        1'b0;
 
U33 : gh_UART_Rx_8bit 
	PORT MAP (
		clk => BR_clk,
		rst => rst,
		BRCx16 => BRC16x,
		sRX =>RX,
		num_bits => num_bits,
		Parity_EN => Parity_EN,
		Parity_EV => Parity_EV,
		Parity_ER => RF_DI(8),
		FRAME_ER => RF_DI(9),
		Break_ITR => RF_DI(10),
		D_RDY => RD_RDY,
		D => RF_DI(7 downto 0)
		);

////////////////////////////////////////////////////////////////
////////// added 04/08/06 time out interrupt //////////////////-
////////// once there a received data wordrecieved, ////////
////////// the counter will be running until //////////////////-
////////// FIFOempty, counter reset on FIFO read or write //
//////- mod 3 aug 2007

	TOI_clr <= RF_empty or RF_RD or (not IER(0)); 

U34 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => TOI_set,
		k => TOI_clr,
		Q => TOI);

U35 : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => LSR(0), // enable time out counter with received data
		k => RF_empty, // once FIFOempty, stop counter
		Q => iTOI_enc);
		
U35a : gh_edge_det_XCD 
	PORT MAP (
		iclk => clk,
		oclk => BR_clk,
		rst => rst,
		d => RF_RD,
		re => RF_RD_brs,
		fe => open);
		
always(BR_clk,rst)
begin
	if (rst == 1'b1) begin
		TOI_enc <= 1'b0;
	end else if (posedge(BR_clk)) begin
		TOI_enc <= iTOI_enc;
	end
end

	TOI_c_ld <= 1'b1 when (IER(0) == 1'b0) else // added 4 aug 2007
	            1'b1 when (TOI_enc == 1'b0) else
	            1'b1 when (RF_RD_brs == 1'b1) else
	            1'b1 when (RF_WR == 1'b1) else 
	            1'b0;
		
U36 : gh_counter_down_ce_ld_tc
	generic	map(10)
	port map(
		clk => BR_clk,
		rst => rst,
		LOAD => TOI_c_ld,
		CE => BRC16x,
		D => TOI_c_d(9 downto 0),
//		Q => ,
		TC => iTOI_set
		);

U36a : gh_edge_det_XCD 
	PORT MAP (
		iclk => BR_clk,
		oclk => clk,
		rst => rst,
		d => iTOI_set,
		re => TOI_set,
		fe => open);

		
	TOI_c_d <= x"1C0" when (num_bits == 5) else
	           x"200" when (num_bits == 6) else
	           x"240" when (num_bits == 7) else
	           x"280";// when (num_bits == 8)

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

	IRQ <= 1'b1 when ((ITR3 or ITR2 or TOI or ITR1 or ITR0) == 1'b1) else
	       1'b0;
		   
	iIIR(0) <= 1'b0 when ((ITR3 or ITR2 or TOI or ITR1 or ITR0) == 1'b1) else
	           1'b1;
			  
	iIIR(3 downto 1) <= "011" when (ITR3 == 1'b1) else
	                    "010" when (ITR2 == 1'b1) else
	                    "110" when (TOI  == 1'b1) else	// added 04/08/06	
	                    "001" when (ITR1 == 1'b1) else
	                    "000";
			  
	IIR(7 downto 4) <= x"C"; // FIFO's always enabled

u37 : gh_register_ce // 12/23/06
	generic map (4)
	port map(
		clk => clk,
		rst => rst,
		ce => CSn,
		D => iIIR,
		Q => IIR(3 downto 0)
		);	

//////////////////////////////////////////////////////////////

endmodule
