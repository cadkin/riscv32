`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Memory
// Description:
//   Implements the RISC-V register file as an array of 32 32-bit registers
//   Specifically designed for Xilinx FPGA implementation using Block RAM
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- 1-bit debug control signal
//   EX_MEM_alures -- 32-bit result from ALU
//   EX_MEM_alusec -- second 32-bit operand for ALU
//   EX_MEM_rd -- 5-bit destination register number
//   EX_MEM_regwrite -- 1-bit register write control
//   EX_MEM_memread -- 1-bit memory read control
//   EX_MEM_memwrite -- 1-bit memory write control
// Output:
//   MEM_WB_regwrite -- 1-bit control for register writeback control
//   MEM_WB_memread -- 1-bit memory read writeback control
//   MEM_WB_rd -- 5-bit destination register number
//   MEM_WB_alures -- 32-bit registered value from ALU
//   MEM_WB_memres -- 32-bit value from memory
//
//////////////////////////////////////////////////////////////////////////////////

module memory (
    main_bus_if bus
);

  logic [31:0] MEM_WB_memres_sig, MEM_WB_memres_temp;
  logic [31:0] MEM_WB_memres;
  logic [ 1:0] MEM_WB_dout_sel;
  logic        En;
  logic [ 4:0] load_control;
  logic MEM_WB_lb, MEM_WB_lh, MEM_WB_lw, MEM_WB_lbu, MEM_WB_lhu;
  logic [4:0] MEM_WB_loadcntrl;
  logic [3:0] byte_write;
  logic [7:0] d0, d1, d2, d3;
  logic [31:0] memforward;
  logic MEM_WB_memwrite;
  logic [31:0] MEM_WB_dout_rs2;
  logic mmio_wea;
  logic set_mmio_wea;
  logic [31:0] mmio_dat;
  logic set_mmio_dat;

  assign En = 1'b1;

  always_comb
    unique case (bus.EX_MEM_storecntrl)
      3'b001: begin  // store byte (sb)
        unique case (bus.EX_MEM_alures[1:0])
          2'b00:   byte_write = 4'b0001;
          2'b01:   byte_write = 4'b0010;
          2'b10:   byte_write = 4'b0100;
          2'b11:   byte_write = 4'b1000;
          default: byte_write = 4'b0000;
        endcase
      end
      3'b010: begin  // store half word (sh)
        unique case (bus.EX_MEM_alures[1:0])
          2'b00:   byte_write = 4'b0011;
          2'b01:   byte_write = 4'b0110;
          2'b10:   byte_write = 4'b1100;
          2'b11:   byte_write = 4'b1001;
          default: byte_write = 4'b0000;
        endcase
      end
      3'b100:  byte_write = 4'b1111;
      3'b000:  byte_write = 4'b1111;  // not store
      default: byte_write = 4'b1111;
    endcase

  assign bus.mem_wea = bus.EX_MEM_memwrite;
  assign bus.mem_rea = bus.EX_MEM_memread;
  assign bus.mem_en = byte_write;
  assign bus.mem_addr = bus.EX_MEM_alures;
  assign bus.mem_din = memforward;
  assign MEM_WB_memres_temp = bus.mem_dout;

  assign d0 = MEM_WB_memres_temp[7:0];
  assign d1 = MEM_WB_memres_temp[15:8];
  assign d2 = MEM_WB_memres_temp[23:16];
  assign d3 = MEM_WB_memres_temp[31:24];

  assign bus.MEM_WB_memres = MEM_WB_memres;

  logic ctrl_fwd;

  assign ctrl_fwd = (bus.EX_MEM_memwrite && bus.MEM_WB_regwrite) &&
                    (bus.MEM_WB_rd == bus.EX_MEM_rs2);
  assign memforward = ctrl_fwd ? bus.WB_res : bus.EX_MEM_dout_rs2;

  always_comb MEM_WB_memres_sig = MEM_WB_memres_temp;
  always_comb
    case (MEM_WB_loadcntrl)
      5'b00001: MEM_WB_memres = {{24{MEM_WB_memres_sig[7]}}, MEM_WB_memres_sig[7:0]};
      5'b00010: MEM_WB_memres = {{16{MEM_WB_memres_sig[15]}}, MEM_WB_memres_sig[15:0]};
      5'b00100: MEM_WB_memres = MEM_WB_memres_sig;
      5'b01000: MEM_WB_memres = {{24{1'b0}}, MEM_WB_memres_sig[7:0]};
      5'b10000: MEM_WB_memres = {{16{1'b0}}, MEM_WB_memres_sig[15:0]};
      default:  MEM_WB_memres = 32'h0;
    endcase

  //passing to the next pipeline stage
  always_ff @(posedge bus.clk) begin
    if (bus.Rst) begin
      bus.MEM_WB_alures <= 32'h00000000;
      bus.MEM_WB_mulres <= 32'h00000000;
      bus.MEM_WB_mul_ready <= 1'b0;
      bus.MEM_WB_divres <= 32'h00000000;
      bus.MEM_WB_div_ready <= 1'b0;
      bus.MEM_WB_fpusrc <= 1'b0;
      bus.MEM_WB_memread <= 1'b0;
      bus.MEM_WB_regwrite <= 1'b0;
      bus.MEM_WB_rd <= 5'b00000;
      MEM_WB_loadcntrl <= 5'b00000;
      MEM_WB_dout_sel <= 2'b00;
      MEM_WB_memwrite <= 1'b0;
      MEM_WB_dout_rs2 <= 32'h00000000;
      mmio_wea <= 0;
      mmio_dat <= 0;
      bus.MEM_WB_pres_addr <= 32'h0;
      bus.MEM_WB_CSR <= 0;
      bus.MEM_WB_CSR_read <= 0;
    end else if ((!bus.dbg) && (!bus.mem_hold) && (!bus.f_stall)) begin
      bus.MEM_WB_alures <= bus.EX_MEM_alures;
      bus.MEM_WB_mulres <= bus.EX_MEM_mulres;
      bus.MEM_WB_mul_ready <= bus.EX_MEM_mul_ready;
      bus.MEM_WB_divres <= bus.EX_MEM_divres;
      bus.MEM_WB_div_ready <= bus.EX_MEM_div_ready;
      bus.MEM_WB_fpusrc <= bus.EX_MEM_fpusrc;
      bus.MEM_WB_memread <= bus.EX_MEM_memread;
      bus.MEM_WB_regwrite <= bus.EX_MEM_regwrite;
      bus.MEM_WB_rd <= bus.EX_MEM_rd;
      MEM_WB_loadcntrl <= bus.EX_MEM_loadcntrl;
      MEM_WB_dout_sel <= bus.EX_MEM_alures[1:0];
      MEM_WB_memwrite <= bus.EX_MEM_memwrite;
      MEM_WB_dout_rs2 <= bus.EX_MEM_dout_rs2;
      bus.MEM_WB_pres_addr <= bus.EX_MEM_pres_addr;
      bus.MEM_WB_CSR <= bus.EX_MEM_CSR;
      bus.MEM_WB_CSR_read <= bus.EX_MEM_CSR_read;
    end
  end
endmodule : memory
