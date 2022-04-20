////////////////////////////////////////////////////////////////////-
//  Filename:  gh_fifo_async16_sr.sv
//
//
//  Description:
//    an Asynchronous FIFO
//
//  Copyright (c) 2006 by George Huber
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision  History:
//  Revision  Date        Author     Comment
//  ////////  //////////  ////////-  //////////-
//  1.0       12/17/06    h lefevre  Initial revision
//  2.0       04/20/22    SenecaUTK  Convert to SystemVerilog
//
////////////////////////////////////////////////////////
module gh_fifo_async16_sr #(
  parameter int data_width = 8
) (// size of data bus
  input logic clk_wr, // write clock
  input logic clk_rd, // read clock
  input logic rst,    // resets counters
  input logic srst,   // resets counters (sync with clk_wr)
  input logic wr,     // write control
  input logic rd,     // read control
  input logic [data_width-1:0] d,
  output logic [data_width-1:0] q,
  output logic empty,
  output logic full
);

  logic [data_width-1:0] ram_mem[16];
  logic iempty;
  logic ifull;
  logic add_wr_ce;
  logic [4:0] add_wr;    // 4 bits are used to address mem
  logic [4:0] add_wr_gc; // 5 bits are used to compare
  logic [4:0] n_add_wr;  //   for empty, full flags
  logic [4:0] add_wr_rs; // synced to read clk
  logic add_rd_ce;
  logic [4:0] add_rd;
  logic [4:0] add_rd_gc;
  logic [4:0] add_rd_gcwc;
  logic [4:0] n_add_rd;
  logic [4:0] add_rd_ws; // synced to write clk
  logic srst_w;
  logic isrst_w;
  logic srst_r;
  logic isrst_r;

//------------------------------------------
//----- memory -----------------------------
//------------------------------------------

  always_ff @(posedge clk_wr) begin
    if ((wr == 1'b1) && (ifull == 1'b0)) ram_mem[add_wr[3:0]] <= d;
  end

  assign q = ram_mem[add_rd[3:0]];

//---------------------------------------
//--- write address counter -------------
//---------------------------------------

  assign add_wr_ce = (ifull == 1'b1) ? 1'b0 :
                     (wr == 1'b0) ? 1'b0 : 1'b1;

  assign n_add_wr = add_wr + 4'h1;

  always_ff @(posedge clk_wr or posedge rst) begin
    if (rst == 1'b1) begin
      add_wr <= 0;
      add_rd_ws <= 5'b11000;
      add_wr_gc <= 0;
    end
    else begin
      add_rd_ws <= add_rd_gcwc;
      if (srst_w == 1'b1) begin
        add_wr <= 0;
        add_wr_gc <= 0;
      end
      else if (add_wr_ce == 1'b1) begin
        add_wr <= n_add_wr;
        add_wr_gc[0] <= n_add_wr[0] ^ n_add_wr[1];
        add_wr_gc[1] <= n_add_wr[1] ^ n_add_wr[2];
        add_wr_gc[2] <= n_add_wr[2] ^ n_add_wr[3];
        add_wr_gc[3] <= n_add_wr[3] ^ n_add_wr[4];
        add_wr_gc[4] <= n_add_wr[4];
      end
      else begin
        add_wr <= add_wr;
        add_wr_gc <= add_wr_gc;
      end
    end
  end

  assign full = ifull;

  assign ifull = (iempty == 1'b1) ? 1'b0 :               // just in case add_rd_ws is reset to 5'b00000
                 (add_rd_ws != add_wr_gc) ? 1'b0 : 1'b1; // instend of 5'b11000

//---------------------------------------
//--- read address counter --------------
//---------------------------------------


  assign add_rd_ce = (iempty == 1'b1) ? 1'b0 :
                     (rd == 1'b0) ? 1'b0 : 1'b1;

  assign n_add_rd = add_rd + 4'h1;

  always_ff @(posedge clk_rd or posedge rst) begin
    if (rst == 1'b1) begin
      add_rd <= 0;
      add_wr_rs <= 0;
      add_rd_gc <= 0;
      add_rd_gcwc <= 5'b11000;
    end
    else begin
      add_wr_rs <= add_wr_gc;
      if (srst_r == 1'b1) begin
        add_rd <= 0;
        add_rd_gc <= 0;
        add_rd_gcwc <= 5'b11000;
      end
      else if (add_rd_ce == 1'b1) begin
        add_rd <= n_add_rd;
        add_rd_gc[0] <= n_add_rd[0] ^ n_add_rd[1];
        add_rd_gc[1] <= n_add_rd[1] ^ n_add_rd[2];
        add_rd_gc[2] <= n_add_rd[2] ^ n_add_rd[3];
        add_rd_gc[3] <= n_add_rd[3] ^ n_add_rd[4];
        add_rd_gc[4] <= n_add_rd[4];
        add_rd_gcwc[0] <= n_add_rd[0] ^ n_add_rd[1];
        add_rd_gcwc[1] <= n_add_rd[1] ^ n_add_rd[2];
        add_rd_gcwc[2] <= n_add_rd[2] ^ n_add_rd[3];
        add_rd_gcwc[3] <= n_add_rd[3] ^ (~n_add_rd[4]);
        add_rd_gcwc[4] <= (~n_add_rd[4]);
      end
      else begin
        add_rd <= add_rd;
        add_rd_gc <= add_rd_gc;
        add_rd_gcwc <= add_rd_gcwc;
      end
    end
  end

  assign empty = iempty;

  assign iempty = (add_wr_rs == add_rd_gc) ? 1'b1 : 1'b0;

//--------------------------------
//-  sync rest stuff --------------
//- srst is sync with clk_wr -----
//- srst_r is sync with clk_rd ---
//--------------------------------

  always_ff @(posedge clk_wr or posedge rst) begin
    if (rst == 1'b1) begin
      srst_w <= 1'b0;
      isrst_r <= 1'b0;
    end
    else begin
      isrst_r <= srst_r;
      if (srst == 1'b1) srst_w <= 1'b1;
      else if (isrst_r == 1'b1) srst_w <= 1'b0;
    end
  end

  always_ff @(posedge clk_rd or posedge rst) begin
    if (rst == 1'b1) begin
      srst_r <= 1'b0;
      isrst_w <= 1'b0;
    end
    else begin
      isrst_w <= srst_w;
      if (isrst_w == 1'b1) srst_r <= 1'b1;
      else srst_r <= 1'b0;
    end
  end
endmodule : gh_fifo_async16_sr
