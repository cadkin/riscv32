////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_shift_reg_PL_sl.vhd
//
//	Description:
//		a shift register with Parallel Load	
//		   will shift left (MSB to LSB)
//
//	Copyright (c) 2006 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	////////// 	////////	//////////-
//	1.0      	02/11/06  	G Huber 	Initial revision
//
////////////////////////////////////////////////////////////////////////////-
module gh_shift_reg_pl_sl #(
  parameter int size = 16
) (
  input logic clk,
  input logic rst,
  input logic load, // load data
  input logic se,   // shift enable
  input logic [size-1:0] d,
  output logic [size-1:0] q
);

  logic [size-1:0] iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 0;
    else begin
      if (load == 1'b1) iq <= d;
      else if (se == 1'b1) iq[size-1:0] <= {1'b0, iq[size-1:1]};
      else iq <= iq;
    end
  end
endmodule : gh_shift_reg_pl_sl
