`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/28/2021 01:22:39 PM
// Design Name:
// Module Name: spi_controller
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
`default_nettype wire

module spi_controller (
    mmio_bus_if mbus
);

  logic clk, rst, rd, wr;
  logic [7:0] din;
  logic ignore_response, data_avail, buffer_empty, buffer_full;
  logic [7:0] dout;
  logic cs, sck, mosi, miso;

  always_comb begin
    clk = mbus.clk;
    rst = mbus.Rst;
    rd = mbus.spi_rd;
    wr = mbus.spi_wr;
    din = mbus.spi_din;
    ignore_response = mbus.spi_ignore_response;  // Unused
    mbus.spi_data_avail = data_avail;
    mbus.spi_buffer_empty = buffer_empty;
    mbus.spi_buffer_full = buffer_full;
    mbus.spi_dout = dout;
    miso = mbus.spi_miso;
    mbus.spi_mosi = mosi;
    mbus.spi_cs = cs;
    mbus.spi_sck = sck;
  end

  logic mosi_RD, mosi_WR;
  logic mosi_empty, mosi_full;
  logic mosi_avail;
  logic [7:0] mosi_din, mosi_dout;

  logic miso_RD, miso_WR;
  logic miso_empty, miso_full;
  logic miso_avail;
  logic [7:0] miso_din, miso_dout;

  logic spi_en;
  logic [7:0] mosi_data_i, miso_data_o;
  logic spi_data_ready;

  logic ctrl_state;

  int tx_count;
  assign tx_count = 1;

  spi_master_cs spi0 (
      .i_Rst_L(~rst),
      .i_Clk(clk),
      .i_TX_Count(tx_count),
      .i_TX_Byte(mosi_data_i),
      .i_TX_DV(spi_en),
      .o_TX_Ready(spi_data_ready),
      .o_RX_Count(),
      .o_RX_DV(miso_WR),
      .o_RX_Byte(miso_data_o),
      .o_SPI_Clk(sck),
      .i_SPI_MISO(miso),
      .o_SPI_MOSI(mosi),
      .o_SPI_CS_n(cs)
  );

  sync_fifo mosi_fifo (
      .clk(clk),
      .rst(rst),
      .srst(rst),
      .wr(mosi_WR),
      .rd(mosi_RD),
      .d(mosi_din),
      .q(mosi_dout),
      .empty(mosi_empty),
      .full(mosi_full)
  );

  sync_fifo miso_fifo (
    .clk(clk),
    .rst(rst),
    .srst(rst),
    .wr(miso_WR),
    .rd(miso_RD),
    .d(miso_din),
    .q(miso_dout),
    .empty(miso_empty),
    .full(miso_full)
  );

  assign mosi_avail = ~mosi_empty;
  assign miso_avail = ~miso_empty;
  assign miso_din = miso_data_o;
  assign mosi_WR = wr;
  assign mosi_din = din;
  assign buffer_empty = mosi_empty;
  assign buffer_full = mosi_full;
  assign data_avail = miso_avail;
  assign miso_RD = miso_avail & rd;

  always_ff @(posedge miso_RD or posedge rst) begin
    if (rst) begin
      dout <= 0;
    end else begin
      dout <= miso_dout;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      ctrl_state <= 0;
      mosi_RD <= 0;
      spi_en <= 0;
      mosi_data_i <= 0;
    end else begin
      if ((ctrl_state == 0) && (mosi_avail)) begin
        ctrl_state <= 1;
        mosi_RD <= 1;
        spi_en <= 1;
        mosi_data_i <= mosi_dout[7:0];
      end else if (ctrl_state & spi_data_ready) begin
        if (mosi_empty) begin
          ctrl_state <= 0;
          spi_en <= 0;
        end else begin
          mosi_RD <= 1;
          spi_en <= 1;
          mosi_data_i <= mosi_dout[7:0];
        end
      end else begin
        mosi_RD <= 0;
        spi_en <= 0;
      end
    end
  end
endmodule
