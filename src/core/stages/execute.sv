`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Execute
// Description:
//   Implements the RISC-V execution pipeline stage
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- debug I/O control
//   ID_EX_compare --
//   ID_EX_pres_adr -- 16-bit program counter (present address) from decode stage
//   ID_EX_alusel2 --
//   ID_EX_alusel1 --
//   ID_EX_alusel0 --
//   ID_EX_addb --
//   ID_EX_rightb --
//   ID_EX_logicb --
//   ID_EX_alusrc --
//   ID_EX_memread --
//   ID_EX_memwrite --
//   ID_EX_regwrite --
//   ID_EX_rs1 -- 5-bit source register 1 address (rs1)
//   ID_EX_rs2 -- 5-bit source register 2 address (rs2)
//   ID_EX_rd -- 5-bit destination register address (rd)
//   ID_EX_dout_rs1 -- 32-bit value from source register 1 (rs1)
//   ID_EX_dout_rs2 -- 32-bit value from source register 2 (rs2)
//   ID_EX_imm -- 32-bit immediate value
//   MEM_WB_regwrite --
//   EX_MEM_alures -- 32-bit
//   WB_res -- 32-bit
//   ID_EX_jal -- jump and link indicator
//   ID_EX_jalr -- jump and link for subrouting return indicator
//   MEM_WB_rd -- 5-bit destination register address for write back
// Output:
//   EX_MEM_dout_rs2 -- 32-bit value output to memory
//   ins -- 32-bit instruction operation code
//   EX_MEM_memread --
//   EX_MEM_rd -- 5-bit destination register address for memory access
//   EX_MEM_memwrite -- memory write signal
//   EX_MEM_regwrite -- register write signal
//   EX_MEM_comp_res --
//   dbg_ALUop1 -- 32-bit ALU operation for debugging
//   dbg_ALUop2 -- 32-bit ALU operation for debugging
//
//////////////////////////////////////////////////////////////////////////////////


module execute (
    main_bus_if.execute bus
);

  logic EX_MEM_memread_sig, EX_MEM_regwrite_sig, EX_MEM_fpusrc;
  logic [31:0] EX_MEM_alures_sig, EX_MEM_fpures_sig;
  logic [31:0] EX_MEM_mulres_sig;
  logic [31:0] EX_MEM_divres_sig;
  logic [ 4:0] EX_MEM_rd_sig;
  logic comp_res, f_stall;
  logic [31:0] alures, fpures;
  logic [31:0] mulres;
  logic [31:0] divres;
  logic [31:0] ALUop1, ALUop2, rs2_mod;

  logic [31:0] CSR_res;

  logic mul_ready_sig;
  logic div_ready_sig;
  logic mul_ready;
  logic div_ready;

  // Forwarding Unit
  forwarding u1_fwd (
      .EX_MEM_regwrite(EX_MEM_regwrite_sig),
      .EX_MEM_memread(EX_MEM_memread_sig),
      .MEM_WB_regwrite(bus.MEM_WB_regwrite),
      .WB_ID_regwrite(bus.WB_ID_regwrite),
      .EX_MEM_rd(EX_MEM_rd_sig),
      .MEM_WB_rd(bus.MEM_WB_rd),
      .WB_ID_rd(bus.WB_ID_rd),
      .ID_EX_rs1(bus.ID_EX_rs1),
      .ID_EX_rs2(bus.ID_EX_rs2),
      .alures(bus.EX_MEM_alures),
      .divres(divres),
      .mulres(mulres),
      .memres(bus.WB_res),
      .wbres(bus.WB_ID_res),
      .alusrc(bus.ID_EX_alusrc),
      .imm(bus.ID_EX_imm),
      .rs1(bus.ID_EX_dout_rs1),
      .rs2(bus.ID_EX_dout_rs2),
      .div_ready(div_ready),
      .mul_ready(mul_ready),
      .EX_MEM_CSR(bus.EX_MEM_CSR),
      .EX_MEM_CSR_read(bus.EX_MEM_CSR_read),
      .fw_rs1(ALUop1),
      .fw_rs2(ALUop2),
      .rs2_mod(rs2_mod)
  );

  // Arithmetic Logic Unit
  alu u2_alu (
      .a(ALUop1),
      .b(ALUop2),
      .ID_EX_pres_adr(bus.ID_EX_pres_addr),
      .alusel(bus.ID_EX_alusel),
      .ID_EX_lui(bus.ID_EX_lui),
      .ID_EX_jal(bus.ID_EX_jal),
      .ID_EX_jalr(bus.ID_EX_jalr),
      .ID_EX_auipc(bus.ID_EX_auipc),
      .ID_EX_compare(bus.ID_EX_compare),
      .csrsel(bus.csrsel),
      .CSR_in(bus.ID_EX_CSR),
      .ID_EX_comp_sig(bus.ID_EX_comp_sig),
      .res(alures),
      .comp_res(comp_res),
      .CSR_res(CSR_res)
  );

  // Multiplier Unit
  multiplier u3_mul (
      .clk(bus.clk),
      .rst(bus.Rst),
      .mulsel(bus.ID_EX_mulsel),
      .a(ALUop1),
      .b(ALUop2),
      .ready(mul_ready_sig),
      .res(mulres)
  );

  // Divider Unit
  divider u4_div (
      .clk(bus.clk),
      .rst(bus.Rst),
      .divsel(bus.ID_EX_divsel),
      .a(ALUop1),
      .b(ALUop2),
      .ready(div_ready_sig),
      .res(divres)
  );

  // Floating Point Unit
  FPU u5_fpu (
      .a(bus.ID_EX_dout_rs1),
      .b(bus.ID_EX_dout_rs2),
      .c(bus.ID_EX_dout_rs3),
      .frm(bus.EX_MEM_frm),
      .fpusel_s(bus.ID_EX_fpusel),
      .fpusel_d(bus.ID_EX_fpusel),
      .g_clk(bus.clk),
      .fp_clk(bus.clk),
      .g_rst(bus.Rst),
      .res(fpures),
      .stall(f_stall)
  );

  // Pipeline Signals
  assign bus.mul_ready = mul_ready_sig;
  assign bus.div_ready = div_ready_sig;
  assign bus.EX_MEM_rd = EX_MEM_rd_sig;
  assign bus.EX_MEM_alures = EX_MEM_fpusrc ? EX_MEM_fpures_sig : EX_MEM_alures_sig;
  assign bus.EX_MEM_mulres = EX_MEM_mulres_sig;
  assign bus.EX_MEM_divres = EX_MEM_divres_sig;
  assign bus.EX_MEM_fpusrc = EX_MEM_fpusrc;
  assign bus.EX_MEM_memread = EX_MEM_memread_sig;
  assign bus.EX_MEM_regwrite = EX_MEM_regwrite_sig;

  // Setting pipeline registers
  always_ff @(posedge bus.clk) begin
    if (bus.Rst) begin
      EX_MEM_rd_sig <= 5'b00000;
      EX_MEM_memread_sig <= 1'b0;
      bus.EX_MEM_memwrite <= 1'b0;
      EX_MEM_regwrite_sig <= 1'b0;
      EX_MEM_alures_sig <= 32'h00000000;
      EX_MEM_mulres_sig <= 32'h00000000;
      EX_MEM_divres_sig <= 32'h00000000;
      EX_MEM_fpures_sig <= 32'h00000000;
      EX_MEM_fpusrc <= 1'b0;
      bus.EX_MEM_frm <= 3'b000;
      bus.EX_MEM_dout_rs2 <= 32'h00000000;
      bus.EX_MEM_mul_ready <= 1'b0;
      bus.EX_MEM_div_ready <= 1'b0;
      bus.EX_MEM_rs2 <= 5'h0;
      bus.EX_MEM_rs1 <= 5'h0;
      bus.EX_MEM_comp_res <= 1'b0;
      bus.EX_MEM_loadcntrl <= 5'h0;
      bus.EX_MEM_storecntrl <= 3'h0;
      bus.EX_MEM_pres_addr <= 32'h0;
      bus.EX_CSR_res <= 0;
      bus.EX_CSR_addr <= 0;
      bus.EX_CSR_write <= 0;
      bus.EX_MEM_CSR <= 0;
      bus.EX_MEM_CSR_read <= 0;
      div_ready <= 0;
      mul_ready <= 0;
      bus.f_stall <= 1'b0;
    // Set EX/MEM pipeline register with ID/EX values
    // Freeze pipeline if debug or prog activated
    end else if ((!bus.dbg) && (!bus.mem_hold) && (!bus.f_stall)) begin
      EX_MEM_rd_sig <= bus.ID_EX_rd;
      EX_MEM_memread_sig <= bus.ID_EX_memread;
      bus.EX_MEM_memwrite <= bus.ID_EX_memwrite;
      EX_MEM_regwrite_sig <= (bus.ID_EX_regwrite && (!bus.ID_EX_compare)) +
                             (bus.ID_EX_regwrite && bus.ID_EX_compare && comp_res);
      EX_MEM_alures_sig <= alures;
      EX_MEM_mulres_sig <= mulres;
      bus.EX_MEM_mul_ready <= mul_ready_sig;
      EX_MEM_divres_sig <= divres;
      bus.EX_MEM_div_ready <= div_ready_sig;
      EX_MEM_fpures_sig <= fpures;
      EX_MEM_fpusrc <= bus.ID_EX_fpusrc;
      bus.EX_MEM_frm <= bus.ID_EX_frm;
      bus.EX_MEM_dout_rs2 <= rs2_mod;
      bus.EX_MEM_rs2 <= bus.ID_EX_rs2;
      bus.EX_MEM_rs1 <= bus.ID_EX_rs1;
      bus.EX_MEM_comp_res <= comp_res;
      bus.EX_MEM_loadcntrl <= bus.ID_EX_loadcntrl;
      bus.EX_MEM_storecntrl <= bus.ID_EX_storecntrl;
      bus.EX_MEM_pres_addr <= bus.ID_EX_pres_addr;
      bus.EX_CSR_res <= CSR_res;
      bus.EX_CSR_addr <= bus.ID_EX_CSR_addr;
      bus.EX_CSR_write <= bus.ID_EX_CSR_write;
      bus.EX_MEM_CSR <= bus.ID_EX_CSR;
      bus.EX_MEM_CSR_read <= bus.ID_EX_CSR_read;
      div_ready <= div_ready_sig;
      mul_ready <= mul_ready_sig;
      bus.f_stall <= f_stall;
    end
  end
endmodule : execute
