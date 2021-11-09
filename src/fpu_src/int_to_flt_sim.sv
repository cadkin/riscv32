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
        input reg clk,
        input reg rst,
		input reg input_a_stb,output_z_ack,
		input reg [31:0] input_a,
		output logic input_a_ack,output_z_stb,
        output logic [31:0] output_z );
        
        
        logic [31:0] a, z, value;
		logic [7:0]  z_r,z_e;
		logic [23:0] z_m;
		logic sign,guard, round_bit, sticky;
		
		int_to_float i_f(clk, rst,input_a_stb, output_z_ack, input_a, input_a_ack, output_z_stb, output_z);
		
      always begin
        #3 clk = !clk;  
      end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #18;
            
            input_a = 32'h00000002;
            input_a_stb = 1;
            
            #100;
            
      end;
      
endmodule
