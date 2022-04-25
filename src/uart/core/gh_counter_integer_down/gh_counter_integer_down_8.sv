////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_counter_integer_down.sv
//
//  Description:
//    an integer down counter
//
//  Copyright (c) 2005 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author    Comment
//  ////////   //////////   ////////  //////////-
//  1.0        10/15/05     G Huber   Initial revision
//  2.0        04/20/22     SenecaUTK Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_counter_integer_down_8 (
    input logic clk,
    input logic rst,
    input logic load, // load d
    input logic ce, // count enable
    input int d,
    output int q
);

  int iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 0;
    else begin
      if (load == 1'b1) iq <= d;
      else if (ce == 1'b1) begin
        if (iq == 0) iq <= 8;
        else iq <= iq - 1;
      end
    end
  end
endmodule : gh_counter_integer_down_8
