////////////////////////////////////////////////////////////////////////////-
//  Filename:  gh_edge_det.sv
//
//  Description:
//    an edge detector -
//       finds the rising edge and falling edge
//
//  Copyright (c) 2005 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision   History:
//  Revision   Date        Author    Comment
//  ////////   //////////  ////////  //////////-
//  1.0        09/10/05    G Huber   Initial revision
//  2.0        09/17/05    h lefevre name change to avoid conflict
//                                    with other libraries
//  2.1        05/21/06    S A Dodd  fix typo's
//  3.0        04/20/22    SenecaUTK Convert to SystemVerilog
//
////////////////////////////////////////////////////////////////////////////-
module gh_edge_det (
  input logic clk,
  input logic rst,
  input logic d,
  output logic re,  // rising edge (need sync source at d)
  output logic fe,  // falling edge (need sync source at d)
  output logic sre, // sync'd rising edge
  output logic sfe  // sync'd falling edge
);

  logic q0, q1;

  assign re = d & (~q0);
  assign fe = (~d) & q0;
  assign sre = q0 & (~q1);
  assign sfe = (~q0) & q1;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
      q0 <= 1'b0;
      q1 <= 1'b0;
    end
    else begin
      q0 <= d;
      q1 <= q0;
    end;
  end;
endmodule : gh_edge_det
