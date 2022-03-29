//IEEE Floating Point to unsign Integer Converter (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
//modified by Jianjun Xu
//Date 2021-11-11

module float_to_unsig_int(
	input logic [31:0] input_a,
	input logic [2:0] rm,
	input logic clk,rst,
    output logic [31:0] output_z,
    output logic output_z_stb);

  logic   s_output_z_stb;
  logic   [31:0] s_output_z;

  logic       [2:0] state;
  parameter unpack        = 3'd0,
            special_cases = 3'd1,
            convert       = 3'd2,
            put_z         = 3'd3;

  logic [32:0] a_m;
  logic [31:0] z;
  logic [8:0] a_e;
  logic a_s;

  always @(posedge clk)
  begin

    case(state)
      unpack:
      begin
        s_output_z_stb <= 0;
        a_m[32:0] <= {1'b1, input_a[22 : 0],9'h000};
        a_e <= input_a[30 : 23] - 127;
        a_s <= input_a[31];
        if(rst == 0) begin
			state <= special_cases;
		end
      end

      special_cases:
      begin
        if (($signed(a_e) == -127)||(a_s == 1)) begin
          z <= 0;
          state <= put_z;
        end else if ($signed(a_e) > 32) begin
          z <= 32'h80000000;
          state <= put_z;
        end else begin
          state <= convert;
        end
      end

      convert:
      begin
        if ($signed(a_e) < 32 && a_m) begin
          a_e <= a_e + 1;
          a_m <= a_m >> 1;
        end else begin
          if (a_m[32]) begin
            z <= 32'h80000000;
          end else begin
            z <= a_m[31:0];
          end
          state <= put_z;
        end
      end

      put_z:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        state <= unpack;
      end

    endcase

    if (rst == 1) begin
      state <= unpack;
      s_output_z_stb <= 0;
    end

  end
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
