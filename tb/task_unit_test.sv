// Tests hazard detection, stalling, and forwarding
task automatic hz_unit_test (
  ref logic mmio_wea,
  ref logic [31:0] dout
);

  $display("Testing data hazard 3...");
  @(negedge mmio_wea);
  if (dout != 1) begin
    $display("FAILED at data hazard 3.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing data hazard 2...");
  @(negedge mmio_wea);
  if (dout != 2) begin
    $display("FAILED at data hazard 2.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing data hazard 1...");
  @(negedge mmio_wea);
  if (dout != 3) begin
    $display("FAILED at data hazard 1.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing branch hazard 3...");
  @(negedge mmio_wea);
  if (dout != 4) begin
    $display("FAILED at branch hazard 3.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing branch hazard 2...");
  @(negedge mmio_wea);
  if (dout != 5) begin
    $display("FAILED at branch hazard 2.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing branch hazard 1...");
  @(negedge mmio_wea);
  if (dout != 6) begin
    $display("FAILED at branch hazard 1.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing load/branch hazard...");
  @(negedge mmio_wea);
  if (dout != 7) begin
    $display("FAILED at load/branch hazard.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing load hazard...");
  @(negedge mmio_wea);
  if (dout != 8) begin
    $display("FAILED at load hazard.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");

  $display("Testing store hazard...");
  @(negedge mmio_wea);
  if (dout != 9) begin
    $display("FAILED at store hazard.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");
endtask

// Tests M-extension
task automatic m_ext_unit_test (
  ref logic mmio_wea,
  ref logic [31:0] dout
);

  $display("Testing M-extension...");
  @(negedge mmio_wea);
  if (dout != 10) begin
    $display("FAILED at M-extension.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");
endtask

// Tests ITOA and ATOI
task automatic itoa_atoi_unit_test (
  ref logic mmio_wea,
  ref logic [31:0] dout
);

  $display("Testing ITOA and ATOI...");
  @(negedge mmio_wea);
  if (dout != 11) begin
    $display("FAILED at ITOA and ATOI.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");
endtask

// Tests quicksort
task automatic qsort_unit_test (
  ref logic mmio_wea,
  ref logic [31:0] dout
);

  $display("Testing quicksort...");
  @(negedge mmio_wea);
  if (dout != 12) begin
    $display("FAILED at quicksort.");
    $display("---END SIMULATION---");
    $stop;
  end
  $display("SUCCESS.");
endtask

// Tests sending data through UART to core
task automatic uart_rx_unit_test (
  input logic [31:0] uart_str,
  ref logic byte_sent,
  ref logic rx
);

  $display("Testing UART...");
  send_word(uart_str, byte_sent, rx);
endtask

// Tests receiving data from UART to core
task automatic uart_tx_unit_test (
  ref logic tx_avail,
  ref logic [7:0] tx_byte,
  input logic [31:0] uart_str
);

  logic [31:0] uart_byte;

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