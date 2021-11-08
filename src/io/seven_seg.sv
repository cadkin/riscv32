`timescale 1ns / 1ps

/*
 * Module: seven_seg
 * Description: A simple seven segment display driver.
 * Requires:
 *  - src/util/clk_divider.sv
 *
 * Ports:
 *  Input:
 *    - clk:   system clock
 *    - rst:   system reset
 *    - bin:   8x 4-bit numbers
 *    - blank: positions to keep blank
 *  Output:
 *    - seg:   active segments
 *    - an:    active digit
 */
module seven_seg(
    input logic clk,
    input logic rst,

    input logic [3:0] bin [7:0],
    input logic [7:0] blank,

    output logic [6:0] seg,
    output logic [7:0] an
);

    logic [7:0] ann;
    logic [3:0] cbin;

    logic div_clk;
    clkdiv #(50000) div (.clk(clk), .rst(rst), .div_clk(div_clk));

    always @(posedge div_clk) begin
        if (rst) begin
            ann <= 8'b11111110;
            cbin <= 4'b0000;
        end
        else begin
            // Rotate anode and value used.
            ann <= {ann[6:0], ann[7]};
            // Blank the anodes the user set.
            an <= ann | blank;
            case (ann)
                8'b01111111: cbin <= bin[0];
                8'b10111111: cbin <= bin[1];
                8'b11011111: cbin <= bin[2];
                8'b11101111: cbin <= bin[3];
                8'b11110111: cbin <= bin[4];
                8'b11111011: cbin <= bin[5];
                8'b11111101: cbin <= bin[6];
                8'b11111110: cbin <= bin[7];
                default:     cbin <= 4'b0000;
            endcase

            case (cbin)
                4'b0000: seg <= 8'b1000000; // "0"
                4'b0001: seg <= 8'b1111001; // "1"
                4'b0010: seg <= 8'b0100100; // "2"
                4'b0011: seg <= 8'b0110000; // "3"
                4'b0100: seg <= 8'b0011001; // "4"
                4'b0101: seg <= 8'b0010010; // "5"
                4'b0110: seg <= 8'b0000010; // "6"
                4'b0111: seg <= 8'b1111000; // "7"
                4'b1000: seg <= 8'b0000000; // "8"
                4'b1001: seg <= 8'b0010000; // "9"
                4'b1010: seg <= 8'b0100000; // "a"
                4'b1011: seg <= 8'b0000011; // "b"
                4'b1100: seg <= 8'b1000110; // "c"
                4'b1101: seg <= 8'b0100001; // "d"
                4'b1110: seg <= 8'b0000110; // "e"
                4'b1111: seg <= 8'b0001110; // "f"
                default: seg <= 8'b1111111; // none
            endcase
        end
    end
endmodule


