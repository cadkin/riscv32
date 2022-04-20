////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_shift_reg_se_sl.vhd
//
//	Description:
//		a shift register with async reset and count enable
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
module gh_shift_reg_se_sl #(
  parameter int size = 16
) (
  input logic clk,
  input logic rst,
  input logic srst,
  input logic se, // shift enable
  input logic d,
  output logic [size-1:0] q
);

  logic [size-1:0] iq;

  assign q = iq;

  always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) iq <= 0;
    else begin
      if (srst == 1'b1) iq <= 0;
      else if (se == 1'b1) begin
        iq[size-1] <= d;
        iq[size-2:0] <= iq[size-1:1];
      end
    end
  end
endmodule : gh_shift_reg_se_sl
