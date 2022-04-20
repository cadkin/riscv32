////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_baud_rate_gen.sv
//
//  Description:
//    a 16 bit baud rate generator
//
//  Copyright (c) 2005 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author     Comment
//  ////////   //////////   ////////-  //////////-
//  1.0        01/28/06     H LeFevre  Initial revision
//  2.0        02/04/06     H LeFevre  reload counter with register load
//  2.1        04/10/06     H LeFevre  Fix error in rCLK
//  3.0        04/20/22     SenecaUTK  Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_baud_rate_gen (
  input logic clk,
  input logic br_clk,
  input logic rst,
  input logic wr,
  input logic [1:0] be, // byte enable
  input logic [15:0] d,
  output logic [15:0] rd,
  output logic rce,
  output logic rclk
);

  logic ub_ld;
  logic lb_ld;
  logic [15:0] rate;
  logic c_ld;
  logic c_ce;
  logic irld;  // added 02/04/06
  logic rld;   // added 02/04/06
  logic [15:0] count;

  assign rce = (count == 8'h01) ? 1'b1 : 1'b0;

  always_ff @(posedge br_clk or posedge rst)
  begin
    if (rst == 1'b1) begin
      rclk <= 1'b0;
      rld <= 1'b0;
    end
    else begin
      rld <= irld;
      if (count > {1'b0, rate[15:1]}) rclk <= 1'b1; // fixed 04/10/06
      else rclk <= 1'b0;
    end;
  end

  assign rd = rate;

//--------------------------------------------
//--------------------------------------------

  assign ub_ld = (wr == 1'b0) ? 1'b0 :
                 (be[1] == 1'b0) ? 1'b0 : 1'b1;

  gh_register_ce_8 u1 (
    .clk(clk),
    .rst(rst),
    .ce(ub_ld),
    .d(d[15:8]),
    .q(rate[15:8])
  );

  assign lb_ld = (wr == 1'b0) ? 1'b0 :
                 (be[0] == 1'b0) ? 1'b0 : 1'b1;

  gh_register_ce_8 u2 (
    .clk(clk),
    .rst(rst),
    .ce(lb_ld),
    .d(d[7:0]),
    .q(rate[7:0])
  );

//----------------------------------------------------------
//---------- baud rate counter -----------------------------
//----------------------------------------------------------

  always_ff @(posedge clk or posedge rst)
  begin
    if (rst == 1'b1) irld <= 1'b0;
    else begin
      if ((ub_ld | lb_ld) == 1'b1) irld <= 1'b1;
      else if (rld == 1'b1) irld <= 1'b0;
    end
  end

  assign c_ld = (count == 8'h01) ? 1'b1 :
                (rld == 1'b1) ? 1'b1 : 1'b0;

  assign c_ce = (rate > 8'h01) ? 1'b1 : 1'b0;

  gh_counter_down_ce_ld u3 (
    .clk(br_clk),
    .rst(rst),
    .load(c_ld),
    .ce(c_ce),
    .d(rate),
    .q(count)
  );
endmodule : gh_baud_rate_gen
