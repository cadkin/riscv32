//IEEE Floating Point Divider (Double Precision)
//Copyright (C) Jonathan P Dawson 2014
//all combinational logic int to float

module int_to_float(
        input logic clk,
        input logic rst,
		input logic input_a_stb,output_z_ack,
		input logic [31:0] input_a,
		output logic input_a_ack,input_a_ack,
        output logic [31:0] output_z );
		
		logic [31:0] a, z, value,;
		logic [7:0]  z_r,z_e;
		logic [23:0] z_m;
		logic sign,guard, round_bit, sticky;;
	logic       [2:0] state;
	parameter 
	    get_a         = 3'h0,
        convert_0     = 3'h1,
        convert_1     = 3'h2,
        convert_2     = 3'h3,
        round         = 3'h4,
        pack          = 3'h5,
        put_z         = 3'h6;
		
	//assign sign = input_a[31];
	always @(posedge clk)
	begin
	case(state)
      get_a:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a <= input_a;
		  s_output_z_stb <= 0;
          s_input_a_ack <= 0;
          state <= convert_0;
        end
      end

      convert_0:
      begin
        if ( a == 0 ) begin
          z_s <= 0;
          z_m <= 0;
          z_e <= -127;
          state <= pack;
        end else begin
          value <= a[31] ? -a : a;
          z_s <= a[31];
          state <= convert_1;
        end
      end

      convert_1:
      begin
        z_e <= 31;
        z_m <= value[31:8];
        z_r <= value[7:0];
        state <= convert_2;
      end

      convert_2:
      begin
        if (!z_m[23]) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= z_r[7];
          z_r <= z_r << 1;
        end else begin
          guard <= z_r[7];
          round_bit <= z_r[6];
          sticky <= z_r[5:0] != 0;
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
        z[31] <= z_s;
        state <= put_z;
      end

      put_z:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        state <= get_a;
      end

    endcase

    if (rst == 1) begin
      state <= get_a;
      s_input_a_ack <= 0;
      s_output_z_stb <= 0;
    end

  end
  assign input_a_ack = s_input_a_ack;
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule