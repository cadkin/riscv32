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
module gh_uart_rx_8bit (
  input logic clk,    // clock
  input logic rst,
  input logic brcx16, // 16x clock enable
  input logic srx,
  input int num_bits,
  input logic parity_en,
  input logic parity_ev,
  output logic parity_er,
  output logic frame_er,
  output logic break_itr,
  output logic d_rdy,
  output logic [7:0] d
);

  typedef enum {
    idle,
    r_start_bit,
    shift_data,
    r_parity,
    r_stop_bit,
    break_err
  } r_statetype;

  r_statetype r_state, r_nstate;

  logic parity;
  logic parity_grst;
  logic rwc_ld;
  int r_wcount;
  logic s_data_ld;
  logic chk_par;
  logic chk_frm;
  logic clr_brk;
  logic clr_d;
  logic s_chk_par;
  logic s_chk_frm;
  logic [7:0] r_shift_reg;
  logic irx;
  logic brc;
  logic dclk_ld;
  int r_brdcount;
  logic iparity_er;
  logic iframe_er;
  logic ibreak_itr;
  logic id_rdy;

//--------------------------------------------
//-- outputs----------------------------------
//--------------------------------------------
  always_ff @(posedge clk or posedge rst)
  begin
    if (rst == 1'b1) begin
      parity_er <= 1'b0;
      frame_er <= 1'b0;
      break_itr <= 1'b0;
      d_rdy <= 1'b0;
    end
    else begin
      if (brcx16 == 1'b1) begin
        d_rdy <= id_rdy;
        if (id_rdy == 1'b1) begin
          parity_er <= iparity_er;
          frame_er <= iframe_er;
          break_itr <= ibreak_itr;
        end
      end
    end
  end

  assign d = (num_bits == 8) ? r_shift_reg :
             (num_bits == 7) ? {1'b0, r_shift_reg[7:1]} :
             (num_bits == 6) ? {2'b00, r_shift_reg[7:2]} : {3'b000, r_shift_reg[7:3]}; // when (bits_word == 5) else


//--------------------------------------------

  assign dclk_ld = (r_state == idle) ? 1'b1 : 1'b0;

  assign brc = (brcx16 == 1'b0) ? 1'b0 :
               (r_brdcount == 0) ? 1'b1 : 1'b0;

  gh_counter_integer_down #( // baud rate divider
    .max_count(15)
  ) u1 (
    .clk(clk),
    .rst(rst),
    .load(dclk_ld),
    .ce(brcx16),
    .d(14),
    .q(r_brdcount)
  );

//--------------------------------------------------------

  gh_shift_reg_se_sl #(
    .size(8)
  ) u2 (
    .clk(clk),
    .rst(rst),
    .srst(clr_d),
    .se(s_data_ld),
    .d(srx),
    .q(r_shift_reg)
  );

//---------------------------------------------------------

  assign chk_par = s_chk_par & (((parity ^ irx) & parity_ev)
                   | (((~parity) ^ irx) & (~parity_ev)));

  gh_jkff u2c (
    .clk(clk),
    .rst(rst),
    .j(chk_par),
    .k(dclk_ld),
    .q(iparity_er)
  );

  assign chk_frm = s_chk_frm & (~irx);

  gh_jkff u2d (
    .clk(clk),
    .rst(rst),
    .j(chk_frm),
    .k(dclk_ld),
    .q(iframe_er)
  );

  gh_jkff u2e (
    .clk(clk),
    .rst(rst),
    .j(clr_d),
    .k(clr_brk),
    .q(ibreak_itr)
  );

//------------------------------------------------------------
//------------------------------------------------------------


  always_comb
  begin
    unique case (r_state)
      idle: begin // idle
        id_rdy = 1'b0;
        s_data_ld = 1'b0;
        rwc_ld = 1'b1;
        s_chk_par = 1'b0;
        s_chk_frm = 1'b0;
        clr_brk = 1'b0;
        clr_d = 1'b0;
        if (irx == 1'b0) r_nstate = r_start_bit;
        else r_nstate = idle;
      end
      r_start_bit: begin //
        id_rdy = 1'b0;
        s_data_ld = 1'b0;
        rwc_ld = 1'b1;
        s_chk_par = 1'b0;
        s_chk_frm = 1'b0;
        clr_brk = 1'b0;
        if (brc == 1'b1) begin
          clr_d = 1'b1;
          r_nstate = shift_data;
        end
        else if ((r_brdcount == 8) && (irx == 1'b1)) begin // false start bit detection
          clr_d = 1'b0;
          r_nstate = idle;
        end
        else begin
          clr_d = 1'b0;
          r_nstate = r_start_bit;
        end
      end
      shift_data: begin // send data bit
        id_rdy = 1'b0;
        rwc_ld = 1'b0;
        s_chk_par = 1'b0;
        s_chk_frm = 1'b0;
        clr_d = 1'b0;
        if (brcx16 == 1'b0) begin
          s_data_ld = 1'b0;
          clr_brk = 1'b0;
          r_nstate = shift_data;
        end
        else if (r_brdcount == 8) begin
          s_data_ld = 1'b1;
          clr_brk = irx;
          r_nstate = shift_data;
        end
        else if ((r_wcount == 1) && (r_brdcount == 0) && (parity_en == 1'b1)) begin
          s_data_ld = 1'b0;
          clr_brk = 1'b0;
          r_nstate = r_parity;
        end
        else if ((r_wcount == 1) && (r_brdcount == 0)) begin
          s_data_ld = 1'b0;
          clr_brk = 1'b0;
          r_nstate = r_stop_bit;
        end
        else begin
          s_data_ld = 1'b0;
          clr_brk = 1'b0;
          r_nstate = shift_data;
        end
      end
      r_parity: begin // check parity bit
        id_rdy = 1'b0;
        s_data_ld = 1'b0;
        rwc_ld = 1'b0;
        s_chk_frm = 1'b0;
        clr_d = 1'b0;
        if (brcx16 == 1'b0) begin
          s_chk_par = 1'b0;
          clr_brk = 1'b0;
          r_nstate = r_parity;
        end
        else if (r_brdcount == 8) begin
          s_chk_par = 1'b1;
          clr_brk = irx;
          r_nstate = r_parity;
        end
        else if (brc == 1'b1) begin
          s_chk_par = 1'b0;
          clr_brk = 1'b0;
          r_nstate = r_stop_bit;
        end
        else begin
          s_chk_par = 1'b0;
          clr_brk = 1'b0;
          r_nstate = r_parity;
        end
      end
      r_stop_bit: begin // check stop bit
        s_data_ld = 1'b0;
        rwc_ld = 1'b0;
        s_chk_par = 1'b0;
        clr_brk = irx;
        clr_d = 1'b0;
        if ((brc == 1'b1) && (ibreak_itr == 1'b1)) begin
          id_rdy = 1'b1;
          s_chk_frm = 1'b0;
          r_nstate = break_err;
        end
        else if (brc == 1'b1) begin
          id_rdy = 1'b1;
          s_chk_frm = 1'b0;
          r_nstate =  idle;
        end
        else if (r_brdcount == 8) begin
          id_rdy = 1'b0;
          s_chk_frm = 1'b1;
          r_nstate = r_stop_bit;
        end
        else if ((r_brdcount == 7) && (ibreak_itr == 1'b0)) begin // added 02/20/06
          id_rdy = 1'b1;
          s_chk_frm = 1'b0;
          r_nstate =  idle;
        end
        else begin
          id_rdy = 1'b0;
          s_chk_frm = 1'b0;
          r_nstate = r_stop_bit;
        end
      end
      break_err: begin
        id_rdy = 1'b0;
        s_data_ld = 1'b0;
        rwc_ld = 1'b0;
        s_chk_par = 1'b0;
        s_chk_frm = 1'b0;
        clr_brk = 1'b0;
        clr_d = 1'b0;
        if (irx == 1'b1) r_nstate = idle;
        else r_nstate = break_err;
      end
      default: begin
        id_rdy = 1'b0;
        s_data_ld = 1'b0;
        rwc_ld = 1'b0;
        s_chk_par = 1'b0;
        s_chk_frm = 1'b0;
        clr_brk = 1'b0;
        clr_d = 1'b0;
        r_nstate = idle;
      end
    endcase
  end

  //
  // registers for sm
  always_ff @(posedge clk or posedge rst)
  begin
    if (rst == 1'b1) begin
      irx <= 1'b1;
      r_state <= idle;
    end
    else begin
      if (brcx16 == 1'b1) begin
        irx <= srx;
        r_state <= r_nstate;
      end
      else begin
        irx <= irx;
        r_state <= r_state;
      end
    end
  end

  gh_counter_integer_down #( // word counter
    .max_count(8)
  ) u3 (
    .clk(clk),
    .rst(rst),
    .load(rwc_ld),
    .ce(brc),
    .d(num_bits),
    .q(r_wcount)
  );

//------------------------------------------------------
//------------------------------------------------------

  assign parity_grst = (r_state == r_start_bit) ? 1'b1 : 1'b0;

  gh_parity_gen_serial u4 (
    .clk(clk),
    .rst(rst),
    .srst(parity_grst),
    .sd(brc),
    .d(r_shift_reg[7]),
    .q(parity)
  );
endmodule : gh_uart_rx_8bit
