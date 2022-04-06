`timescale 1ns / 1ps

module debug_display (
    mmio_bus_if mbus
);

  logic clk, rst, mmio_wea;
  logic [31:0] din, dout;
  logic [4:0] addr;

  integer writecount = 0;

  // Addressable FIFO stores inputs and outputs to debug display
  addr_fifo u0 (
      .wea(mmio_wea),
      .*
  );

  // Connects to MMIO debug display
  always_comb begin : proc_bustransfer
    clk = mbus.clk;
    rst = mbus.Rst;
    mmio_wea = mbus.disp_wea;
    din = mbus.disp_dat;
    mbus.disp_out = dout;
    addr = mbus.debug_input;
  end
endmodule
