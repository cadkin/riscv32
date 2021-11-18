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


module Control_fp
 (input  logic [6:0] opcode,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic [11:0] funct12,
  input  logic ins_zero,
  input  logic flush,
  input  logic hazard,
  input  logic [4:0] rs3,rs2,rs1,rd,
  output logic [4:0]fpusel,
  output logic [1:0]storecntrl, //sf,sd
  output logic [1:0]loadcntrl, //lf,ld
  output logic      feq,
  output logic      fne,
  output logic      flt,
  output logic      memread,
  output logic      memwrite,
  output logic      regwrite,
  output logic      fpusrc,
  output logic      compare,
  output logic      auipc,
  output logic      lui,
  output logic      illegal_ins, 
  output logic [2:0] csrsel, 
  output logic      csrwrite, 
  output logic      csrread,
  output logic trap_ret);

  // intruction classification signal
  
  logic stall;

  always_comb begin
    fpusel_s=5'b11111;
    storecntrl=2'b00;
    loadcntrl=2'b00;
    cmpcntrl=2'b00;
    beq=1'b0;
    bne=1'b0;
    blt=1'b0;
	memread=1'b0;
	memwrite=1'b0;
	regwrite=1'b0;
	alusrc=1'b0;
	compare=1'b0;
	auipc=1'b0;
	lui=1'b0;
	illegal_ins=1'b0;
	csrsel = 3'b000;
	csrwrite = 1'b0;
	csrread = 0;
  	trap_ret = 0;
    unique case (opcode)
      7'b0000111:               //fp I-type (load) 
        begin
        memread=1'b1;
        regwrite=(!stall)&&(1'b1);
        fpusel_s=5'11111;
        alusrc=1'b1; 
            if(func3 == 3'b010)
		//load instruction here:
		loadcntrl=5'b00001;
            else illegal_ins=(!flush)&&(1'b1); 

            end;
        end
      7'b0100111:               // fp S-type (store)
        begin
          memwrite = (!stall)&&1'b1;
          alusrc=1'b1;
          fpusel_s=5'11111;
          unique case(funct3)
              3'b010: storecntrl=3'b001;
              default: illegal_ins=(!flush)&&(1'b1);
          endcase 
        end
      7'b1010011:               //fp R-type (arith & compare)
	begin
	regwrite=(!stall)&&(1'b1);

          unique case(funct7)
			7'h00://fadd
				fpusel_s=5'b00000;
			7'h04://fsub
				fpusel_s=5'b00001;
			7'h08://fmul
				fpusel_s=5'b00010;
			7'h08://fdiv	
				fpusel_s=5'b00011;
			7'h2c://fsqrt
				fpusel_s=5'b00100;
			7'h10:	//fsgnj_s 
			   unique case(funct3)
				3'b000 ://fsgnj
				fpusel_s=5'b00101;
				3'b001 ://fsgnjn
				fpusel_s=5'b00110;
				3'b010 ://fsgnjx
				fpusel_s=5'b00111;
				 default: begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase;
			7'h14:	
			   unique case(funct3)
				3'b000 ://fmax.s
				fpusel_s=5'b01000;
				3'b001 ://fmin.s
				fpusel_s=5'b01001;
			   	default: begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase;
			7'h60:	
			   unique case(rs2)
				5'b00000 ://fcvt.w.s
				fpusel_s=5'b10100;
				5'b00001 ://fcvt.wu.s
				fpusel_s=5'b10101;
			   	default: begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase;
			7'h50:	
			   unique case({rs2,funct3})
				{5'h00,3'b000}://fmv.x.w
				fpusel_s=5'b01101;
				{5'h00,3'b000}:	//fclass.s
				fpusel_s=5'b01110;
				default: begin 
					fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase;
			7'h50:	
			   unique case(funct3)
				3'b010 ://feq.s
				fpusel_s=5'b01010;
				3'b001 ://flt.s
				fpusel_s=5'b01011;
				3'b000 ://fle.s
				fpusel_s=5'b01100;		
			   	default: begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase; 	
			7'h68:	
			   unique case(rs2)
				5'b00000 ://fcvt.s.w
				fpusel_s=5'b10110;
				5'b00001 ://fcvts.wu
				fpusel_s=5'b10111;
			   	default: begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
			   endcase;
			7'h78:
				if ((rs2 ==5'h00) && (funct3 == 3'b000)) begin //fmv.w.x
				fpusel_s=5'b01111;
				end else begin fpusel_s = 5'b11111;
					illegal_ins=(!flush)&&(1'b1);
					end; 
		    default:
		      illegal_ins=1'b1;				
            endcase
        end		
      7'b001**11:               // R4 type
		begin
		regwrite=(!stall)&&(1'b1);
        fpusrc=1'b1;
          unique case(funct3)
			2'b00://FMADD.S
			     	fpusel_s = 5'b10000;
			2'b01://FMSUB.S
				fpusel_s = 5'b10001;
			2'b10://FNMSUB.S
				fpusel_s = 5'b10010;
			2'b11://FNMADD.S
				fpusel_s = 5'b10011;
	endcase
        end
	
     default:
        illegal_ins=(!flush)&&(1'b1);
    endcase
  end

  
  assign stall = flush || hazard || ins_zero;
    


endmodule: Control
