//IEEE RISC-V Floating Point sign injuction (Single Precision)
//By Jianjun Xu
//2021-11-11

module fmove(
	input logic  [31:0] input_a,
	input logic  [1:0] sel,
        output logic [31:0] output_z);

always_comb
begin
   case(sel)
	0'b0:output_z[31:0] = input_a[31:0];
	0'b1:output_z[31:0] = input_a[31:0];
  endcase;
end

endmodule
