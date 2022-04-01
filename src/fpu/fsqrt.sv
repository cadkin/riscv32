//IEEE Floating Point squart root (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
// Project F Library - Square Root (Fixed-Point)
// (C)2021 Will Green, Open source hardware released under the MIT License
//adopted by Jianjun Xu
//01/12/2022

module fsqrt( 
  input logic  [31:0] input_a,
  input logic [2:0] rm,
  input logic  clk,rst,
  output logic [31:0] output_z,
  output logic output_z_stb);
  
  parameter WIDTH=26;  // width of radicand
  parameter FBITS=26;   // fractional bits (for fixed point)
  parameter unpack        = 4'd0,
            special_cases = 4'd1,
            normalise_a   = 4'd2,
            sqrt_0      = 4'd3,
            sqrt_1      = 4'd4,
            normalise_1   = 4'd7,
            normalise_2   = 4'd8,
            round         = 4'd9,
            pack          = 4'd10,
            put_z         = 4'd11;
  logic [WIDTH-1:0] rad;   // radicand
  logic [WIDTH-1:0] root;  // root
  logic [WIDTH-1:0] rem;    // remainder
  logic [WIDTH-1:0] x, x_next;    // radicand copy
  logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
  logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
  logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)
  reg       s_output_z_stb;
  reg       [31:0] s_output_z;

  reg       [3:0] state;
 
  reg       [31:0]z;
  reg       [23:0] a_m, z_m;
  reg       [9:0] a_e, z_e;
  reg       a_s,  z_s;
  reg       guard, round_bit, sticky;
  reg       [50:0] quotient, divisor, dividend, remainder;
  reg       [5:0] count;
  
  logic     [23:0] round_zm;
  logic     [9:0] round_ze;
  rounding r1(z_m,z_e,z_s,guard,round_bit,sticky,rm, round_zm, round_ze);

  localparam ITER = (WIDTH+FBITS) >> 1;  // iterations are half radicand+fbits width
  logic [$clog2(ITER)-1:0] i;            // iteration counter

  always_comb begin
      test_res = ac - {q, 2'b01};
      if (test_res[WIDTH+1] == 0) begin  // test_res >=0? (check MSB)
          {ac_next, x_next} = {test_res[WIDTH-1:0], x, 2'b0};
          q_next = {q[WIDTH-2:0], 1'b1};
      end else begin
          {ac_next, x_next} = {ac[WIDTH-1:0], x, 2'b0};
          q_next = q << 1;
      end
  end

  always @(posedge clk)
  begin
    if (rst == 1) begin
      state <= unpack;
      s_output_z_stb <= 0;
    end
    else begin

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
          z[31] <= a_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= put_z;
	//if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= a_s;
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
          i <= 0;
          q <= 0;
	      
	      z_s <= a_s;
	      if(a_e[0]) begin
          {ac, x} <= {{WIDTH{1'b0}}, a_m, 4'b0};
          end else begin
          {ac, x} <= {{WIDTH{1'b0}}, 1'b0, a_m, 3'b0};
          a_e <= (a_e + 1);
          end
          state <= sqrt_0;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      sqrt_0:
      begin
	    if (i == ITER-1) begin  // we're done
          quotient <= q_next;
          remainder <= ac_next[WIDTH+1:2];  // undo final shift
	      state <= sqrt_1;
        end else begin  // next iteration
          i <= i + 1;
          x <= x_next;
          ac <= ac_next;
          q <= q_next;
	      state <= sqrt_0;
        end
      end

      sqrt_1:
      begin
        z_e <= a_e >> 1;
        z_m <= quotient[25:2];
        guard <= quotient[1];
        round_bit <= quotient[0];
        sticky <= (remainder != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[23] == 0 && $signed(z_e) > -126) begin
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
          state <= pack;
        end
      end

      pack:
      begin
        z[22 : 0] <= round_zm[22:0];
        z[30 : 23] <= round_ze[7:0] + 127;
        z[31] <= z_s;
        if ($signed(round_ze) == -126 && round_zm[23] == 0) begin
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
   end


  end
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
