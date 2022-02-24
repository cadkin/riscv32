`timescale 1ns / 1ps

//IEEE RISC-V Floating Point sign injuction (Single Precision)
//By Jianjun Xu
//2021-11-11

module fsign_inject(
	input logic  [31:0] input_a,input_b,
	input logic  [1:0] sel,
        output logic [31:0] output_z);

always_comb
begin
   case(sel)
     2'd0 : output_z[31] = input_b[31];
     2'd1 : output_z[31] = ~input_b[31];
     3'd2 : output_z[31] = input_a[31] ^ input_b[31];
     default : output_z[31] = input_a[31];
   endcase;
end
   assign output_z[30:0] = input_a[30:0];
endmodule
