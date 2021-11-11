`timescale 1ns / 1ps


module FEQ(
        input logic clk,
        input logic rst,
		input logic [31:0] input_a,
		input logic [31:0] input_b,
		output logic output_z_stb,
        output logic [31:0] output_z

    );
    
     always @(posedge clk)
     begin
  
        if(input_a == input_b) begin
            output_z = 1;
            output_z_stb = 1;
        end
        else begin 
            output_z = 0;
            output_z_stb = 1;
        
        end
        
     end 
    
    
endmodule
