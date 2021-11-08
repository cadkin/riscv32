`timescale 1ns / 1ps

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
