//IEEE Floating Point squart root (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
// Project F Library - Square Root (Fixed-Point)
// (C)2021 Will Green, Open source hardware released under the MIT License
//adproted by Jianjun Xu
//01/12/2022

module fsqrt #(
    parameter WIDTH=32,  // width of radicand
    parameter FBITS=23   // fractional bits (for fixed point)
    ) (  
  input logic  [31:0] input_a
  input logic [2:0] frm,
  input logic  clk,rst,
  output logic [31:0] output_z,
  output logic output_z_stb);

  logic [WIDTH-1:0] rad,   // radicand
  logic [WIDTH-1:0] root,  // root
  logic [WIDTH-1:0] rem    // remainder
  logic [WIDTH-1:0] x, x_next;    // radicand copy
  logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
  logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
  logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)
  reg       s_output_z_stb;
  reg       [31:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [3:0] state;
  parameter unpack        = 4'd2,
            special_cases = 4'd3,
            normalise_a   = 4'd4,
            multiply_0    = 4'd6,
            multiply_1    = 4'd7,
            normalise_1   = 4'd8,
            normalise_2   = 4'd9,
            round         = 4'd10,
            pack          = 4'd11,
            put_z         = 4'd12;

  reg       [31:0] a, z;
  reg       [23:0] a_m, z_m;
  reg       [9:0] a_e, z_e;
  reg       a_s,  z_s;
  reg       guard, round_bit, sticky;
  reg       [47:0] product;

  localparam ITER = (WIDTH+FBITS) >> 1;  // iterations are half radicand+fbits width
  logic [$clog2(ITER)-1:0] i;            // iteration counter

  always_comb begin
      test_res = ac - {q, 2'b01};
      if (test_res[WIDTH+1] == 0) begin  // test_res ≥0? (check MSB)
          {ac_next, x_next} = {test_res[WIDTH-1:0], x, 2'b0};
          q_next = {q[WIDTH-2:0], 1'b1};
      end else begin
          {ac_next, x_next} = {ac[WIDTH-1:0], x, 2'b0};
          q_next = q << 1;
      end
  end

  always @(posedge clk)
  begin

    case(state)
      unpack:
      begin
        s_output_z_stb <= 0;
        a_m <= input_a[22 : 0];
        a_e <= input_a[30 : 23] - 127;
        a_s <= input_a[31];
        if(rst == 0) begin
	    state <= special_cases;
	end
      end

      special_cases:
      begin
        //if a is NaN or b is NaN return NaN 
        if (a_e == 128 && a_m != 0) begin
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
          state <= put_z;
	//if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= put_z;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
            a_m[23] <= 1;
          end
          state <= normalise_a;
        end
      end

      normalise_a:
      begin
        if (a_m[23]) begin
          state <= multiply_0;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      multiply_0:
      begin
	if (i == ITER-1) begin  // we're done
           root <= q_next;
           rem <= ac_next[WIDTH+1:2];  // undo final shift
	   state <= multiply_1;
        end else begin  // next iteration
            i <= i + 1;
            x <= x_next;
            ac <= ac_next;
            q <= q_next;
	    state <= multiply_0;
         end
        z_s <= a_s;
        z_e <= a_e>>1;
      end

      multiply_1:
      begin
        z_m <= product[47:24];
        guard <= product[23];
        round_bit <= product[22];
        sticky <= (product[21:0] != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[23] == 0) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
        end else begin
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
