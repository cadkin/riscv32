`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Decode
// Description:
//   Implements the RISC-V decode pipeline stage
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- debug I/O control
//   IF_ID_pres_adr -- 16-bit program counter address from fetch stage
//   ins -- 32-bit instruction operation code
//   WB_res -- 32-bit results for write back
//   EX_MEM_memread --
//   EX_MEM_regwrite --
//   EX_MEM_alures -- 32-bit ALU result
//   EX_MEM_rd -- 5-bit destination register (rd) address
//   IF_ID_dout_rs1 -- 32-bit source register (rs1) value from fetch stage
//   IF_ID_dout_rs2 -- 32-bit source register (rs2) value from fetch stage
// Output:
//   ID_EX_pres_adr -- 16-bit program counter address to execute stage
//   IF_ID_jalr -- fetch to decode flag for jump and link for subroutine return
//   ID_EX_jalr -- decode to execute flag for jump and link for subroutine return
//   branch_taken -- flag indicating branch taken
//   IF_ID_rs1 -- source register (rs1) address
//   IF_ID_rs2 -- source register (rs2) address
//   ID_EX_dout_rs1 -- 32-bit source register (rs1) value to execute stage
//   ID_EX_dout_rs2 -- 32-bit source register (rs2) value to execute stage
//   branoff -- 16-bit branch offset
//   ID_EX_rs1 -- 5-bit source register (rs1) address to execute stage
//   ID_EX_rs2 -- 5-bit source register (rs2) address to execute stage
//   ID_EX_alusel2 --
//   ID_EX_alusel1 --
//   ID_EX_alusel0 --
//   ID_EX_addb --
//   ID_EX_logicb --
//   ID_EX_rightb --
//   ID_EX_alusrc --
//   ID_EX_memread --
//   ID_EX_memwrite --
//   hz --
// Input/Output (Bidirectional):
//   ID_EX_rd -- 5-bit destination register (rd) address
//
//////////////////////////////////////////////////////////////////////////////////



module decode (
    main_bus_if.decode bus
);

  logic IF_ID_lui, lui;
  logic ID_EX_memread_sig, ID_EX_regwrite_sig;

  // Flushed Instruction Detector
  logic flush;

  logic ins_zero;
  logic flush_sig;
  logic [31:0] rs1_mod, rs2_mod, rs3_mod;

  logic [ 1:0] funct2;
  logic [ 2:0] funct3;
  logic [ 3:0] funct4;
  logic [ 5:0] funct6;
  logic [ 6:0] funct7;
  logic [11:0] funct12;
  logic [31:0] comp_imm;

  logic IF_ID_jal, IF_ID_compare;
  logic jal, compare, jalr_sig;
  logic IF_ID_jalr_sig;

  // Hazard Detection and Compare Unit
  logic zero1, zero2, zero3, zero4, zeroa, zerob;

  // Register File
  logic [4:0] IF_ID_rd;
  logic [31:0] dout_rs1, dout_rs2, dout_rs3;

  // Control
  logic [2:0] IF_ID_alusel, alusel, IF_ID_frm, rm;
  logic [4:0] IF_ID_fpusel, fpusel_s;
  logic [2:0] IF_ID_mulsel;
  logic [2:0] IF_ID_divsel;
  logic IF_ID_branch, branch;
  logic IF_ID_memwrite, IF_ID_memread, IF_ID_regwrite, IF_ID_alusrc;
  logic IF_ID_fpusrc;
  logic memwrite, memread, regwrite, alusrc;
  logic fmemwrite, fmemread, fregwrite, fpusrc;
  logic [2:0] IF_ID_storecntrl, storecntrl, fstorecntrl;
  logic [4:0] IF_ID_loadcntrl, loadcntrl;
  logic [2:0] floadcntrl;
  logic [3:0] IF_ID_cmpcntrl;
  logic       IF_ID_auipc;
  logic [4:0] IF_ID_rs3, IF_ID_rs2, IF_ID_rs1;
  logic [2:0] csrsel;
  logic csrwrite;
  logic csrread;
  logic [11:0] IF_ID_CSR_addr;

  // Immediate Generation
  logic [31:0] imm, IF_ID_imm;
  logic hz_sig;
  logic branch_taken_sig;
  logic div_ready_sig;
  logic div_ready;
  logic mul_ready_sig;
  logic mul_ready;

  // Compressed Signals
  logic [4:0] c_rd, c_rs1, c_rs2;
  logic [1:0] c_funct2;
  logic [2:0] c_funct3;
  logic [3:0] c_funct4;
  logic [5:0] c_funct6;
  logic [6:0] c_funct7;
  logic [2:0] c_alusel;
  logic [2:0] c_storecntrl;
  logic [4:0] c_loadcntrl;
  logic c_branch, c_beq, c_bne, c_memread, c_memwrite, c_regwrite, c_alusrc, c_compare;
  logic c_lui, c_jal, c_jalr;
  logic [31:0] c_imm;

  logic trap_ret;

  logic mul_inst;
  logic div_inst;

  // Control Signal Generation Unit
  control u0_control (
      .clk(bus.clk),
      .opcode(bus.ins[6:0]),
      .funct3(funct3),
      .funct7(funct7),
      .funct12(funct12),
      .ins_zero(ins_zero),
      .flush(flush),
      .hazard(hz_sig),
      .rs1(bus.ins[19:15]),
      .rd(bus.ins[11:7]),
      .alusel(alusel),
      .mulsel(IF_ID_mulsel),
      .divsel(IF_ID_divsel),
      .storecntrl(storecntrl),
      .loadcntrl(loadcntrl),
      .cmpcntrl(IF_ID_cmpcntrl),
      .branch(branch),
      .memread(memread),
      .memwrite(memwrite),
      .regwrite(regwrite),
      .alusrc(alusrc),
      .compare(compare),
      .auipc(IF_ID_auipc),
      .lui(lui),
      .jal(jal),
      .jalr(jalr_sig),
      .csrsel(csrsel),
      .csrwrite(csrwrite),
      .csrread(csrread),
      .trap_ret(trap_ret),
      .mul_inst(mul_inst),
      .div_inst(div_inst)
  );

  // Compressed Instruction Control Unit
  control_cmpr u1_control_cmpr (
      .ins(bus.ins),
      .ins_zero(ins_zero),
      .flush(flush),
      .hazard(hz_sig),
      .rd(c_rd),
      .rs1(c_rs1),
      .rs2(c_rs2),
      .funct2(c_funct2),
      .funct3(c_funct3),
      .funct4(c_funct4),
      .funct6(c_funct6),
      .funct7(c_funct7),
      .alusel(c_alusel),
      .storecntrl(c_storecntrl),
      .loadcntrl(c_loadcntrl),
      .branch(c_branch),
      .beq(c_beq),
      .bne(c_bne),
      .memread(c_memread),
      .memwrite(c_memwrite),
      .regwrite(c_regwrite),
      .alusrc(c_alusrc),
      .compare(c_compare),
      .lui(c_lui),
      .jal(c_jal),
      .jalr(c_jalr),
      .imm(c_imm)
  );

  // Floating Point Control Unit
  Control_fp u2_control_fp (
      .opcode(bus.ins[6:0]),
      .funct3(funct3),
      .funct7(funct7),
      .ins_zero(ins_zero),
      .flush(flush),
      .hazard(hz_sig),
      .rs2(bus.ins[24:20]),
      .rd(bus.ins[11:7]),
      .fpusel_s(IF_ID_fpusel),
      .memwrite(fmemwrite),
      .memread(fmemread),
      .regwrite(fregwrite),
      .fpusrc(IF_ID_fpusrc),
      .storecntrl(fstorecntrl),
      .loadcntrl(floadcntrl),
      .rm(IF_ID_frm)
  );

  // Immediate Generation Unit
  imm_gen u3_imm_gen (
      .ins(bus.ins),
      .imm(imm)
  );

  // Compare Unit
  // For branch decision and hazard detection
  compare u4_compare (
      .IF_ID_rs1(IF_ID_rs1),
      .IF_ID_rs2(IF_ID_rs2),
      .ID_EX_rd(bus.ID_EX_rd),
      .EX_MEM_rd(bus.EX_MEM_rd),
      .MEM_WB_rd(bus.MEM_WB_rd),
      .zero1(zero1),
      .zero2(zero2),
      .zero3(zero3),
      .zero4(zero4),
      .zeroa(zeroa),
      .zerob(zerob)
  );

  // Hazard Detection Unit
  hazard u5_hazard (
      .zero1(zero1),
      .zero2(zero2),
      .zero3(zero3),
      .zero4(zero4),
      .IF_ID_alusrc(IF_ID_alusrc),
      .IF_ID_jalr(IF_ID_jalr_sig),
      .IF_ID_branch(IF_ID_branch),
      .ID_EX_memread(bus.ID_EX_memread),
      .ID_EX_regwrite(bus.ID_EX_regwrite),
      .EX_MEM_memread(bus.EX_MEM_memread),
      .hz(hz_sig)
  );

  // Branch Forward Unit
  branch_forward u6_branch_forward (
      .rs1(bus.IF_ID_dout_rs1),
      .rs2(bus.IF_ID_dout_rs2),
      .zero3(zero3),
      .zero4(zero4),
      .zeroa(zeroa),
      .zerob(zerob),
      .alusrc(IF_ID_alusrc),
      .imm(IF_ID_imm),
      .alures(bus.EX_MEM_alures),
      .wbres(bus.WB_res),
      .divres(bus.EX_MEM_divres),
      .mulres(bus.EX_MEM_mulres),
      .EX_MEM_regwrite(bus.EX_MEM_regwrite),
      .EX_MEM_memread(bus.EX_MEM_memread),
      .MEM_WB_regwrite(bus.MEM_WB_regwrite),
      .div_ready(div_ready_sig),
      .mul_ready(mul_ready_sig),
      .rs1_mod(rs1_mod),
      .rs2_mod(rs2_mod)
  );

  // Branch Decision Unit
  branch_decision u7_branch_decision (
      .rs1_mod(rs1_mod),
      .rs2_mod(rs2_mod),
      .hazard(hz_sig),
      .branch(IF_ID_branch),
      .funct3(funct3),
      .jal(IF_ID_jal),
      .jalr(IF_ID_jalr_sig),
      .branch_taken(branch_taken_sig)
  );

  // Branch Offset Generation Unit
  branch_off_gen u8_branch_off_gen (
      .ins(bus.ins),
      .rs1_mod(rs1_mod),
      .comp_sig(bus.comp_sig),
      .comp_imm(c_imm),
      .jal(IF_ID_jal),
      .jalr(IF_ID_jalr_sig),
      .branoff(bus.branoff)
  );

  // Stalls pipeline if instruction is 0x00000000
  assign ins_zero = !(|bus.ins);
  // Clears branch/jump signal after a branch/jump or triggered trap
  assign flush = flush_sig | bus.trigger_trap | bus.trap_ret;
  // Indicates whether branch is taken
  assign bus.branch = branch_taken_sig;
  // Stalls program counter if hazard is present or MUL/DIV execution in progress
  assign bus.hz = hz_sig || (mul_inst && !bus.mul_ready) || (div_inst && !bus.div_ready);

  // CSR Signals
  assign IF_ID_CSR_addr = bus.ins[31:20];
  assign bus.IF_ID_CSR_addr = IF_ID_CSR_addr;
  // Indicates ECALL instruction, used to make a request to the supporting execution environment
  assign bus.ecall = flush ? 1'b0 : (bus.ins == 32'b00000000000000000000000001110011);

  // MUL/DIV Signals
  assign div_ready = div_ready_sig;
  assign mul_ready = mul_ready_sig;

  // Pipeline Signals
  assign bus.IF_ID_rs1 = IF_ID_rs1;
  assign bus.IF_ID_rs2 = IF_ID_rs2;
  assign bus.IF_ID_rs3 = IF_ID_rs3;
  assign bus.IF_ID_jalr = IF_ID_jalr_sig;
  assign bus.IF_ID_jal = IF_ID_jal;
  assign bus.ID_EX_memread = ID_EX_memread_sig;
  assign bus.ID_EX_regwrite = ID_EX_regwrite_sig;

  always_comb begin
    if (bus.comp_sig) begin
      funct2 = c_funct2;
      funct3 = c_funct3;
      funct4 = c_funct4;
      funct6 = c_funct6;
      funct7 = c_funct7;
      IF_ID_rs1 = c_rs1;
      IF_ID_rs2 = c_rs2;
      IF_ID_rs3 = 5'h0;
      IF_ID_rd = c_rd;
      bus.IF_ID_rd = IF_ID_rd;
      IF_ID_alusel = c_alusel;
      IF_ID_storecntrl = c_storecntrl;
      IF_ID_loadcntrl = c_loadcntrl;
      IF_ID_branch = c_branch;
      IF_ID_memread = c_memread;
      IF_ID_memwrite = c_memwrite;
      IF_ID_regwrite = c_regwrite;
      IF_ID_alusrc = c_alusrc;
      IF_ID_compare = c_compare;
      IF_ID_lui = c_lui;
      IF_ID_jal = c_jal;
      IF_ID_jalr_sig = c_jalr;
      IF_ID_imm = c_imm;
    end else begin
      if (fpusrc) begin
        IF_ID_storecntrl = fstorecntrl;
        IF_ID_loadcntrl = {2'b00, floadcntrl};
        IF_ID_memread = fmemread;
        IF_ID_memwrite = fmemwrite;
        IF_ID_regwrite = fregwrite;
      end else begin
        IF_ID_storecntrl = storecntrl;
        IF_ID_loadcntrl = loadcntrl;
        IF_ID_memread = memread;
        IF_ID_memwrite = memwrite;
        IF_ID_regwrite = regwrite;
      end
      IF_ID_branch = branch;
      IF_ID_alusel = alusel;
      funct3 = bus.ins[14:12];
      funct7 = bus.ins[31:25];
      funct12 = bus.ins[31:20];
      IF_ID_rs1 = bus.ins[19:15];
      IF_ID_rs2 = bus.ins[24:20];
      IF_ID_rs3 = bus.ins[31:27];
      IF_ID_rd = bus.ins[11:7];
      bus.IF_ID_rd = IF_ID_rd;
      IF_ID_alusrc = alusrc;
      IF_ID_compare = compare;
      IF_ID_lui = lui;
      IF_ID_jal = jal;
      IF_ID_jalr_sig = jalr_sig;
      IF_ID_imm = imm;
    end
  end

  always_ff @(posedge bus.clk) begin
    if (bus.Rst) begin
      bus.ID_EX_alusel <= 3'h0;
      bus.ID_EX_mulsel <= 3'h0;
      bus.ID_EX_divsel <= 3'h0;
      bus.ID_EX_alusrc <= 1'b0;
      bus.ID_EX_fpusel <= 5'b11111; // TODO: Refactor FPU to use 0b00000 as default.
      bus.ID_EX_fpusrc <= 1'b0;
      bus.ID_EX_frm <= 3'h0;
      ID_EX_memread_sig <= 1'b0;
      bus.ID_EX_memwrite <= 1'b0;
      ID_EX_regwrite_sig <= 1'b0;
      bus.ID_EX_storecntrl <= 3'h0;
      bus.ID_EX_loadcntrl <= 5'h0;
      bus.ID_EX_cmpcntrl <= 4'h0;
      bus.ID_EX_rs1 <= 5'b00000;
      bus.ID_EX_rs2 <= 5'b00000;
      bus.ID_EX_rd <= 5'b00000;
      bus.ID_EX_dout_rs1 <= 32'h00000000;
      bus.ID_EX_dout_rs2 <= 32'h00000000;
      bus.ID_EX_pres_addr <= 8'h00;
      bus.ID_EX_compare <= 1'b0;
      bus.ID_EX_imm <= 32'h00000000;
      bus.ID_EX_jal <= 1'b0;
      bus.ID_EX_jalr <= 1'b0;
      bus.ID_EX_lui <= 1'b0;
      bus.ID_EX_auipc <= 1'b0;
      bus.ID_EX_CSR_addr <= 12'b0;
      bus.ID_EX_CSR <= 32'b0;
      bus.ID_EX_CSR_write <= 1'b0;
      bus.csrsel <= 3'b000;
      bus.ID_EX_CSR_read <= 0;
      bus.ID_EX_comp_sig <= 0;
      bus.trap_ret <= 0;
      div_ready_sig <= 0;
      mul_ready_sig <= 0;
    // Set ID/EX pipeline register with IF/ID values
    // Freeze pipeline if debug or prog activated
    end else if ((!bus.dbg) && (!bus.mem_hold) && (!bus.f_stall)) begin
      if ((!hz_sig) & bus.RAS_rdy) begin
        bus.ID_EX_alusel <= IF_ID_alusel;
        bus.ID_EX_mulsel <= IF_ID_mulsel;
        bus.ID_EX_divsel <= IF_ID_divsel;
        bus.ID_EX_alusrc <= IF_ID_alusrc;
        bus.ID_EX_fpusel <= IF_ID_fpusel;
        bus.ID_EX_fpusrc <= IF_ID_fpusrc;
        bus.ID_EX_frm <= IF_ID_frm;
        ID_EX_memread_sig <= IF_ID_memread;
        bus.ID_EX_memwrite <= IF_ID_memwrite;
        ID_EX_regwrite_sig <= IF_ID_regwrite;
        bus.ID_EX_storecntrl <= IF_ID_storecntrl;
        bus.ID_EX_loadcntrl <= IF_ID_loadcntrl;
        bus.ID_EX_cmpcntrl <= IF_ID_cmpcntrl;
        bus.ID_EX_rs1 <= IF_ID_rs1;
        bus.ID_EX_rs2 <= IF_ID_rs2;
        bus.ID_EX_rd <= IF_ID_rd;
        bus.ID_EX_compare <= IF_ID_compare;
        bus.ID_EX_dout_rs1 <= bus.IF_ID_dout_rs1;
        bus.ID_EX_dout_rs2 <= bus.IF_ID_dout_rs2;
        bus.ID_EX_imm <= IF_ID_imm;
        bus.ID_EX_pres_addr <= bus.IF_ID_pres_addr;
        flush_sig <= branch_taken_sig;
        bus.ID_EX_jal <= IF_ID_jal;
        bus.ID_EX_jalr <= IF_ID_jalr_sig;
        bus.ID_EX_lui <= IF_ID_lui;
        bus.ID_EX_auipc <= IF_ID_auipc;
        bus.ID_EX_CSR_addr <= IF_ID_CSR_addr;
        bus.ID_EX_CSR <= bus.IF_ID_CSR;
        bus.ID_EX_CSR_write <= csrwrite;
        bus.csrsel <= csrsel;
        bus.ID_EX_CSR_read <= csrread;
        bus.ID_EX_comp_sig <= bus.comp_sig;
        bus.trap_ret <= trap_ret;
        div_ready_sig <= bus.div_ready;
        mul_ready_sig <= bus.mul_ready;
      end else begin
        bus.ID_EX_alusel <= 3'b000;
        bus.ID_EX_alusrc <= 1'b1;
        bus.ID_EX_fpusel <= 5'b11111; // TODO: Refactor FPU to use 0b00000 as default.
        bus.ID_EX_fpusrc <= 1'b0;
        bus.ID_EX_frm <= 3'h0;
        ID_EX_memread_sig <= 1'b0;
        bus.ID_EX_memwrite <= 1'b0;
        ID_EX_regwrite_sig <= 1'b0;
        bus.ID_EX_storecntrl <= 3'b000;
        bus.ID_EX_loadcntrl <= 3'b000;
        bus.ID_EX_cmpcntrl <= 2'b00;
        bus.ID_EX_rs1 <= 5'b00000;
        bus.ID_EX_rs2 <= 5'b00000;
        bus.ID_EX_rd <= 5'b00000;
        bus.ID_EX_compare <= 1'b0;
        bus.ID_EX_dout_rs1 <= 32'h00000000;
        bus.ID_EX_dout_rs2 <= 32'h00000000;
        bus.ID_EX_imm <= 32'h00000000;
        bus.ID_EX_pres_addr <= bus.IF_ID_pres_addr;
        flush_sig <= 1'b0;
        bus.ID_EX_jal <= 1'b0;
        bus.ID_EX_jalr <= 1'b0;
        bus.ID_EX_lui <= 1'b0;
        bus.ID_EX_auipc <= 1'b0;
        bus.ID_EX_CSR_addr <= 12'b0;
        bus.ID_EX_CSR <= 32'b0;
        bus.ID_EX_CSR_write <= 1'b0;
        bus.csrsel <= 3'b000;
        bus.ID_EX_CSR_read <= 0;
        bus.ID_EX_comp_sig <= bus.comp_sig;
        bus.trap_ret <= 0;
        div_ready_sig <= div_ready;
        mul_ready_sig <= mul_ready;
      end
    end
  end
endmodule
