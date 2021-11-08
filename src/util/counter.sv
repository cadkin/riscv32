`timescale 1ns / 1ps

module counter #(WIDTH = 8) (
    input logic inc,
    input logic dec,
    input logic clk,
    input logic rst,

    output logic [WIDTH - 1:0] cnt,
    output logic zero,
    output logic overflow
);

    logic is_one;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            is_one   <= 0;
            cnt      <= 0;
            zero     <= 1;
            overflow <= 0;
        end
        else begin
            is_one <= (cnt == 1);

            if (inc) cnt <= cnt + 1;
            else if (dec) cnt <= cnt - 1;

            zero <= (cnt == 0);
            overflow <= (!is_one && zero);
        end
    end
endmodule
