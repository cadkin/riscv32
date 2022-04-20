////////////////////////////////////////////////////////////////////////////-
//	Filename:	gh_edge_det_XCD.vhd
//
//	Description:
//		an edge detector, for crossing clock domains - 
//		   finds the rising edge and falling edge for a pulse crossing clock domains
//
//	Copyright (c) 2006, 2008 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions  
//
//	Revision 	History:
//	Revision 	Date       	Author    	Comment
//	//////// 	//////////	////////	//////////-
//	1.0        	09/16/06  	S A Dodd 	Initial revision
//	2.0     	04/12/08  	hlefevre	mod to double register between clocks
//	        	          	        	   output time remains the same
//
////////////////////////////////////////////////////////////////////////////-
module gh_edge_det_xcd (
  input logic iclk,  // clock for input data signal
  input logic oclk,  // clock for output data pulse
  input logic rst,
  input logic d,
  output logic re,   // rising edge
  output logic fe   // falling edge
);

  logic iq;
  logic jkr;
  logic jkf;
  logic irq0;
  logic rq0;
  logic rq1;
  logic ifq0;
  logic fq0;
  logic fq1;

  always_ff @(posedge iclk or posedge rst) begin
    if (rst == 1'b1) begin
      iq <= 1'b0;
      jkr <= 1'b0;
      jkf <= 1'b0;
    end
    else begin
      iq <= d;
      if ((d == 1'b1) && (iq == 1'b0)) jkr <= 1'b1;
      else if (rq1 == 1'b1) jkr <= 1'b0;
      else jkr <= jkr;
      if ((d == 1'b0) && (iq == 1'b1)) jkf <= 1'b1;
      else if (fq1 == 1'b1) jkf <= 1'b0;
      else jkf <= jkf;
    end
  end

  assign re = (~rq1) & rq0;
  assign fe = (~fq1) & fq0;

  always_ff @(posedge oclk or posedge rst) begin
    if (rst == 1'b1) begin
      irq0 <= 1'b0;
      rq0 <= 1'b0;
      rq1 <= 1'b0;
      //-------------
      ifq0 <= 1'b0;
      fq0 <= 1'b0;
      fq1 <= 1'b0;
    end
    else begin
      irq0 <= jkr;
      rq0 <= irq0;
      rq1 <= rq0;
      //-------------
      ifq0 <= jkf;
      fq0 <= ifq0;
      fq1 <= fq0;
    end
  end
endmodule : gh_edge_det_xcd
