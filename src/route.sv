`timescale 1ns / 1ps

module route(
    // Basic signals
    input logic clk,
    input logic rst,

    // Switches / LEDs
    input  logic [15:0] sw,
    output logic [15:0] led,

    // SSD
    output logic [7:0] an,
    output logic [6:0] seg,

    // UART
    input  logic rx,
    output logic tx,

    // SPI
    //input  logic miso,
    //output logic mosi,
    //output logic spi_clk
);


endmodule
