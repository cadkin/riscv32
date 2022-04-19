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
// Module name: Fetch
// Description:
//   Implements the RISC-V fetch pipeline stage. This functions almost identically
//   to the original fetch module, however this one has added functionality
//   to reprogram the instruction memory through UART.
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
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
module fetch (
    main_bus_if.fetch bus
);

  logic [31:0] pc_incr;
  logic [31:0] memdout;
  logic [31:0] next_addr;
  logic [31:0] imem_addr;
  logic [31:0] addr_in;
  logic En_sig, En_mem;
  logic [31:0] debug_addr_imm;
  logic comp_sig;
  logic bg;
  logic comp;

  logic branch_next;
  logic [31:0] branch_addr;

  // Checks if current fetched instruction is compressed
  assign comp = (memdout[1:0] != 2'b11) & (memdout != 0);
  assign comp_sig = comp;
  assign bus.comp_sig = comp_sig;

  // Sets a custom address through debug input when prog is high
  assign debug_addr_imm[9:5] = 5'b00000;
  assign debug_addr_imm[4:0] = bus.debug_input;

  // Determines whether PC is incremented by 2 (compressed 16-bit) or 4 (32-bit)
  assign pc_incr = bg ? 0 : comp_sig ? 12'h002 : 12'h004;

  // Sets the address to the next instruction by incrementing the program counter
  assign bus.next_addr = next_addr;
  assign next_addr = bus.trap_ret ? bus.mepc :
                     bus.trigger_trap ? bus.mtvec :
                     branch_next ? branch_addr : bus.IF_ID_pres_addr + pc_incr;

  // Sends the address to find the next instruction to the memory controller
  assign imem_addr = next_addr;
  assign addr_in = bus.prog ? debug_addr_imm : imem_addr;
  assign bus.imem_addr = addr_in;

  // Freeze program counter in these cases:
  // 1. Debug or dbg signals raised
  // 2. Mem_hold raised (potentially unused)
  // 3. FPU stalls
  assign En_sig = (bus.PC_En && (!bus.debug) && (!bus.dbg) && (!bus.mem_hold) && (!bus.f_stall));
  assign En_mem = En_sig || bus.prog;
  assign bus.imem_en = En_mem;

  // Loads the current instruction (either 16-bit compressed or 32-bit) from instruction memory
  // If compressed instruction, clear the upper 16-bits which belongs to the next instruction
  assign bus.ins = bus.Rst ? 32'h00000000 : comp_sig ? {16'h0000, memdout[15:0]} : memdout;
  assign memdout = bus.imem_dout;

  // Updates the instruction memory address to either next address or branch address
  always_ff @(posedge bus.clk) begin
    if (bus.Rst || bus.memcon_prog_ena) begin
      bg <= 1;
      bus.IF_ID_pres_addr <= 32'h000;
      branch_addr <= 0;
      branch_next <= 0;
    // Sets next address in case of branches or jumps
    end else if (En_sig) begin
      bg <= 0;                                                              // PC will increment
      bus.IF_ID_pres_addr <= next_addr;                                     // Sets next address
      branch_addr <= bus.IF_ID_jalr ? bus.branoff :                         // Addr. in reg. + off.
                     bus.IF_ID_jal ? (bus.IF_ID_pres_addr + bus.branoff) :  // PC + off.
                     bus.branch ? (bus.IF_ID_pres_addr + bus.branoff) : 0;  // PC + off.
      branch_next <= bus.IF_ID_jalr | bus.IF_ID_jal | bus.branch;           // Jump/branch present
    end else begin
    end
  end
endmodule
