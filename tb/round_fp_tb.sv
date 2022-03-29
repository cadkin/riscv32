`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2022 10:52:38 AM
// Design Name: 
// Module Name: round_fp_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module round_fp_tb(

    );
  reg       [23:0] a_m;
  reg       [9:0] a_e ;
  reg       a_s,guard, round_bit, sticky;
  logic [2:0] rm;
  logic  clk,rst;
  logic     [23:0] round_zm;
  logic     [9:0] round_ze;
  rounding r1(a_m,a_e,a_s,guard,round_bit,sticky,rm, round_zm, round_ze);
  always begin
        #3 clk = !clk;  
      end  
    initial begin
            clk = 0;
            rst = 1;
            rm = 3'b000;
            
            //set input a
            a_m = 24'h001001;
            a_e = 10'h100;
            a_s = 1'b1;
            guard = 1'b1;
            round_bit = 1'b1;
            sticky = 1'b1;
            #10;
            rst = 0;
            //wait
            #20;
            //set input a
            a_m = 24'hffffff;

            sticky = 1'b0;
            //check output_z when output stable
            //wait
            #20;   
            guard = 1'b0;
            round_bit = 1'b1;
            #20;   
            guard = 1'b1;
            round_bit = 1'b0;
            rm = 3'b001;
     end;    
endmodule
