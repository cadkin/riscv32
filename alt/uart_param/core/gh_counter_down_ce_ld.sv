////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_counter_down_ce_ld.sv
//
//  Description:
//    Binary up/down counter with load, and count enable
//
//  Copyright (c) 2005 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author     Comment
//  ////////   //////////   ////////-  //////////-
//  1.0        09/24/05     S A Dodd   Initial revision
//  2.0        04/20/22     SenecaUTK  Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_counter_down_ce_ld #(
  parameter int SIZE = 8
) (
  input logic clk,
  input logic rst,
  input logic load,
  input logic ce,
  input logic [SIZE-1:0] d,
  output logic [SIZE-1:0] q
);

  logic [SIZE-1:0] iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 0;
    else begin
      if (load == 1'b1) iq <= d;
      else if (ce == 1'b1) iq <= (iq - 2'b01);
    end
  end
endmodule : gh_counter_down_ce_ld
