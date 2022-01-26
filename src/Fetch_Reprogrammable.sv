`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose. Grayson Bruner
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
// Modified:
//   May 20, 2019
//
// Module name: Fetch_Reprogrammable
// Description:
//   Implements the RISC-V fetch pipeline stage. This functions almost identically
//   to the original fetch module, however this one has added functionality
//   to reprogram the instruction memory through UART.
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   En -- enable signal
//   debug -- debug I/O control
//   prog -- debug or reprogram instruction memory
//   Rst -- system reset
//   branch -- branch single
//   IF_ID_jalr -- flag jump and link for subrouting return
//   rx -- uart recv pin
//   branoff -- 16-bit offset for branching
// Output:
//   IF_ID_pres_adr -- 16-bit program counter address
//   ins -- 32-bit instruction operation code
//
//////////////////////////////////////////////////////////////////////////////////

//This functions almost identically to the original fetch module, however this one has added functionality
//to reprogram the instruction memory through UART.
module Fetch_Reprogrammable (
    main_bus_if bus
);

  logic [31:0] pc_incr;
  logic [31:0] memdout;
  logic [31:0] next_addr;
  logic [31:0] pres_addr;
  logic [31:0] imem_addr;
  logic [31:0] imem_next_addr, imem_incr;
  logic [31:0] ins_last;
  logic imem_en;
  logic [31:0] addr_in;
  logic En_sig, En_mem, state_load_prog;
  logic [31:0] debug_addr_imm;
  logic comp_sig;
  logic bg;
  logic lower, next_comp, comp;

  logic branch_next;
  logic [31:0] branch_addr;
  assign comp = (memdout[1:0] != 2'b11) & (memdout != 0);
  assign comp_sig = comp;
  assign bus.comp_sig = comp_sig;
  assign debug_addr_imm[9:5] = 5'b00000;
  assign debug_addr_imm[4:0] = bus.debug_input;
  assign bus.next_addr = next_addr;
  assign memdout = bus.imem_dout;

  assign pc_incr = bg ? 0 : comp_sig ? 12'h002 : 12'h004;
  assign imem_incr = bus.branch ? bus.branoff : 12'h004;

  assign next_addr = bus.trap_ret ? bus.mepc :
                     bus.trigger_trap ? bus.mtvec :
                     branch_next ? branch_addr : bus.IF_ID_pres_addr + pc_incr;

  assign En_sig = (bus.PC_En && (!bus.debug) && (!bus.dbg) && (!bus.mem_hold) && (!bus.f_stall));
  assign En_mem = En_sig || bus.prog;
  assign bus.ins = bus.Rst ? 32'h00000000 : comp_sig ? {16'h0000, memdout[15:0]} : memdout;

  assign addr_in = bus.prog ? debug_addr_imm : imem_addr;
  assign imem_addr = next_addr;
  assign bus.imem_en = En_mem;
  assign bus.imem_addr = addr_in;

  always_ff @(posedge bus.clk) begin
    if (bus.Rst || bus.memcon_prog_ena) begin
      bg <= 1;
      bus.IF_ID_pres_addr <= 32'h000;
      ins_last <= 0;
      branch_addr <= 0;
      branch_next <= 0;
    end else if (En_sig) begin
      bg <= 0;
      bus.IF_ID_pres_addr <= next_addr;
      branch_addr <= bus.IF_ID_jalr ? bus.branoff :
                     bus.IF_ID_jal ? (bus.IF_ID_pres_addr + bus.branoff) :
                     bus.branch ? (bus.IF_ID_pres_addr + bus.branoff) : 0;
      branch_next <= bus.IF_ID_jalr | bus.IF_ID_jal | bus.branch;
    end else begin
    end
  end
endmodule
