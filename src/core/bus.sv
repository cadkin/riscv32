`timescale 1ns / 1ps

interface rvbus(input logic clk, input logic rst)
    // Program memory
    logic pmem_wea;
    logic pmem_en;
    logic [31:0] pmem_addr;
    logic [31:0] pmem_din;
    logic [31:0] pmem_dout;

    // Instruction memory
    logic imem_wea;
    logic imem_en;
    logic [31:0] imem_addr;
    logic [31:0] imem_din;
    logic [31:0] imem_dout;

    // Instruction
    logic [31:0] instr;

    logic [31:0] irq;

    modport core(
        input clk, rst,

        input  pmem_dout,
        output pmem_wea, pmem_en, pmem_addr, pmem_din,

        input  imem_dout,
        output imem_wea, imem_en, imem_addr, imem_din
    );


endinterface
