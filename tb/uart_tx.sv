
module uart_tx (
    input logic clk,
    input logic rst,
    input logic tx,
    output logic tx_avail,
    output logic [7:0] tx_byte
);

  // Testbench UART Tx
  typedef enum {
    idle,
    reading
  } tx_rcv_e;
  tx_rcv_e tx_rcv;
  logic [7:0] tx_byte;
  logic tx_avail;
  int tx_cnt, tx_idx;

  // Testbench UART Tx
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
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
endmodule : uart_tx
