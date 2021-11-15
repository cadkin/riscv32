`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 07:27:26 PM
// Design Name: 
// Module Name: float_to_uint_sim
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


module float_to_uint_sim(
	   input reg [31:0] input_a,
	   input reg clk,rst,
        output logic [31:0] output_z,
        output logic output_z_stb);
        
      float_to_unsig_int f_i(input_a, clk, rst, output_z, output_z_stb);
		
      always begin
        #3 clk = !clk;  
      end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #3;
            
            input_a = 32'h40000000;
            
            #20;
            
            input_a = 32'hc0e00000;
            
            #20;
            
      end;
endmodule
