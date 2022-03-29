`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 05:51:26 PM
// Design Name: 
// Module Name: sqrt_sim
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


module fsqrt_sim();
  logic  [31:0] input_a;
  logic [2:0] rm;
  logic  clk,rst;
  logic [31:0] output_z,z;
  logic output_z_stb;  
  logic[25:0] q,ac,x;
  logic[23:0] z_m,a_m,round_zm;
  logic[9:0] z_e,a_e,round_ze;
  logic [4:0] state;
  reg       guard, round_bit, sticky;
  fsqrt f1(input_a, rm,clk, rst, output_z, output_z_stb);
  assign q = f1.q;
  assign ac = f1.ac;
  assign x = f1.x; 
  assign z_m = f1.z_m;
  assign z_e = f1.z_e;
  assign z = f1.z;
  assign guard = f1.guard;
  assign round_bit = f1.round_bit;
  assign sticky = f1.sticky;
  assign a_m = f1.a_m;
  assign a_e = f1.a_e;
  assign state = f1.state;
  assign round_zm = f1.round_zm;
  assign round_ze = f1.round_ze;
  
  always begin
        #3 clk = !clk;  
      end
        
        
       initial begin
            clk = 0;
            rst = 1;
            rm = 3'b000;
            //set input a
            input_a = 32'h40000000;
            #18;
            rst = 0;
            //wait
            #300;
            //set input a
            input_a = 32'h400ccccd;
            //check output_z when output stable
            //wait
            #300;           
                                  
            //3.5*-3
            //set input a
            input_a = 32'h40600000;
	    //wait
            #200;
            input_a = 32'h3f800000;
            #200;
            input_a = 32'h40800000;
            //set both stable
            //wait
            #200;
            input_a = 32'h42b20000;
            //wait
            #200;
       end; 
     
endmodule
