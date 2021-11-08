`timescale 1ns / 1ps

/*
 * Module: counter
 * Description: A simple synchronous counter.
 * Requires:
 *  - none.
 *
 * Parameters:
 *  - WIDTH: width of counter.
 *
 * Ports:
 *  Input:
 *    - clk:        clock
 *    - rst:        system reset
 *    - inc:        increment the counter; must be high when clocked, takes precedence
 *    - dec:        decrement the counter; must be high when clocked
 *  Output:
 *    - cnt:        value of counter
 *    - zero:       if the value of the counter is zero
 *    - overflow:   if the last operation on the counter caused an overflow
 */
module counter #(WIDTH = 8) (
    input logic clk,
    input logic rst,

    input logic inc,
    input logic dec,

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
