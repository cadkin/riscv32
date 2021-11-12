// unsign Integer to IEEE Floating Point Converter (Single Precision)
//Copyright (C) Jonathan P Dawson 2014
//all combinational logic int to float
//modified by Jianjun Xu
//Date 2021-11-11
module unsig_int_to_float(
        input logic [31:0] input_a,
	input logic clk,rst,
	output logic [31:0] output_z,
	output logic output_z_stb);
		
	logic [31:0] z; 
	logic [32:0] value;
	logic [7:0]  z_r,z_e;
	logic [23:0] z_m;
	logic sign,guard, round_bit, sticky;
	logic [2:0] state;
	parameter 
        convert_1     = 3'h2,
        convert_2     = 3'h3,
        round         = 3'h4,
        pack          = 3'h5,
        put_z         = 3'h6;
		
	//assign sign = input_a[31];
	always @(posedge clk)
	begin
	case(state)
      convert_1:
      begin
        if ( input_a == 0 ) begin
          z_m <= 0;
          z_e <= -127;
	if(rst == 0) begin
	   state <= pack;
	end
        end else begin
          z_e <= 31;
          value <= {'b1,input_a[31:0]};
	if(rst == 0) begin
	    state <= convert_2;
	end
        end
      end

      convert_2:
      begin
        if (!value[32]) begin
          z_e <= z_e - 1;
          value <= value << 1;
        end else begin
	  z_m <= value[31:8];
          guard <= value[7];
          round_bit <= value[6];
          sticky <= value[5:0] != 0;
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit || sticky || z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 24'hffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end

      pack:
      begin
        z[22 : 0] <= z_m[22:0];
        z[30 : 23] <= z_e + 127;
        z[31] <= 0;
        state <= put_z;
      end

      put_z:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        state <= convert_1;
      end

    endcase

    if (rst == 1) begin
      s_output_z_stb <= 0;
	state <= convert_1;
    end

  end
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
