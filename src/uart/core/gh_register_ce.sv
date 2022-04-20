////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_register_ce.sv
//
//  Description:
//    register with clock enable
//
//  Copyright (c) 2005 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date         Author     Comment
//  ////////   //////////   ////////-  //////////-
//  1.0        09/03/05     G Huber    Initial revision
//  2.0        09/17/05     h lefevre  name change to avoid conflict
//                                      with other librarys
//  3.0        04/20/22     SenecaUTK  Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_register_ce #(
  parameter int SIZE = 8
) (
  input logic clk,
  input logic rst,
  input logic ce, // clock enable
  input logic [SIZE-1:0] d,
  output logic [SIZE-1:0] q
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) q <= 0;
    else begin
      if (ce == 1'b1) q <= d;
    end;
  end;
endmodule : gh_register_ce
