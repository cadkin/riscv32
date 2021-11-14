`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 05:51:26 PM
// Design Name: 
// Module Name: mul_sim
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


module mul_sim(
  input reg  [31:0] input_a,input_b,
  input reg  input_a_stb,input_b_stb,output_z_ack,
  input reg  clk,rst,
  output logic [31:0] output_z,
  output logic output_z_stb,input_a_ack,input_b_ack

    );
         always begin
        #3 clk = !clk;  
      end
                
              
      multiplier mul(input_a, input_b, input_a_stb, input_b_stb, output_z_ack, clk, rst, output_z, output_z_stb, input_a_ack, input_b_ack);

        
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
           input_a_stb =1;
           input_b_stb =1;
            
            //wait
            #500;
            
            //check output_z when output stable
                        
                                  
            //3.5*-3
            //set input a
            input_a = 32'h40600000;
            //set input b
            input_b = 32'hc0000000;
            //set both stable
           
            
            //wait
            #100;
            
            
            
       
       end; 
     
endmodule
