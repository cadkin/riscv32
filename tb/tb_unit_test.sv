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



module tb_unit_test ();
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
  logic rx;
  logic tx;

  // Core SPI
  logic miso, mosi, cs;

  // Testbench UART Transmitter
  typedef enum {
    idle,
    reading
  } tx_rcv_e;
  tx_rcv_e tx_rcv;
  logic [7:0] tx_byte;
  logic tx_avail;
  int tx_cnt, tx_idx;

  // Testbench UART Receiver
  logic byte_sent;
  logic [31:0] uart_byte;
  logic [31:0] output_code;

  // RISC-V Top Module
  riscv_top dut (.*);

  // Clock and Reset
  always #5 clk = !clk;
  assign rst_n = ~Rst;

  // UART Delay
  task static delay();
    #8640;
  endtask

  // Transmits a byte through UART to core
  task static send_byte(input logic [7:0] rx_char);
    byte_sent = 0;
    rx = 0;
    delay();
    for (int i = 0; i < 8; i++) begin
      rx = rx_char[i];
      delay();
    end
    byte_sent = 1;
    rx = 1;
  endtask

  // Transmits a word through UART to core
  task static send_word(input logic [31:0] rx_word);
    send_byte(rx_word[31:24]);
    delay();
    send_byte(rx_word[23:16]);
    delay();
    send_byte(rx_word[15:8]);
    delay();
    send_byte(rx_word[7:0]);
  endtask

  // Tests hazard detection, stalling, and forwarding
  task static hz_unit_test();
    $display("Testing data hazard 3...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 1) begin
      $display("FAILED at data hazard 3.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing data hazard 2...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 2) begin
      $display("FAILED at data hazard 2.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing data hazard 1...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 3) begin
      $display("FAILED at data hazard 1.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing branch hazard 3...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 4) begin
      $display("FAILED at branch hazard 3.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing branch hazard 2...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 5) begin
      $display("FAILED at branch hazard 2.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing branch hazard 1...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 6) begin
      $display("FAILED at branch hazard 1.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing load/branch hazard...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 7) begin
      $display("FAILED at load/branch hazard.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing load hazard...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 8) begin
      $display("FAILED at load hazard.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");

    $display("Testing store hazard...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 9) begin
      $display("FAILED at store hazard.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");
  endtask

  // Tests quicksort
  task static qsort_unit_test();
    $display("Testing quicksort...");
    @(negedge dut.d0.mmio_wea);
    if (dut.d0.dout != 10) begin
      $display("FAILED at quicksort.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");
  endtask

  // Tests sending data through UART to core
  task static uart_rx_unit_test();
    $display("Testing UART...");
    send_word(uart_str);
  endtask

  // Tests receiving data from UART to core
  task static uart_tx_unit_test();
    @(posedge tx_avail);
    uart_byte[31:24] = tx_byte;
    @(posedge tx_avail);
    uart_byte[23:16] = tx_byte;
    @(posedge tx_avail);
    uart_byte[15:8] = tx_byte;
    @(posedge tx_avail);
    uart_byte[7:0] = tx_byte;
    if (uart_byte != uart_str) begin
      $display("FAILED at UART.");
      $display("---END SIMULATION---");
      $stop;
    end
    $display("SUCCESS.");
  endtask

  // Testbench UART Transmitter
  always_ff @(posedge dut.u0.B_CLK or posedge Rst) begin
    if (Rst) begin
      tx_cnt   <= 0;
      tx_byte  <= 0;
      tx_rcv   <= idle;
      tx_idx   <= 0;
      tx_avail <= 0;
    end else begin
      if (tx_cnt == 15) begin
        tx_cnt <= 0;
        if ((tx_rcv == idle) & (tx == 0)) begin
          tx_rcv   <= reading;
          tx_idx   <= 0;
          tx_avail <= 0;
        end else if (tx_rcv == reading) begin
          if (tx_idx < 8) begin
            tx_byte[tx_idx] <= tx;
            tx_idx <= tx_idx + 1;
          end else begin
            tx_idx   <= 0;
            tx_avail <= 1;
            tx_rcv   <= idle;
          end
        end else begin
          tx_avail <= 0;
        end
      end else begin
        tx_cnt <= tx_cnt + 1;
      end
    end
  end

  // Stop simulation if core execution reaches endloop instruction
  always_ff @(posedge dut.clk_50M) begin
    if ((dut.rbus.IF_ID_pres_addr == 32'h14) & (dut.rbus.branch)) begin
      $stop;
    end
  end

  // String to test in UART
  logic [31:0] uart_str = "abcd";

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

    hz_unit_test();
    qsort_unit_test();
    uart_rx_unit_test();
  end

  initial begin
    uart_tx_unit_test();
    $display("---END SIMULATION---");
    $stop;
  end
endmodule
