`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2018 01:30:18 PM
// Design Name:
// Module Name: tb_RISCVcore
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


module tb_riscv_core ();
  logic clk;
  logic Rst;
  logic prog;
  logic rx;
  logic tx;
  logic debug;
  logic [4:0] debug_input;
  logic [31:0] debug_output;
  logic addr_up, addr_dn;

  logic mem_wea;
  logic [3:0] mem_en;
  logic [11:0] mem_addr;
  logic [31:0] mem_din, mem_dout;

  riscv_core uut (.*);

  //clock generator
  always #5 clk = !clk;

  //stimuli
  initial begin
    clk = 1'b0;
    Rst = 1'b1;
    debug = 1'b0;
    rx = 1'b1;
    prog = 1'b0;
    debug_input = 5'b0;
    #10 Rst = 1'b0;
    #180 debug = 1'b1;
    debug_input = 5'b00011;
    #10 debug_input = 5'b00100;
    #10 debug_input = 5'b00101;
    #10 debug_input = 5'b00110;
    #10 debug_input = 5'b00110;
    #10 debug = 1'b0;
  end
endmodule
