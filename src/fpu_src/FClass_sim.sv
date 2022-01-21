`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 05:51:26 PM
// Design Name: 
// Module Name: FClass_sim
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


module FClass_sim(
		input reg [31:0] input_a,
        output logic [31:0] output_z
    );
    
    FClass fc(input_a, output_z);
    initial begin
        #20;
        //+infinity;
        input_a = 32'b01111111100000000000000000000000;
        #20;
        //-infinity
        input_a = 32'b11111111100000000000000000000000;
        #20;
        //+0
        input_a = 32'b00000000000000000000000000000000;
        #20;
        //-0
        input_a = 32'b10000000000000000000000000000000;
        #20;
        //QNAN
        input_a = 32'b01111111110000000000000000000000;
        #20;
        //SNAN
        input_a = 32'b01111111101000000000000000000000;
        #20;
        
        //+normal
        input_a = 32'h408ccccd;
        #20;
        
        //-normal
        input_a = 32'hc08ccccd;
        #20;
        
        //+sub
        input_a = 32'h0000000d;
        #20;
        
        //-sub
        input_a = 32'h8000000d;
        #20;
        
        
        
    end
    
endmodule
