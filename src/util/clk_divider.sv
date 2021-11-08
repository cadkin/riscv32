`timescale 1ns / 1ps

/*
 * Module: clkdiv
 * Description: A simple clock divider module.
 * Requires:
 *  - none.
 *
 * Parameters:
 *  - DIV: value to divide clock by.
 *
 * Ports:
 *  Input:
 *    - clk:     system clock
 *    - rst:     system reset
 *  Output:
 *    - div_clk: divided clock signal
 */
module clkdiv #(parameter DIV = 2) (
    input logic clk,
    input logic rst,

    output logic div_clk
);

    logic [15:0] cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
            div_clk <= 0;
        end
        else begin
            if (cnt >= DIV) begin
                div_clk <= ~div_clk;
                cnt <= 0;
            end
            else cnt <= cnt + 1;
        end
    end
endmodule
