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


module mul_sim();
  logic  [31:0] input_a;
  logic [2:0] rm;
  logic  clk,rst;
  logic [31:0] output_z;
  logic output_z_stb;  
  always begin
        #3 clk = !clk;  
      end
                
      float_sqrt fsqrt(input_a, rm,clk, rst, output_z, output_z_stb);
        
       initial begin
            clk = 0;
            rst = 1;
            #9;
            rst = 0;
            
            #18
            
            //set input a
            input_a = 32'h408ccccd;
            //wait
            #200;
            //set input a
            input_a = 32'h400ccccd;
            //check output_z when output stable
            //wait
            #200;           
                                  
            //3.5*-3
            //set input a
            input_a = 32'h40600000;
	    //wait
            #200;
            input_a = 32'hc0000000;
            //set both stable
            //wait
            #200;
       end; 
     
endmodule
