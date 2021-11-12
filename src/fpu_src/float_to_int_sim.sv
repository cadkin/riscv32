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
        input reg clk,
        input reg rst,
		input reg input_a_stb,output_z_ack,
		input reg [31:0] input_a,
		output logic input_a_ack,output_z_stb,
        output logic [31:0] output_z 

    );
    		float_to_int f_i(clk, rst,input_a_stb, output_z_ack, input_a, input_a_ack, output_z_stb, output_z);
		
      always begin
        #3 clk = !clk;  
      end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #18;
            
            input_a = 32'h40000000;
            input_a_stb = 1;
            
            #100;
            
      end;
endmodule
