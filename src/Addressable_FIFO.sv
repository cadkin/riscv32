`timescale 1ns / 1ps

module Addressable_FIFO (
    input  logic        clk,
    input  logic        rst,
    input  logic        wea,
    input  logic [31:0] din,
    input  logic [ 4:0] addr,
    output logic [31:0] dout
);

  logic [31:0] data[31:0];

  integer i;
  always_ff @(posedge clk) begin : proc_FIFO
    if (rst) begin
      dout <= 32'h00000000;
      for (i = 31; i >= 0; i = i - 1) data[i] <= 32'h00000000;
    end else begin
      if (wea) begin
        for (i = 31; i > 0; i = i - 1) begin
          data[i] <= data[i-1];
        end
        data[0] <= din;
      end
      dout <= data[addr];
    end
  end
endmodule
