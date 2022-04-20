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
module gh_uart_16550 (
  input logic clk,
  input logic br_clk,
  input logic rst,
  input logic cs,
  input logic wr,
  input logic [2:0] add,
  input logic [7:0] d,

  input logic srx,

  output logic stx,
  output logic dtrn,
  output logic rtsn,
  output logic out1n,
  output logic out2n,
  output logic txrdyn,
  output logic rxrdyn,

  output logic irq,
  output logic b_clk,
  output logic [7:0] rd
);

  logic [3:0] ier;   // interrupt enable register
  logic [7:0] iir;   // interrupt id register
  logic [3:0] iiir;  // 12/23/06
  logic [7:0] fcr;   // fifo control register
  logic [7:0] lcr;   // line control register
  logic [4:0] mcr;   // modem control register
  logic [7:0] lsr;   // line status register
  logic [7:0] msr;   // modem status register
  logic [7:0] scr;   // line control register
  logic [15:0] rdd;  // divisor latch
  logic [7:4] imsr;  // modem status register
  logic rd_iir;

  logic [7:0] ird;
  logic csn;
  logic [7:0] wr_b;
  logic wr_f;
  logic wr_ier;
  logic wr_d;
  logic [1:0] wr_dml;
  logic [15:0] d16;
  logic brc16x;  // baud rate clock

  logic itr0;
  logic isitr1;
  logic sitr1;
  logic citr1;
  logic citr1a;
  logic itr1;
  logic itr2;
  logic itr3;

  logic dcts;
  logic iloop;

  logic ddsr;

  logic teri;

  logic ddcd;

  logic rd_msr;
  logic msr_clr;

  logic rd_lsr;
  logic lsr_clr;

  int num_bits;  // range 0 to 8 :=0;
  logic stopb;
  logic parity_en;
  logic parity_od;
  logic parity_ev;
//logic parity_sticky;
  logic break_cb;

  logic tf_rd;
  logic tf_clr;
  logic tf_clrs;
  logic [7:0] tf_do;
  logic tf_empty;
  logic tf_full;

  logic rf_wr;
  logic rf_rd;
  logic rf_rd_brs;  // added 3 aug 2007
  logic rf_clr;
  logic rf_clrs;
  logic [10:0] rf_di;  // read fifo data input
  logic [10:0] rf_do;  // read fifo data output
  logic rf_empty;
  logic rf_full;
  logic rd_rdy;

  logic iparity_er;  // added 13 oct 2007
  logic iframe_er;   // added 13 oct 2007
  logic ibreak_itr;  // added 13 oct 2007
  logic parity_er;
  logic frame_er;
  logic break_itr;
  logic tsr_empty;
  logic ovr_er;
  logic istx;
  logic isrx;

  logic q_full;
  logic h_full;
  logic a_full;

  logic rf_er;
  logic tx_rdy;
  logic tx_rdys;
  logic tx_rdyc;
  logic rx_rdy;
  logic rx_rdys;
  logic rx_rdyc;

  logic toi;      // time out interrupt
  logic toi_enc;  // time out interrupt counter inable
  logic itoi_enc;
  logic toi_set;
  logic itoi_set;  // added 3 aug 2007
  logic toi_clr;
  logic toi_c_ld;
  logic [11:0] toi_c_d;

