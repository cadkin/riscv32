////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_Counter_down_ce_ld_tc.vhd
//
//	Description:
//		Binary up/down counter with load, count enable and TC
//
//	Copyright (c) 2005 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 
//
//	Revision 	History:
//	Revision 	Date       	Author   	Comment
//	//////// 	////////// 	////////-	//////////-
//	1.0      	09/03/05   	S A Dodd	Initial revision
//	2.0     	09/17/05  	h lefevre	name change to avoid conflict
//	        	          	         	  with other libraries
//	2.1     	09/24/05  	S A Dodd 	fix description	
//	2.2      	05/21/06  	S A Dodd 	fix typo's
////////////////////////////////////////////////////////////////////////////-
module gh_counter_down_ce_ld_tc #(
  parameter int size = 8
) (
input logic clk,
input logic rst,
input logic load,
input logic ce,
input logic [size-1:0] d,
output logic [size-1:0] q,
output logic tc
);

logic [size-1:0] iq;
logic itc;

//
// outputs

assign tc = (itc & ce);

assign q = iq;

//--------------------------------
//--------------------------------

always_ff @(posedge clk or posedge rst) begin
  if (rst == 1'b1) itc <= 1'b0;
  else begin
    if (load == 1'b1) begin
      if (d == 4'h0) itc <= 1'b1;
      else itc <= 1'b0;
    end
    else if (ce == 1'b0) begin  // load == 1'b0
      if (iq == 4'h0) itc <= 1'b1;
      else itc <= 1'b0;
    end
    else begin // (ce == 1'b1)
      if (iq == 4'h1) itc <= 1'b1;
      else itc <= 1'b0;
    end
  end
end


always_ff @(posedge clk or posedge rst) begin
  if (rst == 1'b1) iq <= 0;
  else begin
    if (load == 1'b1) iq <= d;
    else if (ce == 1'b1) iq <= (iq - 2'b01);
  end
end
endmodule : gh_counter_down_ce_ld_tc
