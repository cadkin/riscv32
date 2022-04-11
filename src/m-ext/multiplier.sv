module multiplier (
    input         clk,
    input         rst,
    input  [ 2:0] mulsel,
    input  [31:0] a,
    input  [31:0] b,
    output        ready,
    output [31:0] res
);

  logic [31:0] op_a;
  logic [31:0] op_b;
  logic high_bits;
  logic rdy;
  logic [64:0] full_res;

  logic is_mul;
  logic a_sign;
  logic b_sign;

  typedef enum logic [2:0] {
    no_mul = 3'b000,
    mul    = 3'b001,
    mulh   = 3'b010,
    mulhsu = 3'b011,
    mulhu  = 3'b100
  } mul_e;
  mul_e mul_op;

  assign mul_op = mul_e'(mulsel);
  assign is_mul = (mul_op != no_mul);

  typedef enum {
    idle,
    busy
  } state_e;
  state_e state_curr, state_next;

  always_ff @(posedge clk) begin
    if (rst) state_curr <= idle;
    else state_curr <= state_next;
  end

  always_comb begin
    state_next = state_curr;

    unique case (state_curr)
      idle: begin
        op_a  = 32'b0;
        op_b  = 32'b0;
        a_sign = 1'b0;
        b_sign = 1'b0;
        high_bits = 1'b0;
        full_res  = 32'h0;
        rdy       = 1'b0;
        if (is_mul) begin
          op_a  = a;
          op_b  = b;
          a_sign = (mul_op == (mul || mulh || mulhsu)) ? op_a[31] : 1'b0;
          b_sign = (mul_op == (mul || mulh)) ? op_b[31] : 1'b0;
          high_bits = (mul_op == (mulh || mulhu || mulhsu));
          state_next = busy;
        end
      end
      busy: begin
        full_res = {{32{a_sign}}, op_a} * {{32{b_sign}}, op_b};
        rdy      = 1'b1;
        if (rdy) state_next = idle;
      end
      default: begin
      end
    endcase
  end

  assign ready = rdy;
  assign res   = high_bits ? full_res[63:32] : full_res[31:0];
endmodule
