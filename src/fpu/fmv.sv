`timescale 1ns / 1ps

//IEEE RISC-V Floating Point Move(Single Precision)
//By Jianjun Xu
//2021-11-11

module fmove(
	input logic  [31:0] input_a,
	input logic  [1:0] sel,
        output logic [31:0] output_z);

always_comb
begin
   case(sel)
	1'b0:output_z[31:0] = input_a[31:0];
	1'b1:output_z[31:0] = input_a[31:0];
  endcase;
end

endmodule
