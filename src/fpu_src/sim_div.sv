`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2021 11:45:15 AM
// Design Name: 
// Module Name: sim_div
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


module sim_div(input_a,
               input_b,
               input_a_stb,
               input_b_stb,
               output_z_ack,
               clk,
               rst,
               output_z,
               output_z_stb,
               input_a_ack,
               input_b_ack);
  
  input reg clk;
  input reg    rst;

  input reg  [31:0] input_a;
  input reg    input_a_stb;
  output    input_a_ack;

  input reg  [31:0] input_b;
  input reg    input_b_stb;
  output    input_b_ack;

  output    [31:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       s_output_z_stb;
  reg       [31:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;
  
      always begin
        #3 clk = !clk;  
      end
                
              
      divider div(input_a, input_b, input_a_stb, input_b_stb, output_z_ack, clk, rst,
        output_z, output_z_stb, input_a_ack, input_b_ack);

        
       initial begin
            clk = 0;
            rst = 1;
            
            #9;
            
            rst = 0;
            
            #18
            
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            //set both stable
            
            #10
            input_a_stb = 1;
            input_b_stb = 1;
            
            //wait
            #500;
            
            //check output_z when output stable
            
            
            
            
       
       end; 
     
endmodule
