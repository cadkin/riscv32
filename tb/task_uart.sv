// UART Delay
task static delay();
  #8640;
endtask

// Transmits a byte through UART to core
task automatic send_byte (
  ref logic [7:0] rx_char,
  ref logic byte_sent,
  ref logic rx
);

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
task automatic send_word (
  input logic [31:0] rx_word,
  ref logic byte_sent,
  ref logic rx
);

  send_byte(rx_word[31:24], byte_sent, rx);
  delay();
  send_byte(rx_word[23:16], byte_sent, rx);
  delay();
  send_byte(rx_word[15:8], byte_sent, rx);
  delay();
  send_byte(rx_word[7:0], byte_sent, rx);
endtask