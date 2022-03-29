`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 05:51:26 PM
// Design Name: 
// Module Name: uint_to_float_sim
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


module uint_to_float_sim(
        input reg [31:0] input_a,
	   input reg clk,rst,
	   output logic [31:0] output_z,
	   output logic output_z_stb);
        
      unsig_int_to_float i_f(input_a, clk, rst, output_z, output_z_stb);
		
      always begin
        #3 clk = !clk;  
      end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            input_a = 32'h00000002;
            #3;
            
            rst = 0;

            #30;
            
            input_a = 32'hfff00000;
            #30;
            
      end;
     
endmodule
