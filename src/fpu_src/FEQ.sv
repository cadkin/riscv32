`timescale 1ns / 1ps


module FEQ(
	input logic [31:0] input_a,
	input logic [31:0] input_b,
        output logic [31:0] output_z);
    
     always_comb
     begin
        if(input_a == input_b) begin
            output_z = 1;
        end
        else begin 
            output_z = 0;
        end
     end 
endmodule
