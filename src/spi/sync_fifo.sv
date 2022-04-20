module sync_fifo (
    input logic clk,
    input logic rst,
    input logic srst,
    input logic wr,
    input logic rd,
    input logic [8-1:0] d,
    output logic [8-1:0] q,
    output logic empty,
    output logic full
);

  logic [8-1:0] ram_mem[2**4];
  logic iempty;
  logic ifull;
  logic add_wr_ce;
  logic [4:0] add_wr;
  logic add_rd_ce;
  logic [4:0] add_rd;

  always_ff @(posedge clk) begin
    if ((wr == 1'b1) && (ifull == 1'b0)) ram_mem[add_wr[4-1:0]] <= d;
  end

  assign q = ram_mem[add_rd[4-1:0]];

  assign add_wr_ce = (ifull == 1'b1) ? 1'b0 :
                     (wr == 1'b0)    ? 1'b0 : 1'b1;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) add_wr <= 1'b0;
    else begin
      if (srst) add_wr <= 1'b0;
      else if (add_wr_ce) add_wr <= add_wr + 1;
      else add_wr <= add_wr;
    end
  end

  assign full = ifull;
  assign ifull = (add_rd[4] != add_wr[4]) &&
                 (add_rd[4-1:0] == add_wr[4-1:0]) ? 1'b1 : 1'b0;

  assign add_rd_ce = (iempty == 1'b1) ? 1'b0 : (rd == 1'b0) ? 1'b0 : 1'b1;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) add_rd <= 1'b0;
    else begin
      if (srst) add_rd <= 1'b0;
      else if (add_rd_ce) add_rd <= add_rd + 1;
      else add_rd <= add_rd;
    end
  end

  assign empty  = iempty;
  assign iempty = (add_wr == add_rd) ? 1'b1 : 1'b0;

  // Initializes ram_mem to 0 in simulations
`ifndef SYNTHESIS
  integer i;
  initial begin
    for (i = 0; i < 2 ** 4; i = i + 1) begin
      ram_mem[i] = 0;
    end
  end
`endif
endmodule : sync_fifo
