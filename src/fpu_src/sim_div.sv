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


module sim_div(  input reg  [31:0] input_a,input_b,
  input reg  clk,rst,
  output logic [31:0] output_z,
  output logic output_z_stb);
  
  


      always begin
        #3 clk = !clk;  
      end
                
              
      divider div(input_a,input_b, clk, rst, output_z, output_z_stb);

        
       initial begin
            clk = 0;
            rst = 1;
            
            #9;
            //4.4/2.2
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            //set both stable
           #18
            rst = 0;
            //wait
            #100;

            
            //check output_z when output stable
            
            
            
            
       
       end; 
     
endmodule
