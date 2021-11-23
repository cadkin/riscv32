`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2021 10:21:37 PM
// Design Name: 
// Module Name: Execute_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
interface riscv_bus (
    input  reg clk, Rst, debug, prog,
    input  logic scan_en, scan_in, scan_clk,
    output logic scan_out,
    input  logic [4:0] debug_input
    );

    //Memory signals
    logic mem_wea, mem_rea;
    logic [3:0] mem_en;
    logic [31:0] mem_addr;
    logic [31:0] mem_din, mem_dout;
    logic [2:0] storecntrl;
    logic [31:0] debug_output;

    //Instruction memory signals
    logic imem_en, imem_prog_ena;
    logic [31:0] imem_addr;
    logic [31:0] imem_dout, imem_din;

    logic mem_hold;
    logic uart_IRQ;
    logic trapping;

    //RAS signals
    logic RAS_branch, ret, stack_full, stack_empty, stack_mismatch;
    logic [31:0] RAS_addr_in;

    logic RAS_rdy;
    logic [31:0] IF_ID_pres_addr, ins, IF_ID_dout_rs1, branoff, next_addr;
    logic branch, IF_ID_jal;
    logic [4:0] IF_ID_rd;

    assign ret = (branch & ((ins == 32'h8082) | (ins == 32'h8067)));
	assign RAS_branch = branch & IF_ID_jal & (IF_ID_rd == 1);
    assign RAS_addr_in = RAS_branch ? (next_addr) : (ret ? branoff : 1'b0);

    modport core(
        input clk, Rst, debug, prog, debug_input, mem_dout, imem_dout, //rx,
        output debug_output, mem_wea, mem_rea, mem_en, mem_addr, mem_din, imem_en,
        output imem_addr, imem_din, imem_prog_ena, storecntrl,
        input mem_hold, uart_IRQ,
        output trapping,
        output IF_ID_pres_addr, ins, IF_ID_dout_rs1, branch, IF_ID_jal, IF_ID_rd, branoff, next_addr,
        input stack_mismatch, RAS_rdy, RAS_branch, ret
    );

    modport memcon(
        input clk, Rst, mem_wea, mem_en, mem_addr, mem_din, imem_en,
        input imem_addr, imem_din, imem_prog_ena, mem_rea, storecntrl,
        output mem_dout, imem_dout, mem_hold,
        input scan_clk, scan_en, scan_in,
        output scan_out
    );

    modport CRAS(
    	input clk, Rst, RAS_branch, ret, RAS_addr_in,
    	//input RAS_mem_rdy,
    	output stack_full, stack_empty, stack_mismatch, RAS_rdy
    );

    modport uart(
    	output uart_IRQ
    );
endinterface

module Execute_sim(

    input  logic clk,
    input  logic rst_n,

    //FPGA Debugging
    input  logic debug,
    input  logic [4:0] debug_input,
    output logic [6:0] sev_out,
    output logic [7:0] an,
    output logic [15:0] led,

    //UART
    input  logic rx,
    output logic tx,

    //Scanchain (disable for FPGA testing)
//    input  logic scan_en,
//    input  logic scan_in,
//    input  logic scan_clk,
//    output logic scan_out,

    //SPI
    input  logic miso,
    output logic mosi, cs
    );
    
    reg clk, Rst, debug, prog, mem_wea, dbg; //rx,
    logic [4:0] debug_input;
    logic [31:0] debug_output, mem_addr, mem_din, mem_dout;
    logic [3:0] mem_en;
    logic RAS_rdy;

    logic trap;
    logic prog;
    logic [31:0] debug_output;
    logic [3:0]  seg_cur, seg_nxt;
    logic        clk_50M, clk_12M, clk_115k;
    logic clk_7seg;
    logic addr_dn, addr_up;
    reg Rst;
    logic rst_in, rst_last;

    // Comment out for FPGA testing
//    logic [4:0] debug_input;
//    logic debug;
//    assign debug = 0;
//    assign debug_input = 5'b00000;
//    logic [6:0] sev_out;
//    logic [7:0] an;
//    logic [15:0] led;
//    assign Rst = !rst_n;

    // Include for FPGA testing
    logic scan_en;
    logic scan_in;
    logic scan_clk;
    logic scan_out;
  riscv_bus rbus(.clk(clk_rv), .*);
  main_bus bus(.mem_hold(rbus.mem_hold), .uart_IRQ(rbus.uart_IRQ), .*);
  
  logic EX_MEM_memread_sig, EX_MEM_regwrite_sig,EX_MEM_fpusrc;
  logic [31:0] EX_MEM_alures_sig,EX_MEM_fpures_sig;
  logic [4:0]  EX_MEM_rd_sig;
  logic comp_res,f_stall;
  logic [31:0] alures,fpures;
  logic [2:0]  sel;
  logic [31:0] ALUop1,ALUop2,rs2_mod;
  logic [31:0] rs2_mod_final;//new
  
  logic [31:0] CSR_res;
  logic [31:0] CSR_mod; 
/*
FPU fut(.a(bus.ID_EX_dout_rs1),
        .b(bus.ID_EX_dout_rs2),
        .c(bus.ID_EX_dout_rs3),
        .rm(frm),
        .fpusel_s(bus.ID_EX_fpusel),
        .fpusel_d(bus.ID_EX_fpusel),
        .g_clk(bus.clk),
        .fp_clk(bus.clk),
        .g_rst(bus.Rst),
        .res(fpures),
        .stall(f_stall)
        ); 
 */
 Execute e(bus);
 reg clk;
 always begin
    #3 clk = !clk;  
 end
 assign bus.clk = clk;
 initial begin
    bus.ID_EX_fpusrc = 1;
    bus.Rst = 1;
    e.frm = 0;
    
    #15
    bus.Rst = 0;
    #15
    bus.ID_EX_dout_rs1 = 32'h408ccccd;
    bus.ID_EX_dout_rs2 = 32'h400ccccd;
    bus.ID_EX_fpusel = 1;
    #200;
    
    
    
    
 end


endmodule
