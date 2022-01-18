`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 01:17:51 PM
// Design Name: 
// Module Name: FLT
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


module FLE(
		input logic [31:0] input_a,
		input logic [31:0] input_b,
        output logic [31:0] output_z
    );
    reg       [23:0] a_m, b_m, z_m;
    reg       [9:0] a_e, b_e, z_e;
    reg       a_s, b_s, z_s;
    
    assign  a_m = {1'b1, input_a[22 : 0]};
    assign  b_m = {1'b1, input_b[22 : 0]};
    assign  a_e = input_a[30 : 23] - 127;
    assign  b_e = input_b[30 : 23] - 127;
    assign  a_s = input_a[31];
    assign  b_s = input_b[31];
    
         always_comb
         begin
            //check if equal
            if(input_a == input_b) begin
                output_z = 1;
            end
            //negative vs positive cmp
            else if(a_s == 1 && b_s == 0 ) begin
                output_z = 1;
            end
            else if(b_s == 1 && a_s == 0 )  begin 
                output_z = 0;
            
            end
            //check exp
            else if(a_e < b_e) begin
                if(a_s == 0) begin
                    output_z = 1;
                end else begin
                    output_z = 0;
                end
            end
            else if(a_e > b_e) begin
                if(a_s == 0) begin
                    output_z = 0;
                end else begin
                    output_z = 1;
                end
            end
            //check m
            else if(a_m < b_m) begin
                if(a_s == 0) begin
                    output_z = 1;
                end else begin
                    output_z = 0;
                end
            end
            else if(a_m > b_m) begin
                if(a_s == 0) begin
                    output_z = 0;
                end else begin
                    output_z = 1;
                end;
            end
            else begin
                output_z = 0;
            end
        end
        
endmodule
