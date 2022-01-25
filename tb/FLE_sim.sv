`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 01:41:31 PM
// Design Name: 
// Module Name: FLE_sim
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


module FLE_sim(
		input reg [31:0] input_a,
		input reg [31:0] input_b,
        output logic [31:0] output_z
    );
        FLE flt1(input_a,input_b,output_z);
      initial begin
            
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
