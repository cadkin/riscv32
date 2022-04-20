`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/17/2020 05:59:57 PM
// Design Name:
// Module Name: uart_controller
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


module uart_controller (
    mmio_bus_if  mbus,
    riscv_bus_if rbus
);

  logic clk, BR_clk, rst, CS, WR;
  logic [2:0] ADD;
  logic [7:0] D;
  logic sRX;
  logic sTX, DTRn, RTSn, OUT1n, OUT2n, TXRDYn, RXRDYn, IRQ, B_CLK;
  logic [7:0] RD;

  always_comb begin
    clk = mbus.clk;
    BR_clk = mbus.BR_clk;
    rst = mbus.Rst;
    sRX = mbus.rx;
    CS = mbus.rx_ren | mbus.tx_wen;
    WR = mbus.tx_wen;
    D = mbus.uart_din;
    ADD = mbus.uart_addr;
    mbus.tx = sTX;
    mbus.uart_dout = RD;
    rbus.uart_IRQ = IRQ;
  end

  typedef enum {
    idle,
    intr_pend
  } state_e;

  state_e state;

  gh_uart_16550 u0 (
      .clk(clk),
      .br_clk(BR_clk),
      .rst(rst),
      .cs(CS),
      .wr(WR),
      .add(ADD),
      .d(D),
      .srx(sRX),
      .stx(sTX),
      .dtrn(DTRn),
      .rtsn(RTSn),
      .out1n(OUT1n),
      .out2n(OUT2n),
      .txrdyn(TXRDYn),
      .rxrdyn(RXRDYn),
      .irq(IRQ),
      .b_clk(B_CLK),
      .rd(RD)
  );
endmodule
