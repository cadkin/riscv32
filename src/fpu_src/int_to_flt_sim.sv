`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2021 01:48:45 PM
// Design Name: 
// Module Name: int_to_flt_sim
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


module int_to_flt_sim(
        input reg [31:0] input_a,
	   input reg clk,rst,
	   output logic [31:0] output_z,
	   output logic output_z_stb);
        
      int_to_float i_f(input_a, clk, rst, output_z, output_z_stb);
		
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
            
            input_a = 32'hfffffff9;
            #30;
            
      end;
      
endmodule
