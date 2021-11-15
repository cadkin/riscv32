`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 05:51:26 PM
// Design Name: 
// Module Name: sign_inj_sim
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


module sign_inj_sim(
	input reg  [31:0] input_a,input_b,
	input reg  [1:0] sel,
    output logic [31:0] output_z

    );
    fsign_inject sj(input_a, input_b, sel, output_z);
    initial begin
            #10
            sel = 0;
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'hc0000000;
            //set both stable
            
            //wait
            #20;
            sel = 1;
            //3.5*-3
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'hc0000000;
            //set both stable
            //wait
            #20;
            sel = 2;
            //3.5*-3
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'hc0000000;
            //set both stable
            //wait
    end
endmodule
