`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 01:42:54 PM
// Design Name: 
// Module Name: FLT_sim
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


module FLT_sim(
        input reg clk,
        input reg rst,
		input reg [31:0] input_a,
		input reg [31:0] input_b,
		output logic output_z_stb,
        output logic [31:0] output_z
    );
        FLT flt1(clk, rst,input_a,input_b,output_z_stb, output_z);
        always begin
            #3 clk = !clk;  
        end
		
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #18;
            
            input_b = 32'h40000000;
            input_a = 32'h40a9999a;
            
            #10;
            
            input_a = 32'h40000000;
            input_b = 32'h40a9999a;
            
            #10;
            
            input_a = 32'h40000000;
            input_b = 32'h40200000;
            #15;
                        
            input_a = 32'h40000000;
            input_b = 32'h40000000;
            #15;
      end;
endmodule
