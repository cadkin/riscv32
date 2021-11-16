`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2021 11:29:23 AM
// Design Name: 
// Module Name: float_to_int_sim
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


module float_to_int_sim(
	   input reg [31:0] input_a,
	   input reg clk,rst,
        output logic [31:0] output_z,
        output logic output_z_stb);
        
      float_to_int f_i(input_a, clk, rst, output_z, output_z_stb);
		
      always begin
        #3 clk = !clk;  
      end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            input_a = 32'h40000000;
            
            
            #3;
            
            rst = 0;
            
            #20;
            
                        #18;
            
            input_a = 32'hc0e00000;
            
            #20;
            
      end;
endmodule
