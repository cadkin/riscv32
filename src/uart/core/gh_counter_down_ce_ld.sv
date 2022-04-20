////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_Counter_down_ce_ld.vhd
//
//	Description:
//		Binary up/down counter with load, and count enable
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author   	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	09/24/05  	S A Dodd	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
module gh_counter_down_ce_ld #(
  parameter int size = 8
) (
  input logic clk,
  input logic rst,
  input logic load,
  input logic ce,
  input logic [size-1:0] d,
  output logic [size-1:0] q
);

  logic [size-1:0] iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 0;
    else begin
      if (load == 1'b1) iq <= d;
      else if (ce == 1'b1) iq <= (iq - 2'b01);
    end
  end
endmodule : gh_counter_down_ce_ld
