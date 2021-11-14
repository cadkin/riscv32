`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 09:34:10 PM
// Design Name: 
// Module Name: adder_sim
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


module adder_sim(
  input reg [31:0] input_a,input_b,
  input reg clk,rst,
  output logic [31:0]output_z,
  output logic output_z_stb

    );
    
      adder inst(input_a, input_b, clk, rst, output_z, output_z_stb);
      
      always begin
        #3 clk = !clk;  
      end
      
      initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #18;
            
            //Addition Testing
            //2 + 1.5
            input_a = 32'h40000000;
            input_b = 32'h3fc00000;
            #100;
            
            //7.46 + 1.5
            input_a = 32'h40eeb852;
            input_b = 32'h3fc00000;
            #100;
            
            //2 + 3.25
            input_a = 32'h40000000;
            input_b = 32'h40500000;
            #100;
            
            //Modified adder for subtraction
            
            //2 - 1.5
            input_a = 32'h40000000;
            input_b = 32'hbfc00000;
            #100;
            
            //7.46 - 1.5
            input_a = 32'h40eeb852;
            input_b = 32'hbfc00000;
            #100;
            
            //2-3.25
            input_a = 32'h40000000;
            input_b = 32'hc0500000;
            #100;
      
      end
    
endmodule