//--------------------------------------------
//-- resd   ----------------------------------
//--------------------------------------------

  assign rd = ((add == 0) & (lcr[7] == 1'b0)) ? rf_do[7:0] :
              ((add == 1) & (lcr[7] == 1'b0)) ? ({4'h0, ier}) :
              (add == 2) ? iir :
              (add == 3) ? lcr :
              (add == 4) ? ({3'b000, mcr}) :
              (add == 5) ? lsr :
              (add == 6) ? msr :
              (add == 7) ? scr :
              (add == 0) ? rdd[7:0] : rdd[15:8];

//--------------------------------------------

  gh_jkff u1 (
    .clk(clk),
    .rst(rst),
    .j(tx_rdys),
    .k(tx_rdyc),
    .q(tx_rdy)
  );

  assign txrdyn = (~tx_rdy);

  assign tx_rdys = ((fcr[3] == 1'b0) & (tf_empty == 1'b1) & (tsr_empty == 1'b1)) ? 1'b1 :
                   ((fcr[3] == 1'b1) & (tf_empty == 1'b1)) ? 1'b1 : 1'b0;

  assign tx_rdyc = ((fcr[3] == 1'b0) & (tf_empty == 1'b0)) ? 1'b1 :
                   ((fcr[3] == 1'b1) & (tf_full == 1'b1)) ? 1'b1 : 1'b0;

  gh_jkff u2 (
    .clk(clk),
    .rst(rst),
    .j(rx_rdys),
    .k(rx_rdyc),
    .q(rx_rdy)
  );

  assign rxrdyn = (~rx_rdy);

  assign rx_rdys = ((fcr[3] == 1'b0) & (rf_empty == 1'b0)) ? 1'b1 :  // mod 01/20/07
                   ((fcr[3] == 1'b1) & (fcr[7:6] == 2'b11) & (a_full == 1'b1)) ? 1'b1 :
                   ((fcr[3] == 1'b1) & (fcr[7:6] == 2'b10) & (h_full == 1'b1)) ? 1'b1 :
                   ((fcr[3] == 1'b1) & (fcr[7:6] == 2'b01) & (q_full == 1'b1)) ? 1'b1 :
                   ((fcr[3] == 1'b1) & (fcr[7:6] == 2'b00) & (rf_empty == 1'b0)) ? 1'b1 : 1'b0;


  assign rx_rdyc = (rf_empty == 1'b1) ? 1'b1 : 1'b0;


//--------------------------------------------
//-- modem status register bits --------------
//--------------------------------------------

  gh_jkff u4 (
    .clk(clk),
    .rst(rst),
    .j(1'b0),  // todo optimize out 1'b0 inputs (becomes d-ff w/ k as enable)
    .k(msr_clr),
    .q(dcts)
  );

  assign msr[0] = dcts;

  gh_jkff u6 (
    .clk(clk),
    .rst(rst),
    .j(1'b0),
    .k(msr_clr),
    .q(ddsr)
  );

  assign msr[1] = ddsr;

  gh_jkff u8 (
    .clk(clk),
    .rst(rst),
    .j(1'b0),
    .k(msr_clr),
    .q(teri)
  );

  assign msr[2] = teri;

  gh_jkff u10 (
    .clk(clk),
    .rst(rst),
    .j(1'b0),
    .k(msr_clr),
    .q(ddcd)
  );

  assign msr[3] = ddcd;

  assign imsr[4] = (iloop == 1'b0) ? 1'b0 : mcr[1];

  assign imsr[5] = (iloop == 1'b0) ? 1'b0 : mcr[0];

  assign imsr[6] = (iloop == 1'b0) ? 1'b0 : mcr[2];

  assign imsr[7] = (iloop == 1'b0) ? 1'b0 : mcr[3];

  assign rd_msr = ((cs == 1'b0) | (wr == 1'b1)) ? 1'b0 :
                  (add != 6) ? 1'b0 : 1'b1;


  assign itr0 = (ier[3] == 1'b0) ? 1'b0 :
                (msr[3:0] > 4'h0) ? 1'b1 : 1'b0;

  gh_edge_det u11 (
    .clk(clk),
    .rst(rst),
    .d(rd_msr),
    .sfe(msr_clr)
  );

  gh_register_ce #(
    .size(4)
  ) u12 (
    .clk(clk),
    .rst(rst),
    .ce(1'b1),
    .d(imsr),
    .q(msr[7:4])
  );

//-------------------------------------------------
//------ lsr --------------------------------------
//-------------------------------------------------

  assign lsr[0] = (~rf_empty);

  gh_jkff u13 (
    .clk(clk),
    .rst(rst),
    .j(ovr_er),
    .k(lsr_clr),
    .q(lsr[1])
  );

  assign ovr_er = ((rf_full == 1'b1) & (rf_wr == 1'b1)) ? 1'b1 : 1'b0;

  gh_jkff u14 (
    .clk(clk),
    .rst(rst),
    .j(parity_er),
    .k(lsr_clr),
    .q(lsr[2])
  );

  gh_jkff u15 (
    .clk(clk),
    .rst(rst),
    .j(frame_er),
    .k(lsr_clr),
    .q(lsr[3])
  );

  gh_jkff u16 (
    .clk(clk),
    .rst(rst),
    .j(break_itr),
    .k(lsr_clr),
    .q(lsr[4])
  );

  assign lsr[5] = tf_empty;
  assign lsr[6] = tf_empty & tsr_empty;

  gh_jkff u17 (
    .clk(clk),
    .rst(rst),
    .j(rf_er),
    .k(lsr_clr),
    .q(lsr[7])
  );

  assign rf_er = (rf_di[10:8] > 3'b000) ? 1'b1 : 1'b0;

  assign rd_lsr = ((cs == 1'b0) | (wr == 1'b1)) ? 1'b0 :
                  (add != 5) ? 1'b0 : 1'b1;

  gh_edge_det u18 (
    .clk(clk),
    .rst(rst),
    .d(rd_lsr),
    .sfe(lsr_clr)
  );

//--------------------------------------------
//----  registers -------
//--------------------------------------------

  assign csn = (~cs);


  gh_decode_3to8 u19 (
    .a(add),
    .g1(wr),
    .g2n(csn),
    .g3n(1'b0),
    .y(wr_b)
  );

  assign wr_f = wr_b[0] & (~lcr[7]);
  assign wr_ier = wr_b[1] & (~lcr[7]);
  assign wr_d = lcr[7] & (wr_b[0] | wr_b[1]);
  assign wr_dml = {(wr_b[1] & lcr[7]), (wr_b[0] & lcr[7])};

  gh_register_ce #(
    .size(4)
  ) u20 (
    .clk(clk),
    .rst(rst),
    .ce(wr_ier),
    .d(d[3:0]),
    .q(ier)
  );

  gh_register_ce #(
    .size(8)
  ) u21 (
    .clk(clk),
    .rst(rst),
    .ce(wr_b[2]),
    .d(d),
    .q(fcr)
  );

  gh_jkff u22 (
    .clk(clk),
    .rst(rst),
    .j(rf_clrs),
    .k(rf_empty),
    .q(rf_clr)
  );

  assign rf_clrs = d[1] & wr_b[2];

  gh_jkff u23 (
    .clk(clk),
    .rst(rst),
    .j(tf_clrs),
    .k(tf_empty),
    .q(tf_clr)
  );

  assign tf_clrs = d[2] & wr_b[2];

  gh_register_ce #(
    .size(8)
  ) u24 (
    .clk(clk),
    .rst(rst),
    .ce(wr_b[3]),
    .d(d),
    .q(lcr)
  );

  assign num_bits = ((lcr[0] == 1'b0) & (lcr[1] == 1'b0)) ? 5 :
                    ((lcr[0] == 1'b1) & (lcr[1] == 1'b0)) ? 6 :     // 07/12/07
                    ((lcr[0] == 1'b0) & (lcr[1] == 1'b1)) ? 7 : 8;  // 07/12/07

  assign stopb = lcr[2];

  assign parity_en = lcr[3];
  assign parity_od = lcr[3] & (~lcr[4]) & (~lcr[5]);
  assign parity_ev = lcr[3] & lcr[4] & (~lcr[5]);
//assign parity_sticky = lcr[3] & lcr[5];
  assign break_cb = lcr[6];

  gh_register_ce #(
    .size(5)
  ) u25 (
    .clk(clk),
    .rst(rst),
    .ce(wr_b[4]),
    .d(d[4:0]),
    .q(mcr)
  );

  assign dtrn = (~mcr[0]) | iloop;
  assign rtsn = (~mcr[1]) | iloop;
  assign out1n = (~mcr[2]) | iloop;
  assign out2n = (~mcr[3]) | iloop;
  assign iloop = mcr[4];

  gh_register_ce #(
    .size(8)
  ) u26 (
    .clk(clk),
    .rst(rst),
    .ce(wr_b[7]),
    .d(d),
    .q(scr)
  );

//--------------------------------------------------------

  assign d16 = {d, d};

  gh_baud_rate_gen u27 (
    .clk(clk),
    .br_clk(br_clk),
    .rst(rst),
    .wr(wr_d),
    .be(wr_dml),
    .d(d16),
    .rd(rdd),
    .rce(brc16x),
    .rclk(b_clk)
  );

//------------------------------------------------
//-- trans fifo   12/23/06 -----------------------
//------------------------------------------------

  gh_fifo_async16_sr #(
    .data_width(8)
  ) u28 (
    .clk_wr(clk),
    .clk_rd(br_clk),
    .rst(rst),
    .srst(tf_clr),
    .wr(wr_f),
    .rd(tf_rd),
    .d(d),
    .q(tf_do),
    .empty(tf_empty),
    .full(tf_full)
  );

//--------------------------------------------------------------
//--------- added 03/18/06 -------------------------------------
//---------  mod 10/12/07 --------------------------------------

  gh_edge_det u28a (
    .clk(clk),
    .rst(rst),
    .d(isitr1),
    .sre(sitr1)
  );

  assign isitr1 = tf_empty & ier[1];

//-------- end mod 10/12/07 -----------------

  assign rd_iir = (add != 2) ? 1'b0 :
                  (wr == 1'b1) ? 1'b0 :
                  (cs == 1'b0) ? 1'b0 :
                  (iir[3:1] != 3'b001) ? 1'b0 : 1'b1;  // walter hogan 12/12/2006

  gh_edge_det u28b (
    .clk(clk),
    .rst(rst),
    .d(rd_iir),
    .sfe(citr1a)
  );

  assign citr1 = citr1a | (~tf_empty);

  gh_jkff u28c (
    .clk(clk),
    .rst(rst),
    .j(sitr1),
    .k(citr1),
    .q(itr1)
  );

//--------- added 03/18/06 ------------------------------------------
//-------------------------------------------------------------------

  gh_uart_tx_8bit u29 (
    .clk(br_clk),
    .rst(rst),
    .xbrc(brc16x),
    .d_ryn(tf_empty),
    .d(tf_do),
    .num_bits(num_bits),
    .break_cb(break_cb),
    .stopb(stopb),
    .parity_en(parity_en),
    .parity_ev(parity_ev),
    .stx(istx),
    .busyn(tsr_empty),
    .read(tf_rd)
  );

  assign stx = istx;


//------------------------------------------------
//-- receive fifo ----------------------------------
//------------------------------------------------

  gh_edge_det u30 (
    .clk(br_clk),
    .rst(rst),
    .d(rd_rdy),
    .re(rf_wr)
  );

  assign rf_rd = (lcr[7] == 1'b1) ? 1'b0 :  // added 04/19/06
                 ((add == 3'b000) & (cs == 1'b1) & (wr == 1'b0)) ? 1'b1 : 1'b0;

  gh_fifo_async16_rcsr_wf #(  // 01/20/07
    .data_width(11)
  ) u31 (
    .clk_wr(br_clk),
    .clk_rd(clk),
    .rst(rst),
    .rc_srst(rf_clr),
    .wr(rf_wr),
    .rd(rf_rd),
    .d(rf_di),
    .q(rf_do),
    .empty(rf_empty),
    .q_full(q_full),
    .h_full(h_full),
    .a_full(a_full),
    .full(rf_full)
  );

//---------- 10/12/07 --------------------------------------
//--- as suggested  matthias klemm -------------------------
//--- mod 10/13/07 -----------------------------------------

  assign iparity_er = rf_do[8] & (~rf_rd);

  gh_edge_det u32a (
    .clk(clk),
    .rst(rst),
    .d(iparity_er),
    .sre(parity_er)
  );

  assign iframe_er = rf_do[9] & (~rf_rd);

  gh_edge_det u32b (
    .clk(clk),
    .rst(rst),
    .d(iframe_er),
    .sre(frame_er)
  );

  assign ibreak_itr = rf_do[10] & (~rf_rd) & (~rf_empty);  // 07/21/08

  gh_edge_det u32c (
    .clk(clk),
    .rst(rst),
    .d(ibreak_itr),
    .sre(break_itr)
  );

  assign itr3 = (ier[2] == 1'b0) ? 1'b0 :
                (lsr[1] == 1'b1) ? 1'b1 :
                (lsr[4:2] > 3'b000) ? 1'b1 : 1'b0;

//---------------------------------------------------------------------


  assign isrx = (iloop == 1'b0) ? srx : istx;


  assign itr2 = (ier[0] == 1'b0) ? 1'b0 :  // mod 01/20/07
                ((fcr[7:6] == 2'b11) & (a_full == 1'b1)) ? 1'b1 :
                ((fcr[7:6] == 2'b10) & (h_full == 1'b1)) ? 1'b1 :
                ((fcr[7:6] == 2'b01) & (q_full == 1'b1)) ? 1'b1 :
                ((fcr[7:6] == 2'b00) & (rf_empty == 1'b0)) ? 1'b1 : 1'b0;

  gh_uart_rx_8bit u33 (
    .clk(br_clk),
    .rst(rst),
    .brcx16(brc16x),
    .srx(isrx),
    .num_bits(num_bits),
    .parity_en(parity_en),
    .parity_ev(parity_ev),
    .parity_er(rf_di[8]),
    .frame_er(rf_di[9]),
    .break_itr(rf_di[10]),
    .d_rdy(rd_rdy),
    .d(rf_di[7:0])
  );

//--------------------------------------------------------------
//-------- added 04/08/06 time out interrupt -------------------
//-------- once there a received data word is recieved, --------
//-------- the counter will be running until -------------------
//-------- fifo is empty, counter reset on fifo read | write --
//----- mod 3 aug 2007

  assign toi_clr = rf_empty | rf_rd | (~ier[0]);

  gh_jkff u34 (
    .clk(clk),
    .rst(rst),
    .j(toi_set),
    .k(toi_clr),
    .q(toi)
  );

  gh_jkff u35 (
    .clk(clk),
    .rst(rst),
    .j(lsr[0]),    // enable time out counter with received data
    .k(rf_empty),  // once fifo is empty), stop counter
    .q(itoi_enc)
  );

  gh_edge_det_xcd u35a (
    .iclk(clk),
    .oclk(br_clk),
    .rst(rst),
    .d(rf_rd),
    .re(rf_rd_brs),
    .fe(open)
  );

  always_ff @(posedge br_clk or posedge rst) begin
    if (rst == 1'b1) toi_enc <= 1'b0;
    else toi_enc <= itoi_enc;
  end

  assign toi_c_ld = (ier[0] == 1'b0) ? 1'b1 :  // added 4 aug 2007
                    (toi_enc == 1'b0) ? 1'b1 :
                    (rf_rd_brs == 1'b1) ? 1'b1 :
                    (rf_wr == 1'b1) ? 1'b1 : 1'b0;

  gh_counter_down_ce_ld_tc #(
    .size(10)
  ) u36 (
    .clk(br_clk),
    .rst(rst),
    .load(toi_c_ld),
    .ce(brc16x),
    .d(toi_c_d[9:0]),
//  .q(),
    .tc(itoi_set)
  );

  gh_edge_det_xcd u36a (
    .iclk(br_clk),
    .oclk(clk),
    .rst(rst),
    .d(itoi_set),
    .re(toi_set),
    .fe(open)
  );


  assign toi_c_d = (num_bits == 5) ? 12'h1c0 :
                   (num_bits == 6) ? 12'h200 :
                   (num_bits == 7) ? 12'h240 : 280;  // when (num_bits == 8)

//------------------------------------------------------------
//------------------------------------------------------------

  assign irq = ((itr3 | itr2 | toi | itr1 | itr0) == 1'b1) ? 1'b1 : 1'b0;

  assign iiir[0] = ((itr3 | itr2 | toi | itr1 | itr0) == 1'b1) ? 1'b0 : 1'b1;

  assign iiir[3:1] = (itr3 == 1'b1) ? 3'b011 :
                     (itr2 == 1'b1) ? 3'b010 :
                     (toi == 1'b1) ? 3'b110 :  // added 04/08/06
                     (itr1 == 1'b1) ? 3'b001 : 3'b000;

  assign iir[7:4] = 4'hc;  // fifo's always enabled

  gh_register_ce #(  // 12/23/06
    .size(4)
  ) u37 (
    .clk(clk),
    .rst(rst),
    .ce(csn),
    .d(iiir),
    .q(iir[3:0])
  );

//------------------------------------------------------------

endmodule : gh_uart_16550
