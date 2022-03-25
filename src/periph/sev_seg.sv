`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//
// Created:
//
// Module name: Seven Segment Display Driver
// Description:
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
// Output:
//
//////////////////////////////////////////////////////////////////////////////////

module sev_seg (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] din,
    output logic [6:0]  sev_out,
    output logic [7:0]  an_out
);

  typedef enum logic [7:0] {
    a0 = 8'b11111110,
    a1 = 8'b11111101,
    a2 = 8'b11111011,
    a3 = 8'b11110111,
    a4 = 8'b11101111,
    a5 = 8'b11011111,
    a6 = 8'b10111111,
    a7 = 8'b01111111
  } an_e;
  an_e an_cur, an_nxt;

  logic [3:0] seg_cur, seg_nxt;

  assign an_out = an_cur;

  always_comb begin
    case (seg_cur)
      4'b0000: sev_out = 7'b0000001;
      4'b0001: sev_out = 7'b1001111;
      4'b0010: sev_out = 7'b0010010;
      4'b0011: sev_out = 7'b0000110;
      4'b0100: sev_out = 7'b1001100;
      4'b0101: sev_out = 7'b0100100;
      4'b0110: sev_out = 7'b0100000;
      4'b0111: sev_out = 7'b0001111;
      4'b1000: sev_out = 7'b0000000;
      4'b1001: sev_out = 7'b0000100;
      4'b1010: sev_out = 7'b0001000;
      4'b1011: sev_out = 7'b1100000;
      4'b1100: sev_out = 7'b0110001;
      4'b1101: sev_out = 7'b1000010;
      4'b1110: sev_out = 7'b0110000;
      4'b1111: sev_out = 7'b0111000;
      default: sev_out = 7'b0000000;
    endcase
  end

  always_comb begin
    case (an_cur)
      a0: begin
        an_nxt  = a1;
        seg_nxt = din[7:4];
      end
      a1: begin
        an_nxt  = a2;
        seg_nxt = din[11:8];
      end
      a2: begin
        an_nxt  = a3;
        seg_nxt = din[15:12];
      end
      a3: begin
        an_nxt  = a4;
        seg_nxt = din[19:16];
      end
      a4: begin
        an_nxt  = a5;
        seg_nxt = din[23:20];
      end
      a5: begin
        an_nxt  = a6;
        seg_nxt = din[27:24];
      end
      a6: begin
        an_nxt  = a7;
        seg_nxt = din[31:28];
      end
      a7: begin
        an_nxt  = a0;
        seg_nxt = din[3:0];
      end
      default: begin
        an_nxt  = a0;
        seg_nxt = din[3:0];
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      an_cur  <= a0;
      seg_cur <= din[3:0];
    end else begin
      an_cur  <= an_nxt;
      seg_cur <= seg_nxt;
    end
  end
endmodule
