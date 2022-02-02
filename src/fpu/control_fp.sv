`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Jianjun Xu
//   University of Tennessee, Knoxville
//
// Created:
//   October 28, 2021
//
// Module name: Control_fp
// Description:
//   Implements the RISC-V control logic for floating point unit (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   opcode -- 7-bit opcode field from the 32-bit instruction
//   funct3 -- 3-bit funct3 field from the 32-bit instruction
//   funct7 -- 7-bit funct7 field from the 32-bit instruction
//   ins_zero --
//   flush --
//   hazard --
// Output:
//   fpusel_s2 --
//   fpusel_s1 --
//   fpusel_s0 --
//   addb --
//   rightb --
//   logicb --
//   branch --
//   memwrite --
//   memread --
//   regwrite --
//   alusrc --
//   compare --
//
//////////////////////////////////////////////////////////////////////////////////

module Control_fp (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic       ins_zero,
    input  logic       flush,
    input  logic       hazard,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    output logic [4:0] fpusel_s,
    output logic [2:0] storecntrl,  //sf,sd
    output logic [2:0] loadcntrl,  //lf,ld
    output logic [2:0] rm,
    output logic       memread,
    output logic       memwrite,
    output logic       regwrite,
    output logic       fpusrc,
    output logic       illegal_ins
);

  // intruction classification signal
  logic stall;

  always_comb begin
    fpusel_s = 5'b11111;
    loadcntrl = 3'b000;
    memread = 1'b0;
    memwrite = 1'b0;
    regwrite = 1'b0;
    fpusrc = 1'b0;
    illegal_ins = 1'b0;
    rm = 3'b000;
    unique case (opcode)
      7'b0000111: begin  //fp I-type (load)
        memread  = 1'b1;
        regwrite = (!stall) && (1'b1);
        fpusel_s = 5'b11111;
        fpusrc   = 1'b1;
        //load instruction here:
        if (funct3 == 3'b010) loadcntrl = 3'b001;
        else illegal_ins = (!flush) && (1'b1);
      end
      7'b0100111: begin
        memwrite = (!stall) && 1'b1;
        fpusrc   = 1'b1;
        fpusel_s = 5'b11111;
        unique case (funct3)
          3'b010:  storecntrl = 3'b001;
          default: illegal_ins = (!flush) && (1'b1);
        endcase
      end
      7'b1010011: begin  //fp R-type (arith & compare)
        regwrite = (!stall) && (1'b1);
        fpusrc   = 1'b1;
        unique case (funct7)
          7'h00: begin  //fadd
            fpusel_s = 5'b00000;
            rm = funct3;
          end
          7'h04: begin  //fsub
            fpusel_s = 5'b00001;
            rm = funct3;
          end
          7'h08: begin  //fmul
            fpusel_s = 5'b00010;
            rm = funct3;
          end
          7'h08: begin  //fdiv
            fpusel_s = 5'b00011;
            rm = funct3;
          end
          7'h2c: begin  //fsqrt
            fpusel_s = 5'b00100;
            rm = funct3;
          end
          7'h10:  //fsgnj_s
          unique case (funct3)
            3'b000: fpusel_s = 5'b00101;  //fsgnj
            3'b001: fpusel_s = 5'b00110;  //fsgnjn
            3'b010: fpusel_s = 5'b00111;  //fsgnjx
            default: begin
              fpusel_s = 5'b11111;
              illegal_ins = (!flush) && (1'b1);
              fpusrc = 1'b0;
            end
          endcase
          7'h14:
          unique case (funct3)
            3'b000: fpusel_s = 5'b01000;  //fmax.s
            3'b001: fpusel_s = 5'b01001;  //fmin.s
            default: begin
              fpusel_s = 5'b11111;
              illegal_ins = (!flush) && (1'b1);
              fpusrc = 1'b0;
            end
          endcase
          7'h60: begin
            rm = funct3;
            unique case (rs2)
              5'b00000: fpusel_s = 5'b10100;  //fcvt.w.s
              5'b00001: fpusel_s = 5'b10101;  //fcvt.wu.s
              default: begin
                fpusel_s = 5'b11111;
                illegal_ins = (!flush) && (1'b1);
                fpusrc = 1'b0;
              end
            endcase
          end
          7'h50: begin
            rm = funct3;
            unique case ({rs2, funct3})
              {5'h00, 3'b000} : fpusel_s = 5'b01101;  //fmv.x.w
              {5'h00, 3'b000} : fpusel_s = 5'b01110;  //fclass.s
              default: begin
                fpusel_s = 5'b11111;
                illegal_ins = (!flush) && (1'b1);
                fpusrc = 1'b0;
              end
            endcase
          end
          7'h50:
          unique case (funct3)
            3'b010: fpusel_s = 5'b01010;  //feq.s
            3'b001: fpusel_s = 5'b01011;  //flt.s
            3'b000: fpusel_s = 5'b01100;  //fle.s
            default: begin
              fpusel_s = 5'b11111;
              illegal_ins = (!flush) && (1'b1);
              fpusrc = 1'b0;
            end
          endcase
          7'h68: begin
            rm = funct3;
            unique case (rs2)
              5'b00000: fpusel_s = 5'b10110;  //fcvt.s.w
              5'b00001: fpusel_s = 5'b10111;  //fcvts.wu
              default: begin
                fpusel_s = 5'b11111;
                illegal_ins = (!flush) && (1'b1);
                fpusrc = 1'b0;
              end
            endcase
          end
          7'h78:
          if ((rs2 == 5'h00) && (funct3 == 3'b000)) begin  //fmv.w.x
            fpusel_s = 5'b01111;
          end else begin
            fpusel_s = 5'b11111;
            illegal_ins = (!flush) && (1'b1);
            fpusrc = 1'b0;
          end
          default: begin
            illegal_ins = 1'b1;
            fpusrc = 1'b0;
          end
        endcase
      end
      7'h001 ** 11: begin  // R4 type
        regwrite = (!stall) && (1'b1);
        fpusrc = 1'b1;
        rm = funct3;
        unique case (opcode[3:2])
          2'b00:   fpusel_s = 5'b10000;  //FMADD.S
          2'b01:   fpusel_s = 5'b10001;  //FMSUB.S
          2'b10:   fpusel_s = 5'b10010;  //FNMSUB.S
          2'b11:   fpusel_s = 5'b10011;  //FNMADD.S
          default: fpusel_s = 5'b00000;
        endcase
      end

      default: begin
        illegal_ins = (!flush) && (1'b1);
        fpusrc = 1'b0;
      end
    endcase
  end

  assign stall = flush || hazard || ins_zero;
endmodule : Control_fp
