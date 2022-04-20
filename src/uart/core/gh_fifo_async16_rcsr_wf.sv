////////////////////////////////////////////////////////////////////-
//  Filename:  gh_fifo_async16_rcsr_wf.sv
//
//
//  Description:
//    a simple Asynchronous FIFO - uses FASM style Memory
//    16 word depth with UART level read flags
//    has "Style #2" gray code address compare
//
//  Copyright (c) 2007 by Howard LeFevre
//    an OpenCores.org Project
//    free to use, but see documentation for conditions
//
//  Revision  History:
//  Revision  Date        Author     Comment
//  ////////  //////////  ////////-  //////////-
//  1.0       01/20/07    h lefevre  Initial revision
//  2.0       04/20/22    SenecaUTK Convert to SystemVerilog
//
////////////////////////////////////////////////////////
module gh_fifo_async16_rcsr_wf (
  input logic clk_wr,  // write clock
  input logic clk_rd,  // read clock
  input logic rst,     // resets counters
  input logic rc_srst, // resets counters (sync with clk_rd!!!)
  input logic wr,      // write control
  input logic rd,      // read control
  input logic [11-1:0] d,
  output logic [11-1:0] q,
  output logic empty,  // sync with clk_rd!!!
  output logic q_full, // sync with clk_rd!!!
  output logic h_full, // sync with clk_rd!!!
  output logic a_full, // sync with clk_rd!!!
  output logic full
);

  logic [11-1:0] ram_mem[16];
  logic iempty;
  logic diempty;
  logic ifull;
  logic add_wr_ce;
  logic [4:0] add_wr;    // add_width -1 bits are used to address mem
  logic [4:0] add_wr_gc; // add_width bits are used to compare
  logic [4:0] iadd_wr_gc;
  logic [4:0] n_add_wr;  // for empty, full flags
  logic [4:0] add_wr_rs; // synced to read clk
  logic add_rd_ce;
  logic [4:0] add_rd;
  logic [4:0] add_rd_gc;
  logic [4:0] iadd_rd_gc;
  logic [4:0] add_rd_gcwc;
  logic [4:0] iadd_rd_gcwc;
  logic [4:0] iiadd_rd_gcwc;
  logic [4:0] n_add_rd;
  logic [4:0] add_rd_ws; // synced to write clk
  logic srst_w;
  logic isrst_w;
  logic srst_r;
  logic isrst_r;
  logic [4:0] c_add_rd;
  logic [4:0] c_add_wr;
  logic [4:0] c_add;

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

  assign n_add_wr = add_wr + 2'b01;

  gh_binary2gray u1 (
    .b(n_add_wr),
    .g(iadd_wr_gc)
  );

  always_ff @(posedge clk_wr or posedge rst) begin
    if (rst == 1'b1) begin
      add_wr <= 0;
      add_rd_ws[4:3] <= 2'b11;
      add_rd_ws[2:0] <= 0;
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
        add_wr_gc <= iadd_wr_gc;
      end
      else begin
        add_wr <= add_wr;
        add_wr_gc <= add_wr_gc;
      end
    end
  end

  assign full = ifull;

  assign ifull = (iempty == 1'b1) ? 1'b0 : // just in case add_rd_ws is reset to all zero's
                 (add_rd_ws != add_wr_gc) ? 1'b0 : 1'b1; // instend of "11 zero's"


//---------------------------------------
//--- read address counter --------------
//---------------------------------------


  assign add_rd_ce = (iempty == 1'b1) ? 1'b0 :
                     (rd == 1'b0) ? 1'b0 : 1'b1;

  assign n_add_rd = add_rd + 2'b01;

  gh_binary2gray u2 (
    .b(n_add_rd),
    .g(iadd_rd_gc) // to be used for empty flag
  );

  assign iiadd_rd_gcwc = {(~n_add_rd[4]), n_add_rd[3:0]};

  gh_binary2gray u3 (
    .b(iiadd_rd_gcwc),
    .g(iadd_rd_gcwc) // to be used for full flag
  );

  always_ff @(posedge clk_rd or posedge rst) begin
    if (rst == 1'b1) begin
      add_rd <= 0;
      add_wr_rs <= 0;
      add_rd_gc <= 0;
      add_rd_gcwc[4:3] <= 2'b11;
      add_rd_gcwc[2:0] <= 0;
      diempty <= 1'b1;
    end
    else begin
      add_wr_rs <= add_wr_gc;
      diempty <= iempty;
      if (srst_r == 1'b1) begin
        add_rd <= 0;
        add_rd_gc <= 0;
        add_rd_gcwc[4:3] <= 2'b11;
        add_rd_gcwc[2:0] <= 0;
      end
      else if (add_rd_ce == 1'b1) begin
        add_rd <= n_add_rd;
        add_rd_gc <= iadd_rd_gc;
        add_rd_gcwc <= iadd_rd_gcwc;
      end
      else begin
        add_rd <= add_rd;
        add_rd_gc <= add_rd_gc;
        add_rd_gcwc <= add_rd_gcwc;
      end
    end
  end

  assign empty = diempty;

  assign iempty = (add_wr_rs == add_rd_gc) ? 1'b1 : 1'b0;

  gh_gray2binary u4 (
    .g(add_rd_gc),
    .b(c_add_rd)
  );

  gh_gray2binary u5 (
    .g(add_wr_rs),
    .b(c_add_wr)
  );

  assign c_add = (c_add_wr - c_add_rd);

  assign q_full = (iempty == 1'b1) ? 1'b0 :
                  (c_add[4:2] == 3'b000) ? 1'b0 : 1'b1;

  assign h_full = (iempty == 1'b1) ? 1'b0 :
                  (c_add[4:3] == 2'b00) ? 1'b0 : 1'b1;

  assign a_full = (iempty == 1'b1) ? 1'b0 :
                  (c_add[4:1] < 4'b0111) ? 1'b0 : 1'b1;

//--------------------------------
//- sync rest stuff --------------
//- rc_srst is sync with clk_rd --
//- srst_w is sync with clk_wr ---
//--------------------------------

  always_ff @(posedge clk_wr or posedge rst) begin
    if (rst == 1'b1) begin
      srst_w <= 1'b0;
      isrst_r <= 1'b0;
    end
    else begin
      srst_w <= isrst_w;
      if (srst_w == 1'b1) isrst_r <= 1'b1;
      else if (srst_w == 1'b0) isrst_r <= 1'b0;
    end
  end

  always_ff @(posedge clk_rd or posedge rst) begin
    if (rst == 1'b1) begin
      srst_r <= 1'b0;
      isrst_w <= 1'b0;
    end
    else begin
      srst_r <= rc_srst;
      if (rc_srst == 1'b1) isrst_w <= 1'b1;
      else if (isrst_r == 1'b1) isrst_w <= 1'b0;
    end
  end
endmodule : gh_fifo_async16_rcsr_wf
