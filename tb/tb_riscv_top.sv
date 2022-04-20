`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/06/2019 10:07:43 AM
// Design Name:
// Module Name: tb_rvtop
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tb_riscv_top ();
  // Clock and Reset
  logic clk;
  logic Rst, rst_n;

  // FPGA Debugging
  logic debug;
  logic [4:0] debug_input;
  logic [ 6:0] sev_out;
  logic [ 7:0] an;
  logic [15:0] led;

  // Core UART
  logic rx, tx;

  // Core SPI
  logic miso, mosi, cs;
  logic sck;

  // Testbench UART Rx
  logic byte_sent;

  // Testbench UART Tx
  logic tx_avail;
  logic [7:0] tx_byte;

  // Clock and Reset
  always #5 clk = !clk;
  assign rst_n = ~Rst;

  // RISC-V Top Module
  riscv_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .debug(debug),
    .debug_input(debug_input),
    .sev_out(sev_out),
    .an(an),
    .led(led),
    .rx(rx),
    .tx(tx),
    .miso(mosi),
    .mosi(mosi),
    .cs(cs),
    .sck(sck)
  );

  initial begin
    $display("---BEGIN SIMULATION---");
    clk = 0;
    Rst = 1;
    debug = 0;
    debug_input = 0;
    byte_sent = 0;
    rx = 1;

    #10;
    Rst = 0;
  end
endmodule
