`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//
// Created:
//
// Module name: Addressable FIFO
// Description:
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
// Output:
//
//////////////////////////////////////////////////////////////////////////////////

module addr_fifo (
    input  logic        clk,
    input  logic        rst,
    input  logic        wea,
    input  logic [31:0] din,
    input  logic [ 4:0] addr,
    output logic [31:0] dout
);

  logic [31:0] data[32];

  // Stores writes to debug display in a FIFO that can be examined on the 7 segment display
  integer i;
  always_ff @(posedge clk) begin : proc_FIFO
    if (rst) begin
      dout <= 32'h00000000;
      for (i = 31; i >= 0; i = i - 1) data[i] = 32'h00000000;
    end else begin
      if (wea) begin
        for (i = 31; i > 0; i = i - 1) begin
          data[i] = data[i-1];
        end
        data[0] = din;
      end
      dout <= data[addr];
    end
  end
endmodule
