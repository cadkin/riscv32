`timescale 1ns / 1ps

//IEEE Floating Point Multiple adder (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
//modified by Jianjun Xu
//2021-11-18

module mul_adder(
  input logic  [31:0] input_a,input_b,input_c,
  input logic  [1:0] sel, //select between mul_add mul_sub neg_mul_add neg_mul_sub
  input logic  clk,rst,
  output logic [31:0] output_z,
  output logic output_z_stb);

  reg       s_output_z_stb;
  reg       [31:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [3:0] state;
  parameter unpack        = 4'd1,
            special_cases = 4'd2,
            normalise     = 4'd3,
            multiply_0    = 4'd4,
            align    	  = 4'd5,
            add_0   	  = 4'd6,
	        normalise_1   = 4'd7,
            normalise_2   = 4'd8,
            round         = 4'd9,
            pack          = 4'd10,
            put_z         = 4'd11;

  reg       [31:0] a, b, c, z;
  reg       [23:0] a_m, b_m,z_m;
  reg       [9:0] a_e, b_e, c_e,t_e, z_e;
  reg       a_s, b_s,c_s,t_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [47:0] t_m,c_m;
  reg       [48:0] sum;

  always @(posedge clk)
  begin

    case(state)
      unpack:
      begin
        s_output_z_stb <= 0;
        a_m <= input_a[22 : 0];
        b_m <= input_b[22 : 0];
	c_m <= {24'h000000,input_c[22 : 0]};
        a_e <= input_a[30 : 23] - 127;
        b_e <= input_b[30 : 23] - 127;
	c_e <= input_c[30 : 23] - 127;
        a_s <= input_a[31];
        b_s <= input_b[31];
	c_s <= input_c[31]^ sel[0];//change add into a sub using sel bit 0
        if(rst == 0) begin
	    state <= special_cases;
	end
      end

      special_cases:
      begin
        //if a is NaN or b or c is NaN return NaN 
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)||(c_e == 128 && c_m != 0)) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          z[21:0] <= 0;
          state <= put_z;
        //if a is inf return inf
        end else if (a_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          //if b is zero return NaN
          if (($signed(b_e) == -127) && (b_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
          
	//if c is inf and signs don't match return nan
          end else if ((c_e == 128) && (a_s != c_s)) begin
              z[31] <= c_s;
              z[30:23] <= 255;
              z[22] <= 1;
              z[21:0] <= 0;
          end
          state <= put_z;
        //if b is inf return inf
        end else if (b_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          //if a is zero return NaN
          if (($signed(a_e) == -127) && (a_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
          //if c is inf and signs don't match return nan
          end else if ((c_e == 128) && (b_s != c_s)) begin
              z[31] <= c_s;
              z[30:23] <= 255;
              z[22] <= 1;
              z[21:0] <= 0;
          end
          state <= put_z;
	//if c is inf return inf
        end else if (c_e == 128) begin
          z[31] <= c_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= put_z;
        //if a is zero return c
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= c_s;
          z[30:23] <= c_e[7:0] + 127;
          z[22:0] <= c_m[26:3];
          state <= put_z;
        //if b is zero return c
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
          z[31] <= c_s;
          z[30:23] <= c_e[7:0] + 127;
          z[22:0] <= c_m[26:3];
          state <= put_z;
	//if a and b and c is zero return zero
        end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(c_e) == -127) && (c_m == 0)) &&(($signed(b_e) == -127) && (b_m == 0))) begin
          z[31] <= a_s ^ b_s & c_s;
          z[30:23] <= c_e[7:0] + 127;
          z[22:0] <= c_m[26:3];
          state <= put_z;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
            a_m[23] <= 1;
          end
          //Denormalised Number
          if ($signed(b_e) == -127) begin
            b_e <= -126;
          end else begin
            b_m[23] <= 1;
          end
	  //Denormalised Number
          if ($signed(c_e) == -127) begin
            c_e <= -126;
          end else begin
            c_m[23] <= 1;
          end
          state <= normalise;
        end
      end

      normalise:
      begin
        if (~a_m[23]) begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end  
        if (~b_m[23]) begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end else if (a_m[23]) begin
	       state <= multiply_0;
        end
      end

      multiply_0:
      begin
        t_s <= a_s ^ b_s ^ sel[1]; //change the sign bit for add or sub
        t_e <= a_e + b_e + 1;
        t_m <= a_m * b_m;
        state <= align;
      end

      align: //need some fix for overflow and underflow
      begin
        if ($signed(t_e) > $signed(c_e)) begin
          c_e <= c_e + 1;
          c_m <= c_m >> 1;
          c_m[0] <= c_m[0] | c_m[1];
        end else if ($signed(t_e) < $signed(c_e)) begin
          t_e <= t_e + 1;
          t_m <= t_m >> 1;
          t_m[0] <= t_m[0] | t_m[1];
        end else begin
          state <= add_0;
        end
      end
      
      add_0:
      begin
        z_e <= t_e;
        if (t_s == c_s) begin
          sum <= t_m + c_m;
          z_s <= t_s;
        end else begin
          if (a_m >= c_m) begin
            sum <= t_m - c_m;
            z_s <= t_s;
          end else begin
            sum <= c_m - t_m;
            z_s <= c_s;
          end
        end
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (sum[48] == 0) begin
          z_e <= z_e - 1;
          sum <= sum << 1;
        end else begin
	      z_m <= sum[48:25];
	      guard <= sum[24];
          round_bit <= sum[23];
          sticky <= (sum[22:0] != 0);
          state <= normalise_2;
        end
      end

      normalise_2:
      begin
        if ($signed(z_e) < -126) begin
          z_e <= z_e + 1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
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
        z[30 : 23] <= z_e[7:0] + 127;
        z[31] <= z_s;
        if ($signed(z_e) == -126 && z_m[23] == 0) begin
          z[30 : 23] <= 0;
        end
        //if overflow occurs, return inf
        if ($signed(z_e) > 127) begin
          z[22 : 0] <= 0;
          z[30 : 23] <= 255;
          z[31] <= z_s;
        end
        state <= put_z;
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
