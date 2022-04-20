////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_uart_tx_8bit.sv
//
//  Description:
//    an 8 bit UART Tx Module
//
//  Copyright (c) 2006, 2007 by H LeFevre
//    A SystemVerilog 16550 UART core
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author     Comment
//  ////////   //////////   ////////-  //////////-
//  1.0        02/18/06     H LeFevre  Initial revision
//  1.1        02/25/06     H LeFevre  add BUSYn output
//  2.0        06/18/07     P.Azkarate Define "range" in T_WCOUNT and x_dCOUNT signals
//  2.1        07/12/07     H LeFevre  fix a problem with 5 bit data and 1.5 stop bits
//                                     as pointed out by Matthias Klemm
//  2.2        08/17/07     H LeFevre  add stopB to sensitivity list line 164
//                                     as suggested by Guillaume Zin
//  3.0        04/20/22     SenecaUTK  Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_uart_tx_8bit (
  input logic clk, //  clock
  input logic rst,
  input logic xbrc, // x clock enable
  input logic d_ryn, // data ready
  input logic [7:0] d,
  input int num_bits, // number of bits in transfer
  input logic break_cb,
  input logic stopb,
  input logic parity_en,
  input logic parity_ev,
  output logic stx,
  output logic busyn,
  output logic read // data read
);

  typedef enum {
    idle,
    s_start_bit,
    shift_data,
    s_parity,
    s_stop_bit,
    s_stop_bit2
  } t_state_e;

  t_state_e t_state, t_nstate;

  logic parity;
  logic parity_grst;
  logic twc_ld;
  logic twc_ce;
  int t_wcount;
  int d_ld_v;
  logic d_ld;
  logic trans_sr_se;
  logic [7:0] trans_shift_reg;
  logic itx;
  logic brc;
  logic dclk_ld;
  int x_dcount;

//--------------------------------------------
//-- outputs----------------------------------
//--------------------------------------------

  assign busyn = (t_state == idle) ? 1'b1 : 1'b0;

  assign read = d_ld; // read a data word

//--------------------------------------------

  assign dclk_ld = ((num_bits == 5) && (stopb == 1'b1)
                   && (t_state == s_stop_bit2) && (x_dcount == 7)) ? 1'b1 :
                   (d_ryn == 1'b0) ? 1'b0 :
                   (t_state != idle) ? 1'b0 : 1'b1;

  assign d_ld_v = (t_state == s_stop_bit2) ? 15 : 1;

  assign brc = (xbrc == 1'b0) ? 1'b0 :
               (x_dcount == 0) ? 1'b1 : 1'b0;


  gh_counter_integer_down #( // baud rate divider
    .MAX_COUNT(15)
  ) u1 (
    .clk(clk),
    .rst(rst),
    .load(dclk_ld),
    .ce(xbrc),
    .d(d_ld_v),
    .q(x_dcount)
  );

  gh_shift_reg_pl_sl #(
    .SIZE(8)
  ) u2 (
    .clk(clk),
    .rst(rst),
    .load(d_ld),
    .se(trans_sr_se),
    .d(d),
    .q(trans_shift_reg)
  );

//------------------------------------------------------------
//------------------------------------------------------------

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) stx <= 1'b1;
    else stx <= itx & (~break_cb);
  end

  assign itx = (t_state == s_start_bit) ? 1'b0 : // send start bit
               (t_state == shift_data) ? trans_shift_reg[0] : // send data
               ((parity_ev == 1'b1) && (t_state == s_parity)) ? parity :
               (t_state == s_parity) ? (~parity) : 1'b1; // idle, stop bit

  always_comb
  begin
    unique case (t_state)
      idle: begin // idle
        twc_ce = 1'b0;
        if ((d_ryn == 1'b0) && (brc == 1'b1)) begin
          d_ld = 1'b1;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_start_bit;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = idle;
        end
      end
      s_start_bit: begin // fifo is read, send start bit
        twc_ce = 1'b0;
        if (brc == 1'b1) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b1;
          t_nstate = shift_data;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_start_bit;
        end
      end
      shift_data: begin // send data bit
        if (brc == 1'b0) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          twc_ce = 1'b0;
          t_nstate = shift_data;
        end
        else if ((t_wcount == 1) && (parity_en == 1'b1)) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          twc_ce = 1'b1;
          t_nstate = s_parity;
        end
        else if (t_wcount == 1) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          twc_ce = 1'b1;
          t_nstate = s_stop_bit;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b1;
          twc_ld = 1'b0;
          twc_ce = 1'b1;
          t_nstate = shift_data;
        end
      end
      s_parity: begin // send parity bit
        twc_ce = 1'b0;
        if (brc == 1'b1) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_stop_bit;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_parity;
        end
      end
      s_stop_bit: begin // send stop bit
        twc_ce = 1'b0;
        if (brc == 1'b0) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_stop_bit;
        end
        else if (stopb == 1'b1) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_stop_bit2;
        end
        else if (d_ryn == 1'b0) begin
          d_ld = 1'b1;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_start_bit;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = idle;
        end
      end
      s_stop_bit2: begin // send stop bit
        twc_ce = 1'b0;
        if ((d_ryn == 1'b0) && (brc == 1'b1)) begin
          d_ld = 1'b1;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_start_bit;
        end
        else if (brc == 1'b1) begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = idle;
        end
        else if ((num_bits == 5) && (x_dcount == 7) && (d_ryn == 1'b0)) begin
          d_ld = 1'b1;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_start_bit;
        end
        else if ((num_bits == 5) && (x_dcount == 7)) begin
          d_ld = 1'b1;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = idle;
        end
        else begin
          d_ld = 1'b0;
          trans_sr_se = 1'b0;
          twc_ld = 1'b0;
          t_nstate = s_stop_bit2;
        end
      end
      default: begin
        d_ld = 1'b0;
        trans_sr_se = 1'b0;
        twc_ld = 1'b0;
        twc_ce = 1'b0;
        t_nstate = idle;
      end
    endcase
  end

  // registers for sm
  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) t_state <= idle;
    else t_state <= t_nstate;
  end

  gh_counter_integer_down #( // word counter
    .MAX_COUNT(8)
  ) u3 (
    .clk(clk),
    .rst(rst),
    .load(twc_ld),
    .ce(twc_ce),
    .d(num_bits),
    .q(t_wcount)
  );

//------------------------------------------------------
//------------------------------------------------------

  assign parity_grst = (t_state == s_start_bit) ? 1'b1 : 1'b0;

  gh_parity_gen_serial u4 (
    .clk(clk),
    .rst(rst),
    .srst(parity_grst),
    .sd(brc),
    .d(trans_shift_reg[0]),
    .q(parity)
  );
endmodule : gh_uart_tx_8bit
